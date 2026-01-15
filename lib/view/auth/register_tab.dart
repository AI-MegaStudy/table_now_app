import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/custom/custom_button.dart';
import 'package:table_now_app/custom/custom_text_field.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: 회원가입 로직 구현
      // - 입력값 검증
      // - API 호출
      // - 회원가입 성공 시 로그인 화면으로 전환 또는 자동 로그인
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

              // 전화번호 입력 필드
              CustomTextField(
                controller: _phoneController,
                labelText: '전화번호',
                hintText: '전화번호를 입력하세요',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '전화번호를 입력해주세요';
                  }
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
                btnText: '회원가입',
                onCallBack: _handleRegister,
                buttonType: ButtonType.elevated,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
