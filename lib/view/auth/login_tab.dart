import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:table_now_app/config.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/custom/custom_button.dart';
import 'package:table_now_app/custom/custom_text_field.dart';
import 'package:table_now_app/custom/util/navigation/custom_navigation_util.dart';
import 'package:table_now_app/model/customer.dart';
import 'package:table_now_app/theme/app_colors.dart';
import 'package:table_now_app/utils/custom_common_util.dart';
import 'package:table_now_app/view/Dev/dev_07.dart';
import 'package:table_now_app/vm/auth_notifier.dart';

/// 로그인 탭 위젯
///
/// 이 위젯은 AuthScreen의 탭 중 하나로 사용됩니다.
/// 독립적으로 작업할 수 있도록 별도 파일로 분리되어 있습니다.
class LoginTab extends ConsumerStatefulWidget {
  const LoginTab({super.key});

  @override
  ConsumerState<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends ConsumerState<LoginTab> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _autoLoginEnabled = false; // 자동 로그인 체크박스 상태

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // 폼 검증
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // 로딩 시작
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    // 로딩 오버레이 표시
    CustomCommonUtil.showLoadingOverlay(context, message: '로그인 중...');

    // API URL 구성
    final apiBaseUrl = getApiBaseUrl();
    final url = Uri.parse('$apiBaseUrl/api/customer/login');

    try {
      // Form 데이터 준비
      final requestBody = {
        'customer_email': _emailController.text.trim(),
        'customer_pw': _passwordController.text,
      };

      // HTTP POST 요청 (Form 데이터)
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: requestBody,
          )
          .timeout(const Duration(seconds: 30));

      // 로딩 오버레이 숨기기
      if (mounted) {
        CustomCommonUtil.hideLoadingOverlay(context);
      }

      // 응답 처리
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // 응답 파싱
      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        // 성공 처리
        if (responseData['result'] != null &&
            responseData['result'] != 'Error') {
          // 로그인 성공
          final customerData = responseData['result'];
          final customerName = customerData['customer_name'] ?? '고객';

          // Customer 모델 생성
          final customer = Customer.fromJson(customerData);

          // 인증 Notifier를 통해 로그인 처리 (GetStorage 자동 저장 및 전역 상태 업데이트)
          await ref.read(authNotifierProvider.notifier).login(customer, _autoLoginEnabled);

          if (mounted) {
            // 환영 메시지 스낵바 표시
            CustomCommonUtil.showSuccessSnackbar(
              context: context,
              title: '로그인 성공',
              message: '$customerName님, 환영합니다!',
            );

            // dev_07 페이지로 이동
            await CustomNavigationUtil.offAll(context, const Dev_07());
          }
        } else {
          // 서버 에러 응답
          final errorMsg = responseData['errorMsg'] ?? '로그인에 실패했습니다.';
          if (mounted) {
            CustomCommonUtil.showErrorSnackbar(
              context: context,
              message: errorMsg,
            );
          }
        }
      } else {
        // HTTP 에러
        final errorMsg =
            responseData['errorMsg'] ??
            '서버 오류가 발생했습니다. (${response.statusCode})';
        if (mounted) {
          CustomCommonUtil.showErrorSnackbar(
            context: context,
            message: errorMsg,
          );
        }
      }
    } catch (e) {
      // 로딩 오버레이 숨기기
      if (mounted) {
        CustomCommonUtil.hideLoadingOverlay(context);
        setState(() {
          _isLoading = false;
        });
      }

      // 에러 처리
      String errorMessage = '로그인 중 오류가 발생했습니다.';
      if (e.toString().contains('TimeoutException')) {
        errorMessage = '요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = '네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.';
      } else {
        errorMessage = '오류: ${e.toString()}';
      }

      if (mounted) {
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: errorMessage,
        );
      }

      // 디버깅을 위한 에러 로그
      CustomCommonUtil.logError(
        functionName: '_handleLogin',
        error: e,
        url: '$apiBaseUrl/api/customer/login',
      );
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    if (provider != 'google') {
      if (mounted) {
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '지원하지 않는 소셜 로그인입니다.',
        );
      }
      return;
    }

    // 로딩 시작
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    // 로딩 오버레이 표시
    CustomCommonUtil.showLoadingOverlay(context, message: 'Google 로그인 중...');

    try {
      // Google Sign-In 초기화
      // Web client ID 사용 (google-services.json의 client_type: 3)
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        // Android에서 명시적으로 serverClientId 설정 (Web client ID)
        serverClientId: '447164902457-anlngk8m69k69cr4nq27nrn49tbcfai9.apps.googleusercontent.com',
      );

      if (kDebugMode) {
        print('🔐 Google Sign-In 초기화 완료');
        print('   Server Client ID: ${googleSignIn.serverClientId}');
      }

      // Google 로그인 시도 전 상태 확인
      if (kDebugMode) {
        print('🔐 Google 로그인 시도 전 상태 확인...');
        try {
          // 이전 로그인 상태 확인 (에러 발생 여부 확인용)
          final currentUser = await googleSignIn.signInSilently();
          if (currentUser != null) {
            print('   ✅ 이전 로그인 세션 발견: ${currentUser.email}');
          } else {
            print('   ℹ️  이전 로그인 세션 없음');
          }
        } catch (e) {
          print('   ⚠️  signInSilently 실패 (정상일 수 있음): $e');
        }
      }

      // Google 로그인 시도
      if (kDebugMode) {
        print('🔐 Google 로그인 시도 중...');
      }
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // 사용자가 로그인 취소한 경우
      if (googleUser == null) {
        if (mounted) {
          CustomCommonUtil.hideLoadingOverlay(context);
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // 백엔드 API 호출을 위한 데이터 준비
      final apiBaseUrl = getApiBaseUrl();
      final url = Uri.parse('$apiBaseUrl/api/customer/social-login');

      final requestBody = {
        'customer_email': googleUser.email,
        'customer_name': googleUser.displayName ?? '구글 사용자',
        'provider_subject': googleUser.id, // Google ID
      };

      // HTTP POST 요청
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: requestBody,
          )
          .timeout(const Duration(seconds: 30));

      // 로딩 오버레이 숨기기
      if (mounted) {
        CustomCommonUtil.hideLoadingOverlay(context);
      }

      // 응답 처리
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // 응답 파싱
      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        // result가 "NeedLink"인 경우: 계정 통합 필요
        if (responseData['result'] == 'NeedLink') {
          final customerSeq = responseData['customer_seq'];

          // 계정 통합 확인 다이얼로그 표시
          final bool shouldLink = await CustomCommonUtil.showConfirmDialog(
            context: context,
            title: '계정 통합',
            message: '구글 로그인으로 통합 하시겠습니까?\n통합시 기존 비밀 번호는 사라집니다.',
            confirmText: '예',
            cancelText: '아니오',
          );

          if (shouldLink == true) {
            // 계정 통합 진행
            await _linkSocialAccount(
              customerSeq: customerSeq,
              providerSubject: googleUser.id,
              customerName: googleUser.displayName ?? '구글 사용자',
            );
          } else {
            // 통합 거부
            if (mounted) {
              CustomCommonUtil.showErrorSnackbar(
                context: context,
                message: '일반 로그인 또는 계정 통합을 바랍니다.',
              );
            }
          }
        } else if (responseData['result'] != null &&
            responseData['result'] != 'Error') {
          // 로그인 성공 또는 회원가입 성공
          final customerData = responseData['result'];
          final customerName = customerData['customer_name'] ?? '고객';

          // Customer 모델 생성
          final customer = Customer.fromJson(customerData);

          // 인증 Notifier를 통해 로그인 처리 (GetStorage 자동 저장 및 전역 상태 업데이트)
          await ref.read(authNotifierProvider.notifier).login(customer, _autoLoginEnabled);

          if (mounted) {
            // 환영 메시지 스낵바 표시
            CustomCommonUtil.showSuccessSnackbar(
              context: context,
              title: '로그인 성공',
              message: '$customerName님, 환영합니다!',
            );

            // dev_07 페이지로 이동
            await CustomNavigationUtil.offAll(context, const Dev_07());
          }
        } else {
          // 서버 에러 응답
          final errorMsg = responseData['errorMsg'] ?? '로그인에 실패했습니다.';
          if (mounted) {
            CustomCommonUtil.showErrorSnackbar(
              context: context,
              message: errorMsg,
            );
          }
        }
      } else {
        // HTTP 에러
        final errorMsg =
            responseData['errorMsg'] ??
            '서버 오류가 발생했습니다. (${response.statusCode})';
        if (mounted) {
          CustomCommonUtil.showErrorSnackbar(
            context: context,
            message: errorMsg,
          );
        }
      }
    } catch (e) {
      // 로딩 오버레이 숨기기
      if (mounted) {
        CustomCommonUtil.hideLoadingOverlay(context);
        setState(() {
          _isLoading = false;
        });
      }

      // 에러 처리
      String errorMessage = 'Google 로그인 중 오류가 발생했습니다.';
      
      if (e is PlatformException) {
        // Google Sign-In PlatformException 처리
        final code = e.code;
        final message = e.message ?? '';
        final details = e.details?.toString() ?? '';
        
        if (kDebugMode) {
          print('❌ PlatformException 상세 정보:');
          print('   Code: $code');
          print('   Message: $message');
          print('   Details: $details');
          print('   Full Exception: $e');
        }
        
        if (code == 'network_error' || code == '7') {
          errorMessage = '네트워크 연결에 실패했습니다.\n\n가능한 원인:\n'
              '1. Google Play Services 업데이트 필요\n'
              '2. 에뮬레이터의 Google 계정 확인\n'
              '3. 인터넷 연결 확인\n'
              '4. 앱 재설치 필요\n\n'
              '에러 코드: $code\n'
              '상세: ${message.isNotEmpty ? message : details}';
        } else if (code == 'sign_in_canceled' || code == '12500') {
          errorMessage = '로그인이 취소되었습니다.';
        } else if (code == 'sign_in_failed' || code == '10') {
          errorMessage = 'Google 로그인에 실패했습니다.\n앱 설정을 확인해주세요.\n\n에러 코드: $code';
        } else {
          errorMessage = 'Google 로그인 오류: $code\n${message.isNotEmpty ? message : details}';
        }
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = '요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = '네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.';
      } else {
        errorMessage = '오류: ${e.toString()}';
      }

      if (mounted) {
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: errorMessage,
        );
      }

      // 디버깅을 위한 에러 로그
      CustomCommonUtil.logError(functionName: '_handleSocialLogin', error: e);
    }
  }

  /// 계정 통합 처리
  Future<void> _linkSocialAccount({
    required int customerSeq,
    required String providerSubject,
    required String customerName,
  }) async {
    if (!mounted) return;
    // 로딩 오버레이 표시
    CustomCommonUtil.showLoadingOverlay(context, message: '계정 통합 중...');

    final apiBaseUrl = getApiBaseUrl();
    final url = Uri.parse('$apiBaseUrl/api/customer/link-social');

    try {
      final requestBody = {
        'customer_seq': customerSeq.toString(),
        'provider_subject': providerSubject,
        'customer_name': customerName,
      };

      // HTTP POST 요청
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: requestBody,
          )
          .timeout(const Duration(seconds: 30));

      // 로딩 오버레이 숨기기
      if (mounted) {
        CustomCommonUtil.hideLoadingOverlay(context);
      }

      // 응답 파싱
      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        if (responseData['result'] != null &&
            responseData['result'] != 'Error') {
          // 통합 성공
          final customerData = responseData['result'];
          final customerName = customerData['customer_name'] ?? '고객';

          // Customer 모델 생성
          final customer = Customer.fromJson(customerData);

          // 인증 Notifier를 통해 로그인 처리 (GetStorage 자동 저장 및 전역 상태 업데이트)
          await ref.read(authNotifierProvider.notifier).login(customer, _autoLoginEnabled);

          if (mounted) {
            // 환영 메시지 스낵바 표시
            CustomCommonUtil.showSuccessSnackbar(
              context: context,
              title: '계정 통합 완료',
              message: '$customerName님, 계정이 통합되었습니다!',
            );

            // dev_07 페이지로 이동
            await CustomNavigationUtil.offAll(context, const Dev_07());
          }
        } else {
          // 서버 에러 응답
          final errorMsg = responseData['errorMsg'] ?? '계정 통합에 실패했습니다.';
          if (mounted) {
            CustomCommonUtil.showErrorSnackbar(
              context: context,
              message: errorMsg,
            );
          }
        }
      } else {
        // HTTP 에러
        final errorMsg =
            responseData['errorMsg'] ??
            '서버 오류가 발생했습니다. (${response.statusCode})';
        if (mounted) {
          CustomCommonUtil.showErrorSnackbar(
            context: context,
            message: errorMsg,
          );
        }
      }
    } catch (e) {
      // 로딩 오버레이 숨기기
      if (mounted) {
        CustomCommonUtil.hideLoadingOverlay(context);
      }

      // 에러 처리
      String errorMessage = '계정 통합 중 오류가 발생했습니다.';
      if (e.toString().contains('TimeoutException')) {
        errorMessage = '요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = '네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.';
      } else {
        errorMessage = '오류: ${e.toString()}';
      }

      if (mounted) {
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: errorMessage,
        );
      }

      // 디버깅을 위한 에러 로그
      CustomCommonUtil.logError(
        functionName: '_linkSocialAccount',
        error: e,
        url: '$apiBaseUrl/api/customer/link-social',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SingleChildScrollView(
      child: Padding(
        padding: mainDefaultPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: mainLargeSpacing,
            children: [
              // 이메일 입력 필드
              CustomTextField(
                controller: _emailController,
                labelText: '이메일',
                hintText: '이메일을 입력하세요',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요';
                  }
                  if (!value.contains('@')) {
                    return '올바른 이메일 형식이 아닙니다';
                  }
                  return null;
                },
              ),

              // 비밀번호 입력 필드
              CustomTextField(
                controller: _passwordController,
                labelText: '비밀번호',
                hintText: '비밀번호를 입력하세요',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요';
                  }
                  if (value.length < 6) {
                    return '비밀번호는 6자 이상이어야 합니다';
                  }
                  return null;
                },
              ),

              // 자동 로그인 체크박스
              Row(
                children: [
                  Checkbox(
                    value: _autoLoginEnabled,
                    onChanged: (value) {
                      if (!mounted) return;
                      setState(() {
                        _autoLoginEnabled = value ?? false;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!mounted) return;
                      setState(() {
                        _autoLoginEnabled = !_autoLoginEnabled;
                      });
                    },
                    child: Text(
                      '자동 로그인',
                      style: mainBodyTextStyle.copyWith(
                        color: p.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              // 로그인 버튼
              CustomButton(
                btnText: _isLoading ? '로그인 중...' : '로그인',
                onCallBack: _isLoading ? () {} : _handleLogin,
                buttonType: ButtonType.elevated,
              ),

              // 구분선 (소셜 로그인과 구분)
              Row(
                children: [
                  Expanded(child: Divider(color: p.divider)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: mainDefaultSpacing),
                    child: Text(
                      '또는',
                      style: mainSmallTextStyle.copyWith(
                        color: p.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: p.divider)),
                ],
              ),

              // 소셜 로그인 버튼 (Google 브랜드 가이드라인 준수)
              _GoogleSignInButton(
                onPressed: _isLoading ? null : () => _handleSocialLogin('google'),
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-15
// 작성자: 김택권
// 설명: 로그인 탭 위젯 - 일반 로그인 및 구글 소셜 로그인 기능 구현
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-15 김택권: 초기 생성
//   - 일반 로그인 API 연동 구현 (/api/customer/login)
//   - 로그인 성공 시 GetStorage에 Customer 정보 저장
//   - 로그인 성공 시 환영 메시지 표시 및 dev_07 페이지로 이동
//   - 구글 소셜 로그인 구현 (google_sign_in 패키지 사용)
//   - 소셜 로그인 시 기존 로컬 계정과 이메일 중복 체크
//   - 기존 로컬 계정 존재 시 계정 통합 다이얼로그 표시
//   - 계정 통합 API 연동 (/api/customer/link-social)
//   - 에러 처리 및 로딩 상태 관리
//
// 2026-01-15 김택권: GetStorage 키 상수화
//   - 'customer' 문자열을 config.dart의 storageKeyCustomer 상수로 변경
//   - 오타 방지 및 일관성 유지
//
// 2026-01-15 김택권: UI 일관성 개선
//   - 하드코딩된 padding 값을 ui_config.dart의 상수로 변경
//   - mainDefaultSpacing 상수 사용
//
// 2026-01-15: Google 브랜드 가이드라인 준수
//   - Google 소셜 로그인 버튼을 Google 브랜드 가이드라인에 맞춰 구현
//   - 공식 브랜드 색상 및 스타일 적용
//   참고: https://developers.google.com/identity/branding-guidelines

/// Google 브랜드 가이드라인에 맞춘 Google 로그인 버튼
///
/// Google 브랜드 가이드라인을 준수하여 디자인된 버튼입니다.
/// 참고: https://developers.google.com/identity/branding-guidelines
class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _GoogleSignInButton({
    required this.onPressed,
    this.isLoading = false,
  });

  // Google 브랜드 색상 (공식 가이드라인)
  static const Color _googleWhite = Color(0xFFFFFFFF);
  static const Color _googleBlack = Color(0xFF1A1A1A);
  static const Color _googleGray = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 테마에 따른 색상 결정
    final backgroundColor = isDark ? _googleBlack : _googleWhite;
    final textColor = isDark ? _googleWhite : _googleBlack;
    final borderColor = isDark ? _googleGray : const Color(0xFFDADCE0);

    return SizedBox(
      width: double.infinity,
      height: mainButtonHeight,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(
            color: isLoading ? borderColor.withOpacity(0.5) : borderColor,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // Google 가이드라인: 직사각형 모서리
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 로딩 중일 때 인디케이터, 아닐 때 Google 아이콘
            if (isLoading) ...[
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              ),
              const SizedBox(width: 12),
            ] else ...[
              // 테마에 맞는 Google 아이콘 표시
              Image.asset(
                isDark 
                  ? 'images/android_dark_rd_na@3x.png' 
                  : 'images/android_light_rd_na@3x.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
            ],
            // 버튼 텍스트
            Text(
              isLoading ? '로그인 중...' : 'Google로 로그인',
              style: mainBodyTextStyle.copyWith(
                color: isLoading ? textColor.withOpacity(0.6) : textColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
