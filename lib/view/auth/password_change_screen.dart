import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_now_app/config.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/custom/custom_button.dart';
import 'package:table_now_app/custom/custom_text_field.dart';
import 'package:table_now_app/theme/app_colors.dart';
import 'package:table_now_app/utils/custom_common_util.dart';

/// 비밀번호 변경 화면
///
/// 이메일 인증 코드를 통한 비밀번호 변경 화면입니다.
/// 1단계: 인증 코드 요청 및 입력
/// 2단계: 새 비밀번호 입력
/// 작성일: 2026-01-15
/// 작성자: 김택권
class PasswordChangeScreen extends ConsumerStatefulWidget {
  final int customerSeq;
  final String customerEmail;
  final String customerName;

  const PasswordChangeScreen({
    super.key,
    required this.customerSeq,
    required this.customerEmail,
    required this.customerName,
  });

  @override
  ConsumerState<PasswordChangeScreen> createState() =>
      _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends ConsumerState<PasswordChangeScreen> {
  // 단계 관리 (1: 인증 코드 요청/입력, 2: 새 비밀번호 입력)
  int _currentStep = 1;

  // 인증 코드 관련
  final _authCodeController = TextEditingController();
  String? _authToken;
  DateTime? _expiresAt;
  bool _isRequestingCode = false;
  bool _isVerifyingCode = false;

  // 비밀번호 관련
  final _newPasswordController = TextEditingController();
  final _newPasswordConfirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isChangingPassword = false;

  @override
  void dispose() {
    _authCodeController.dispose();
    _newPasswordController.dispose();
    _newPasswordConfirmController.dispose();
    super.dispose();
  }

  /// 인증 코드 요청
  Future<void> _requestAuthCode() async {
    if (_isRequestingCode) return;

    setState(() {
      _isRequestingCode = true;
    });

    try {
      final apiBaseUrl = getApiBaseUrl();
      final uri = Uri.parse('$apiBaseUrl/api/customer/request-password-change');

      final request = http.MultipartRequest('POST', uri);
      request.fields['customer_seq'] = widget.customerSeq.toString();

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && responseData['result'] == 'OK') {
        setState(() {
          _authToken = responseData['auth_token'];
          _expiresAt = DateTime.parse(responseData['expires_at']);
        });

        if (mounted) {
          CustomCommonUtil.showSuccessSnackbar(
            context: context,
            title: '인증 코드 발송',
            message: '이메일로 인증 코드가 발송되었습니다.',
          );
        }
      } else {
        final errorMsg =
            responseData['errorMsg'] ?? '인증 코드 발송에 실패했습니다.';
        if (mounted) {
          CustomCommonUtil.showErrorSnackbar(
            context: context,
            message: errorMsg,
          );
        }
      }
    } catch (e) {
      String errorMessage = '인증 코드 요청 중 오류가 발생했습니다.';
      if (e.toString().contains('TimeoutException')) {
        errorMessage = '요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = '네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.';
      }

      if (mounted) {
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: errorMessage,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingCode = false;
        });
      }
    }
  }

  /// 인증 코드 검증
  Future<void> _verifyAuthCode() async {
    if (_authToken == null) {
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        message: '먼저 인증 코드를 요청해주세요.',
      );
      return;
    }

    final authCode = _authCodeController.text.trim();
    if (authCode.isEmpty || authCode.length != 6) {
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        message: '6자리 인증 코드를 입력해주세요.',
      );
      return;
    }

    setState(() {
      _isVerifyingCode = true;
    });

    try {
      final apiBaseUrl = getApiBaseUrl();
      final uri = Uri.parse('$apiBaseUrl/api/customer/verify-password-change-code');

      final request = http.MultipartRequest('POST', uri);
      request.fields['customer_seq'] = widget.customerSeq.toString();
      request.fields['auth_token'] = _authToken!;
      request.fields['auth_code'] = authCode;

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && responseData['result'] == 'OK') {
        // 인증 성공 - 2단계로 이동
        setState(() {
          _currentStep = 2;
        });

        if (mounted) {
          CustomCommonUtil.showSuccessSnackbar(
            context: context,
            title: '인증 완료',
            message: '새 비밀번호를 입력해주세요.',
          );
        }
      } else {
        final errorMsg =
            responseData['errorMsg'] ?? '인증 코드가 올바르지 않습니다.';
        if (mounted) {
          CustomCommonUtil.showErrorSnackbar(
            context: context,
            message: errorMsg,
          );
        }
      }
    } catch (e) {
      String errorMessage = '인증 코드 검증 중 오류가 발생했습니다.';
      if (e.toString().contains('TimeoutException')) {
        errorMessage = '요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = '네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.';
      }

      if (mounted) {
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: errorMessage,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingCode = false;
        });
      }
    }
  }

  /// 비밀번호 변경
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_authToken == null) {
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        message: '인증이 완료되지 않았습니다.',
      );
      return;
    }

    final newPassword = _newPasswordController.text.trim();
    final newPasswordConfirm = _newPasswordConfirmController.text.trim();

    if (newPassword != newPasswordConfirm) {
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        message: '비밀번호가 일치하지 않습니다.',
      );
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    try {
      final apiBaseUrl = getApiBaseUrl();
      final uri = Uri.parse('$apiBaseUrl/api/customer/change-password');

      final request = http.MultipartRequest('PUT', uri);
      request.fields['customer_seq'] = widget.customerSeq.toString();
      request.fields['new_password'] = newPassword;
      request.fields['auth_token'] = _authToken!;

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && responseData['result'] == 'OK') {
        if (mounted) {
          CustomCommonUtil.showSuccessDialog(
            context: context,
            title: '비밀번호 변경 완료',
            message: '비밀번호가 성공적으로 변경되었습니다.',
            onConfirm: () {
              Navigator.of(context).pop(true); // 변경 완료 반환
            },
          );
        }
      } else {
        // 422 오류 등 상세 에러 정보 확인
        final errorMsg = responseData['errorMsg'] ?? 
            responseData['detail'] ?? 
            '비밀번호 변경에 실패했습니다. (${response.statusCode})';
        
        // 디버깅을 위한 로그
        print('비밀번호 변경 실패:');
        print('Status Code: ${response.statusCode}');
        print('Response: $responseData');
        
        if (mounted) {
          CustomCommonUtil.showErrorSnackbar(
            context: context,
            message: errorMsg,
          );
        }
      }
    } catch (e) {
      String errorMessage = '비밀번호 변경 중 오류가 발생했습니다.';
      if (e.toString().contains('TimeoutException')) {
        errorMessage = '요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = '네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.';
      }

      if (mounted) {
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: errorMessage,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChangingPassword = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(
          '비밀번호 변경',
          style: mainAppBarTitleStyle.copyWith(color: p.textPrimary),
        ),
        centerTitle: mainAppBarCenterTitle,
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: mainDefaultPadding,
          child: _currentStep == 1 ? _buildStep1(p) : _buildStep2(p),
        ),
      ),
    );
  }

  /// 1단계: 인증 코드 요청 및 입력
  Widget _buildStep1(AppColorScheme p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: mainLargeSpacing,
      children: [
        // 안내 메시지
        Container(
          padding: mainDefaultPadding,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: mainSmallBorderRadius,
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: mainSmallSpacing,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  Text(
                    '이메일 인증',
                    style: mainMediumTextStyle.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              mainSmallVerticalSpacing,
              Text(
                '${widget.customerEmail}로 인증 코드가 발송됩니다.',
                style: mainSmallTextStyle.copyWith(
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),

        // 인증 코드 요청 버튼
        CustomButton(
          btnText: _isRequestingCode
              ? '인증 코드 발송 중...'
              : '인증 코드 발송',
          onCallBack: _isRequestingCode ? null : _requestAuthCode,
          buttonType: ButtonType.elevated,
        ),

        // 인증 코드 입력 필드
        if (_authToken != null) ...[
          CustomTextField(
            controller: _authCodeController,
            labelText: '인증 코드',
            hintText: '6자리 숫자를 입력하세요',
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '인증 코드를 입력해주세요';
              }
              if (value.length != 6) {
                return '6자리 숫자를 입력해주세요';
              }
              return null;
            },
          ),

          // 만료 시간 표시
          if (_expiresAt != null)
            Text(
              '만료 시간: ${_expiresAt!.toString().substring(11, 16)}',
              style: mainSmallTextStyle.copyWith(color: p.textSecondary),
              textAlign: TextAlign.center,
            ),

          // 인증 코드 검증 버튼
          CustomButton(
            btnText: _isVerifyingCode ? '인증 중...' : '인증 확인',
            onCallBack: _isVerifyingCode ? null : _verifyAuthCode,
            buttonType: ButtonType.elevated,
          ),
        ],
      ],
    );
  }

  /// 2단계: 새 비밀번호 입력
  Widget _buildStep2(AppColorScheme p) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: mainLargeSpacing,
        children: [
          // 안내 메시지
          Container(
            padding: mainDefaultPadding,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: mainSmallBorderRadius,
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              spacing: mainSmallSpacing,
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                Expanded(
                  child: Text(
                    '인증이 완료되었습니다. 새 비밀번호를 입력해주세요.',
                    style: mainSmallTextStyle.copyWith(
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 새 비밀번호 입력 필드
          CustomTextField(
            controller: _newPasswordController,
            labelText: '새 비밀번호',
            hintText: '새 비밀번호를 입력하세요',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력해주세요';
              }
              if (value.length < 6) {
                return '비밀번호는 최소 6자 이상이어야 합니다';
              }
              return null;
            },
          ),

          // 비밀번호 확인 입력 필드
          CustomTextField(
            controller: _newPasswordConfirmController,
            labelText: '비밀번호 확인',
            hintText: '비밀번호를 다시 입력하세요',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호 확인을 입력해주세요';
              }
              if (value != _newPasswordController.text.trim()) {
                return '비밀번호가 일치하지 않습니다';
              }
              return null;
            },
          ),

          // 비밀번호 변경 버튼
          CustomButton(
            btnText: _isChangingPassword ? '변경 중...' : '비밀번호 변경',
            onCallBack: _isChangingPassword ? null : _changePassword,
            buttonType: ButtonType.elevated,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-15
// 작성자: 김택권
// 설명: 비밀번호 변경 화면 - 이메일 인증 코드를 통한 비밀번호 변경 기능
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-15 김택권: 초기 생성
//   - 2단계 비밀번호 변경 프로세스 구현
//     - 1단계: 인증 코드 요청 및 입력 (/api/customer/request-password-change)
//     - 2단계: 인증 코드 검증 및 새 비밀번호 입력
//   - 인증 코드 검증 API 연동 (/api/customer/verify-password-change-code)
//   - 비밀번호 변경 API 연동 (/api/customer/change-password)
//   - 인증 코드 만료 시간 표시 (10분)
//   - 비밀번호 일치 검증 로직 구현
//   - 에러 처리 및 로딩 상태 관리
//   - 422 에러 상세 로깅 추가 (디버깅용)
//
// 2026-01-15 김택권: UI 일관성 개선
//   - 하드코딩된 UI 값을 ui_config.dart의 상수로 변경
//   - mainDefaultPadding, mainSmallBorderRadius, mainSmallSpacing, mainSmallVerticalSpacing 상수 사용