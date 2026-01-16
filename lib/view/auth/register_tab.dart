import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_now_app/config.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/custom/custom_button.dart';
import 'package:table_now_app/custom/custom_text_field.dart';
import 'package:table_now_app/utils/custom_common_util.dart';

/// 회원가입 탭 위젯
///
/// 이 위젯은 AuthScreen의 탭 중 하나로 사용됩니다.
/// 독립적으로 작업할 수 있도록 별도 파일로 분리되어 있습니다.
class RegisterTab extends ConsumerStatefulWidget {
  const RegisterTab({super.key});

  @override
  ConsumerState<RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends ConsumerState<RegisterTab> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
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
    CustomCommonUtil.showLoadingOverlay(context, message: '회원가입 중...');

    // API URL 구성
    final apiBaseUrl = getApiBaseUrl();
    final url = Uri.parse('$apiBaseUrl/api/customer/register');

    try {
      // Form 데이터 준비
      final phoneNumber = _phoneController.text.trim();
      final requestBody = {
        'customer_name': _nameController.text.trim(),
        'customer_phone': phoneNumber.isEmpty ? '' : phoneNumber, // 빈 문자열이면 빈 문자열로 전송 (백엔드에서 null 처리)
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
          // 회원가입 성공
          if (mounted) {
            CustomCommonUtil.showSuccessDialog(
              context: context,
              title: '회원가입 성공',
              message: '회원가입이 완료되었습니다.\n로그인 탭에서 로그인해주세요.',
              onConfirm: () {
                // 입력 필드 초기화
                _nameController.clear();
                _emailController.clear();
                _phoneController.clear();
                _passwordController.clear();
                _passwordConfirmController.clear();
              },
              confirmText: '확인',
            );
          }
        } else {
          // 서버 에러 응답
          final errorMsg = responseData['errorMsg'] ?? '회원가입에 실패했습니다.';
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
      String errorMessage = '회원가입 중 오류가 발생했습니다.';
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
        functionName: '_handleRegister',
        error: e,
        url: '$apiBaseUrl/api/customer/register',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: mainDefaultPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: mainLargeSpacing,
            children: [
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

              // 전화번호 입력 필드 (선택사항)
              CustomTextField(
                controller: _phoneController,
                labelText: '전화번호 (선택사항)',
                hintText: '전화번호를 입력하세요 (선택사항)',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  // 전화번호는 선택사항이므로 빈 값도 허용
                  // 전화번호 형식 검증 (선택사항)
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

              // 비밀번호 확인 입력 필드
              CustomTextField(
                controller: _passwordConfirmController,
                labelText: '비밀번호 확인',
                hintText: '비밀번호를 다시 입력하세요',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호 확인을 입력해주세요';
                  }
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다';
                  }
                  return null;
                },
              ),

              // 회원가입 버튼
              CustomButton(
                btnText: _isLoading ? '처리 중...' : '회원가입',
                onCallBack: _isLoading ? () {} : _handleRegister,
                buttonType: ButtonType.elevated,
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
// 설명: 회원가입 탭 위젯 - 일반 회원가입 기능 구현
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-15 김택권: 초기 생성
//   - 회원가입 폼 구현 (이름, 이메일, 전화번호, 비밀번호, 비밀번호 확인)
//   - 폼 검증 로직 구현
//   - 회원가입 API 연동 (/api/customer/register)
//   - 회원가입 성공 시 폼 초기화 및 성공 다이얼로그 표시
//   - 에러 처리 및 로딩 상태 관리
//
// 2026-01-15 김택권: 전화번호 필드 선택사항 처리
//   - 전화번호 필드를 선택사항으로 변경
//   - 라벨 텍스트를 "전화번호 (선택사항)"으로 변경
//   - 전화번호 검증 로직 제거 (빈 값 허용)