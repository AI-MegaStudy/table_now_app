import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/custom/custom_button.dart';
import 'package:table_now_app/custom/custom_text_field.dart';
import 'package:table_now_app/theme/app_colors.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: 로그인 로직 구현
      // - 이메일/비밀번호 검증
      // - API 호출
      // - 로그인 성공 시 화면 전환
    }
  }

  void _handleSocialLogin(String provider) {
    // TODO: 소셜 로그인 로직 구현
    // - Google Sign-In 등
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

              // 로그인 버튼
              CustomButton(
                btnText: '로그인',
                onCallBack: _handleLogin,
                buttonType: ButtonType.elevated,
              ),

              // 구분선 (소셜 로그인과 구분)
              Row(
                children: [
                  Expanded(child: Divider(color: p.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '또는',
                      style: mainSmallTextStyle.copyWith(color: p.textSecondary),
                    ),
                  ),
                  Expanded(child: Divider(color: p.divider)),
                ],
              ),

              // 소셜 로그인 버튼
              CustomButton(
                btnText: 'Google로 로그인',
                onCallBack: () => _handleSocialLogin('google'),
                buttonType: ButtonType.outlined,
                // TODO: 소셜 로그인 버튼 스타일 적용 필요
              ),
            ],
          ),
        ),
      ),
    );
  }
}
