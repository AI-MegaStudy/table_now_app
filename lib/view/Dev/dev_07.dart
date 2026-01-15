// dev_07.dart (작업자: 프로젝트 관리자)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/ui_config.dart';
import '../../theme/app_colors.dart';
import '../../custom/util/navigation/custom_navigation_util.dart';
import '../auth/auth_screen.dart';

class Dev_07 extends ConsumerStatefulWidget {
  const Dev_07({super.key});

  @override
  ConsumerState<Dev_07> createState() => _Dev_07State();
}

class _Dev_07State extends ConsumerState<Dev_07> {
  // Property
  // late는 초기화를 나중으로 미룸

  @override
  void initState() {
    // 페이지가 새로 생성될 때 무조건 1번 사용됨
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final p = context.palette;
        return Scaffold(
          backgroundColor: p.background,
          appBar: AppBar(
            title: Text(
              '프로젝트 관리자 페이지',
              style: mainAppBarTitleStyle.copyWith(color: p.textPrimary),
            ),
            centerTitle: mainAppBarCenterTitle,
            backgroundColor: p.background,
            foregroundColor: p.textPrimary,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: mainDefaultPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: mainLargeSpacing,
                children: [
                  // 인증 관련 페이지
                  Text(
                    '인증 관련',
                    style: mainTitleStyle.copyWith(color: p.textPrimary),
                  ),
                  Center(
                    child: SizedBox(
                      width: mainButtonMaxWidth,
                      height: mainButtonHeight,
                      child: ElevatedButton(
                        onPressed: () => _navigateToAuthScreen(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: p.primary,
                          foregroundColor: p.textOnPrimary,
                        ),
                        child: Text(
                          '로그인/회원가입 화면',
                          style: mainMediumTitleStyle.copyWith(color: p.textOnPrimary),
                        ),
                      ),
                    ),
                  ),
                  
                  // 여기에 추가 페이지 연결 버튼 추가 가능
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //--------Functions ------------

  /// 로그인/회원가입 화면으로 이동
  void _navigateToAuthScreen() async {
    await CustomNavigationUtil.to(context, const AuthScreen());
  }

  //------------------------------
}
