import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_now_app/config.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/custom/custom_button.dart';
import 'package:table_now_app/custom/custom_text_field.dart';
import 'package:table_now_app/model/customer.dart';
import 'package:table_now_app/theme/app_colors.dart';
import 'package:table_now_app/utils/custom_common_util.dart';
import 'package:table_now_app/view/auth/password_change_screen.dart';
import 'package:table_now_app/custom/util/navigation/custom_navigation_util.dart';
import 'package:table_now_app/vm/auth_notifier.dart';

/// 회원 정보 수정 화면
///
/// 사용자의 회원 정보를 수정할 수 있는 화면입니다.
/// provider에 따라 비밀번호 수정 필드가 표시/숨김 처리됩니다.
/// GetStorage에서 로그인 정보를 가져와 사용합니다.
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isLoadingData = true;
  String? _provider;
  String? _errorMessage;
  Customer? _customer;
  int? _customerSeq;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// 고객 정보 조회
  Future<void> _loadCustomerData() async {
    if (!mounted) return;
    // 인증 Notifier에서 로그인 정보 가져오기
    final authState = ref.read(authNotifierProvider);

    if (authState.customer != null) {
      // 전역 상태에 저장된 데이터가 있으면 사용
      try {
        _customer = authState.customer;
        _customerSeq = _customer!.customerSeq;
        _nameController.text = _customer!.customerName;
        _emailController.text = _customer!.customerEmail;
        _phoneController.text = _customer!.customerPhone ?? '';
        _provider = _customer!.provider;
        if (mounted) {
          setState(() {
            _isLoadingData = false;
          });
        }
        return;
      } catch (e) {
        // 데이터 파싱 실패 시 API로 조회
        CustomCommonUtil.logError(functionName: '_loadCustomerData', error: e);
      }
    }

    // GetStorage에 데이터가 없거나 파싱 실패 시 API로 조회
    // customer_seq가 없으면 에러
    if (_customerSeq == null) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
          _errorMessage = '로그인 정보를 찾을 수 없습니다. 다시 로그인해주세요.';
        });
      }
      return;
    }

    // API로 고객 정보 조회
    final apiBaseUrl = getApiBaseUrl();
    final url = Uri.parse('$apiBaseUrl/api/customer/$_customerSeq');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));

        if (responseData['result'] != null &&
            responseData['result'] != 'Error') {
          final customerData = responseData['result'];
          _customer = Customer.fromJson(customerData);
          _customerSeq = _customer!.customerSeq;
          _nameController.text = _customer!.customerName;
          _emailController.text = _customer!.customerEmail;
          _phoneController.text = _customer!.customerPhone ?? '';
          _provider = _customer!.provider;

          // 인증 Notifier에도 업데이트 (GetStorage 자동 저장 및 전역 상태 업데이트)
          await ref
              .read(authNotifierProvider.notifier)
              .updateCustomer(_customer!);
        } else {
          _errorMessage = responseData['errorMsg'] ?? '고객 정보를 불러올 수 없습니다.';
        }
      } else {
        _errorMessage = '서버 오류가 발생했습니다. (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = '고객 정보를 불러오는 중 오류가 발생했습니다.';
      CustomCommonUtil.logError(
        functionName: '_loadCustomerData',
        error: e,
        url: '$apiBaseUrl/api/customer/$_customerSeq',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  /// 회원 정보 수정
  Future<void> _handleUpdate() async {
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
    CustomCommonUtil.showLoadingOverlay(context, message: '회원 정보 수정 중...');

    // API URL 구성
    final apiBaseUrl = getApiBaseUrl();
    final url = Uri.parse('$apiBaseUrl/api/customer/$_customerSeq');

    try {
      // Form 데이터 준비
      // 이메일은 읽기 전용이므로 수정 요청에 포함하지 않음
      // 비밀번호 변경은 별도 화면(PasswordChangeScreen)에서 처리
      final requestBody = {
        'customer_name': _nameController.text.trim(),
        'customer_phone': _phoneController.text.trim(),
      };

      // HTTP PUT 요청
      final response = await http
          .put(
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
        if (responseData['result'] == 'OK') {
          // 수정 성공 - 인증 Notifier 업데이트 (GetStorage 자동 저장 및 전역 상태 업데이트)
          if (_customer != null) {
            final updatedCustomer = _customer!.copyWith(
              customerName: _nameController.text.trim(),
              customerEmail: _emailController.text.trim(),
              customerPhone: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
            );
            await ref
                .read(authNotifierProvider.notifier)
                .updateCustomer(updatedCustomer);
          }

          if (mounted) {
            CustomCommonUtil.showSuccessSnackbar(
              context: context,
              title: '수정 완료',
              message: '회원 정보가 성공적으로 수정되었습니다.',
            );
            Navigator.of(context).pop(true); // 수정 완료 반환
          }
        } else {
          // 서버 에러 응답
          final errorMsg = responseData['errorMsg'] ?? '회원 정보 수정에 실패했습니다.';
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
      String errorMessage = '회원 정보 수정 중 오류가 발생했습니다.';
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
        functionName: '_handleUpdate',
        error: e,
        url: '$apiBaseUrl/api/customer/$_customerSeq',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(
          '회원 정보 수정',
          style: mainAppBarTitleStyle.copyWith(color: p.textPrimary),
        ),
        centerTitle: mainAppBarCenterTitle,
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
      ),
      body: _isLoadingData
          ? Center(child: CircularProgressIndicator(color: p.primary))
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  mainDefaultVerticalSpacing,
                  Text(
                    _errorMessage!,
                    style: mainMediumTextStyle.copyWith(color: p.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  mainDefaultVerticalSpacing,
                  CustomButton(
                    btnText: '다시 시도',
                    onCallBack: () {
                      if (!mounted) return;
                      setState(() {
                        _errorMessage = null;
                        _isLoadingData = true;
                      });
                      _loadCustomerData();
                    },
                    buttonType: ButtonType.elevated,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: mainDefaultPadding,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: mainLargeSpacing,
                    children: [
                      // 계정 타입 표시
                      if (_provider == 'google')
                        Container(
                          padding: mainMediumPadding,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: mainSmallBorderRadius,
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            spacing: mainSmallSpacing,
                            children: [
                              Icon(
                                Icons.account_circle,
                                color: Colors.blue.shade700,
                              ),
                              Text(
                                '구글 로그인 계정',
                                style: mainSmallTextStyle.copyWith(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // 이름 입력 필드
                      CustomTextField(
                        controller: _nameController,
                        labelText: '이름',
                        hintText: '이름을 입력하세요',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이름을 입력해주세요';
                          }
                          return null;
                        },
                      ),

                      // 이메일 입력 필드 (읽기 전용)
                      CustomTextField(
                        controller: _emailController,
                        labelText: '이메일',
                        hintText: '이메일을 입력하세요',
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                        enabled: false,
                        fillColor: p.cardBackground.withOpacity(0.5),
                        filled: true,
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

                      // 전화번호 입력 필드
                      CustomTextField(
                        controller: _phoneController,
                        labelText: '전화번호',
                        hintText: '전화번호를 입력하세요 (선택사항)',
                        keyboardType: TextInputType.phone,
                      ),

                      // 비밀번호 변경 버튼 (로컬 계정만)
                      if (_provider == 'local') ...[
                        const Divider(),
                        CustomButton(
                          btnText: '비밀번호 변경',
                          onCallBack: () {
                            if (_customer != null) {
                              CustomNavigationUtil.to(
                                context,
                                PasswordChangeScreen(
                                  customerSeq: _customerSeq!,
                                  customerEmail: _customer!.customerEmail,
                                  customerName: _customer!.customerName,
                                ),
                              );
                            }
                          },
                          buttonType: ButtonType.outlined,
                        ),
                      ],

                      // 수정 버튼
                      CustomButton(
                        btnText: _isLoading ? '수정 중...' : '수정하기',
                        onCallBack: _isLoading ? () {} : _handleUpdate,
                        buttonType: ButtonType.elevated,
                      ),
                    ],
                  ),
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
// 설명: 회원 정보 수정 화면 - 사용자 프로필 정보 수정 및 비밀번호 변경 기능
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-15 김택권: 초기 생성
//   - GetStorage에서 로그인 정보 조회
//   - API를 통한 회원 정보 조회 (/api/customer/{customer_seq})
//   - provider에 따른 UI 분기 처리 (구글 계정/로컬 계정)
//   - 이메일 필드 읽기 전용 처리
//   - 회원 정보 수정 API 연동 (/api/customer/{customer_seq} PUT)
//   - 구글 계정의 경우 비밀번호 변경 버튼 숨김 처리
//   - 로컬 계정의 경우 비밀번호 변경 버튼 표시 및 PasswordChangeScreen으로 이동
//   - 수정 성공 시 GetStorage 업데이트 및 화면 반환값 처리
//   - 에러 처리 및 로딩 상태 관리
//
// 2026-01-15 김택권: GetStorage 키 상수화
//   - 'customer' 문자열을 config.dart의 storageKeyCustomer 상수로 변경
//   - 오타 방지 및 일관성 유지
//
// 2026-01-15 김택권: UI 일관성 개선
//   - 하드코딩된 UI 값을 ui_config.dart의 상수로 변경
//   - mainDefaultVerticalSpacing, mainMediumPadding, mainSmallBorderRadius, mainSmallSpacing 상수 사용
