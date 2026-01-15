import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_now_app/config.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/custom/custom_tab_bar.dart';
import 'package:table_now_app/theme/app_colors.dart';
import 'package:table_now_app/view/auth/login_tab.dart';
import 'package:table_now_app/view/auth/register_tab.dart';

/// 인증 화면 (로그인/회원가입 탭)
///
/// 탭 기반 UI로 로그인과 회원가입을 하나의 화면에서 처리합니다.
/// 각 탭은 별도의 위젯으로 분리되어 있어 팀원들이 독립적으로 작업할 수 있습니다.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  @override
  void initState() {
    super.initState();
    // 로그인 화면 진입 시 기존 사용자 정보 삭제 (새로운 로그인을 위함)
    final storage = GetStorage();
    storage.remove(storageKeyCustomer);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 여백 (선택사항)
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),

            // 탭 바와 탭 뷰
            Expanded(
              child: CustomTabBar(
                tabs: const ['로그인', '회원가입'],
                // 탭 스타일 커스터마이징
                tabColor: p.primary,
                unselectedTabColor: p.textSecondary,
                indicatorColor: p.primary,
                indicatorHeight: 3.0,
                labelStyle: mainMediumTitleStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: mainMediumTitleStyle.copyWith(
                  fontWeight: FontWeight.normal,
                ),
                children: const [LoginTab(), RegisterTab()],
              ),
            ),
          ],
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
// 설명: 인증 화면 (로그인/회원가입 탭) - 탭 기반 UI로 로그인과 회원가입을 하나의 화면에서 처리
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-15 김택권: 초기 생성
//   - CustomTabBar를 사용한 탭 기반 인증 화면 구현
//   - LoginTab과 RegisterTab 위젯 통합
//   - initState에서 GetStorage의 'customer' 키 삭제하여 새로운 로그인을 위한 초기화 처리
//
// 2026-01-15 김택권: GetStorage 키 상수화
//   - 'customer' 문자열을 config.dart의 storageKeyCustomer 상수로 변경
//   - 오타 방지 및 일관성 유지
