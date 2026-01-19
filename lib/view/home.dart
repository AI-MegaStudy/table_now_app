import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/custom/util/navigation/custom_navigation_util.dart';
import 'package:table_now_app/theme/app_colors.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/view/Dev/dev_01.dart';
import 'package:table_now_app/view/Dev/dev_02.dart';
import 'package:table_now_app/view/Dev/dev_03.dart';
import 'package:table_now_app/view/Dev/dev_04.dart';
import 'package:table_now_app/view/Dev/dev_05.dart';
import 'package:table_now_app/view/Dev/dev_06.dart';
import 'package:table_now_app/view/Dev/dev_07.dart';
import 'package:table_now_app/view/Dev/dev_firebase_test.dart';
import 'package:table_now_app/view/auth/auth_screen.dart';
import 'package:table_now_app/view/map/region_list_screen.dart';
import 'package:table_now_app/vm/auth_notifier.dart';
import 'package:table_now_app/vm/theme_notifier.dart';
import 'package:table_now_app/utils/current_screen_tracker.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  final List<Widget> _devPages = [
    const Dev_01(),
    const Dev_02(),
    const Dev_03(),
    const Dev_04(),
    const Dev_05(),
    const Dev_06(),
    const Dev_07(),
  ];

  @override
  void initState() {
    super.initState();
    // 현재 화면 추적
    CurrentScreenTracker.setCurrentScreen('Home');
  }

  @override
  void dispose() {
    // 화면이 사라질 때 추적 해제
    CurrentScreenTracker.clearCurrentScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final p = context.palette;

        // 현재 방식: ThemeNotifier의 메서드 사용 (ThemeMode.system 처리 포함)
        final isDarkMode = ref
            .read(themeNotifierProvider.notifier)
            .isDarkMode(context);

        // 기존 방식 1: 간단한 비교 (ThemeMode.system 미처리)
        // final themeMode = ref.watch(themeNotifierProvider);
        // final isDarkMode = themeMode == ThemeMode.dark;

        // 기존 방식 2: 삼항 연산자 사용 (ThemeMode.system 처리 포함)
        // final themeMode = ref.watch(themeNotifierProvider);
        // final isDarkMode = themeMode == ThemeMode.dark
        //     ? true
        //     : (themeMode == ThemeMode.light
        //         ? false
        //         : MediaQuery.of(context).platformBrightness == Brightness.dark);

        return Scaffold(
          backgroundColor: p.background,
          appBar: AppBar(
            title: Text(
              '홈',
              style: mainAppBarTitleStyle.copyWith(color: p.textPrimary),
            ),
            centerTitle: mainAppBarCenterTitle,
            backgroundColor: p.background,
            foregroundColor: p.textPrimary,
            actions: [
              // 테마 스위치
              Padding(
                padding: EdgeInsets.symmetric(horizontal: mainSmallSpacing),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: mainSmallSpacing,
                  children: [
                    Icon(
                      Icons.light_mode,
                      size: 20,
                      color: isDarkMode ? p.textSecondary : p.primary,
                    ),
                    Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        ref.read(themeNotifierProvider.notifier).toggleTheme();
                      },
                      activeThumbColor: p.primary,
                    ),
                    Icon(
                      Icons.dark_mode,
                      size: 20,
                      color: isDarkMode ? p.primary : p.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: mainDefaultPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: mainLargeSpacing,
                children: [
                  // 개발 페이지 버튼 (항상 표시)
                  ..._buildDevPageButtons(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 개발 페이지 버튼 목록 생성
  List<Widget> _buildDevPageButtons(BuildContext context) {
    final p = context.palette;
    return [
      Center(
        child: SizedBox(
          width: mainButtonMaxWidth,
          height: mainButtonHeight,
          child: OutlinedButton(
            onPressed: () => _navigateToDevPage(0),
            style: OutlinedButton.styleFrom(side: BorderSide(color: p.divider)),
            child: Text(
              '이광태 페이지',
              style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
            ),
          ),
        ),
      ),
      Center(
        child: SizedBox(
          width: mainButtonMaxWidth,
          height: mainButtonHeight,
          child: OutlinedButton(
            onPressed: () => _navigateToDevPage(1),
            style: OutlinedButton.styleFrom(side: BorderSide(color: p.divider)),
            child: Text(
              '이예은 페이지',
              style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
            ),
          ),
        ),
      ),
      Center(
        child: SizedBox(
          width: mainButtonMaxWidth,
          height: mainButtonHeight,
          child: OutlinedButton(
            onPressed: () => _navigateToDevPage(2),
            style: OutlinedButton.styleFrom(side: BorderSide(color: p.divider)),
            child: Text(
              '유다원 페이지',
              style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
            ),
          ),
        ),
      ),
      Center(
        child: SizedBox(
          width: mainButtonMaxWidth,
          height: mainButtonHeight,
          child: OutlinedButton(
            onPressed: () => _navigateToDevPage(3),
            style: OutlinedButton.styleFrom(side: BorderSide(color: p.divider)),
            child: Text(
              '임소연 페이지',
              style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
            ),
          ),
        ),
      ),
      Center(
        child: SizedBox(
          width: mainButtonMaxWidth,
          height: mainButtonHeight,
          child: OutlinedButton(
            onPressed: () => _navigateToDevPage(4),
            style: OutlinedButton.styleFrom(side: BorderSide(color: p.divider)),
            child: Text(
              '정진석 페이지',
              style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
            ),
          ),
        ),
      ),
      Center(
        child: SizedBox(
          width: mainButtonMaxWidth,
          height: mainButtonHeight,
          child: OutlinedButton(
            onPressed: () => _navigateToDevPage(5),
            style: OutlinedButton.styleFrom(side: BorderSide(color: p.divider)),
            child: Text(
              '김택권 페이지',
              style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
            ),
          ),
        ),
      ),
      Center(
        child: SizedBox(
          width: mainButtonMaxWidth,
          height: mainButtonHeight,
          child: OutlinedButton(
            onPressed: () => _navigateToDevPage(6),
            style: OutlinedButton.styleFrom(side: BorderSide(color: p.divider)),
            child: Text(
              '프로젝트 관리자 페이지',
              style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
            ),
          ),
        ),
      ),
      Center(
        child: SizedBox(
          width: mainButtonMaxWidth,
          height: mainButtonHeight,
          child: ElevatedButton(
            onPressed: () => _navigateToFirebaseTest(),
            style: ElevatedButton.styleFrom(
              backgroundColor: p.primary,
              foregroundColor: p.textOnPrimary,
            ),
            child: Text(
              'Firebase 연결 테스트',
              style: mainMediumTitleStyle.copyWith(color: p.textOnPrimary),
            ),
          ),
        ),
      ),
      Center(
        child: SizedBox(
          width: mainButtonMaxWidth,
          height: mainButtonHeight,
          child: ElevatedButton(
            onPressed: () => _navigateToAuthOrMap(),
            style: ElevatedButton.styleFrom(
              backgroundColor: p.primary,
              foregroundColor: p.textOnPrimary,
            ),
            child: Text(
              '첫화면 가기',
              style: mainMediumTitleStyle.copyWith(color: p.textOnPrimary),
            ),
          ),
        ),
      ),
    ];
  }

  //--------Functions ------------

  /// 개발 페이지로 이동
  void _navigateToDevPage(int index) async {
    await CustomNavigationUtil.to(context, _devPages[index]);
  }

  /// Firebase 테스트 페이지로 이동
  void _navigateToFirebaseTest() async {
    await CustomNavigationUtil.to(context, const DevFirebaseTest());
  }

  /// 자동 로그인 여부에 따라 AuthScreen으로 갈지 RegionListScreen으로 결정 하는 함수
  void _navigateToAuthOrMap() async {
    // 현재 로그인 상태 확인
    final authState = ref.read(authNotifierProvider);

    if (authState.isLoggedIn) {
      // 로그인되어 있으면 RegionListScreen으로 이동
      await CustomNavigationUtil.to(context, const RegionListScreen());
    } else {
      // 로그인되어 있지 않으면 AuthScreen으로 이동
      await CustomNavigationUtil.to(context, const AuthScreen());
    }
  }

  //------------------------------
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-15
// 작성자: 김택권
// 설명: 홈 화면 - 개발 페이지 네비게이션 및 테마 스위치 기능
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-15 김택권: 초기 생성
//   - 개발 페이지 버튼 목록 구현
//   - 테마 스위치 기능 구현
//   - Firebase 테스트 페이지 네비게이션 추가
//
// 2026-01-15 김택권: UI 일관성 개선
//   - 하드코딩된 UI 값을 ui_config.dart의 상수로 변경
//   - mainSmallSpacing 상수 사용
