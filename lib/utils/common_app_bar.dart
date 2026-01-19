import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/custom/custom_app_bar.dart';
import 'package:table_now_app/config/ui_config.dart';

/// 공통 AppBar
///
/// 앱 전체에서 사용하는 표준 AppBar입니다.
/// 전용 스타일과 기능이 포함되어 있습니다.
///
/// 사용 예시:
/// ```dart
/// Scaffold(
///   appBar: CommonAppBar(
///     title: '홈',
///     actions: [
///       IconButton(icon: Icon(Icons.search), onPressed: () {}),
///     ],
///   ),
///   body: YourContent(),
/// )
/// ```
class CommonAppBar extends CustomAppBar {
  /// 공통 AppBar 생성자
  ///
  /// [title]: AppBar 제목 (필수)
  /// [actions]: 오른쪽 액션 버튼들
  /// [showBackButton]: 뒤로가기 버튼 표시 여부 (기본값: true)
  /// [customLeading]: 커스텀 leading 위젯 (showBackButton보다 우선)
  /// [onBackPressed]: 뒤로가기 버튼 클릭 시 콜백 (기본 동작: Navigator.pop)
  CommonAppBar({
    super.key,
    required super.title,
    List<Widget>? actions,
    bool showBackButton = true,
    Widget? customLeading,
    VoidCallback? onBackPressed,
    // 전용 기능들을 여기에 추가할 수 있습니다
    // 예: bool showSearchButton = false,
    //     bool showNotificationBadge = false,
  }) : super(
          // 전용 스타일 적용
          backgroundColor: null, // 테마에서 자동으로 가져옴
          foregroundColor: null, // 테마에서 자동으로 가져옴
          centerTitle: mainAppBarCenterTitle,
          titleTextStyle: mainAppBarTitleStyle,
          leading: customLeading ??
              (showBackButton
                  ? _buildBackButton(onBackPressed)
                  : null),
          actions: actions,
          automaticallyImplyLeading: false, // 커스텀 leading 사용
        );

  /// 뒤로가기 버튼 빌드
  static Widget? _buildBackButton(VoidCallback? onBackPressed) {
    return Builder(
      builder: (context) {
        if (!Navigator.canPop(context)) {
          return const SizedBox.shrink(); // 뒤로 갈 수 없으면 빈 위젯 반환
        }

        return IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        );
      },
    );
  }
}

/// Riverpod을 사용하는 공통 AppBar
///
/// 상태 관리가 필요한 경우 사용합니다.
/// 예: 알림 배지, 사용자 프로필 등
class CommonAppBarConsumer extends ConsumerWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Widget? customLeading;
  final VoidCallback? onBackPressed;

  const CommonAppBarConsumer({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.customLeading,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 여기서 ref를 사용하여 상태를 읽을 수 있습니다
    // 예: final notificationCount = ref.watch(notificationCountProvider);
    //     final p = context.palette;

    return CommonAppBar(
      title: title,
      actions: actions,
      showBackButton: showBackButton,
      customLeading: customLeading,
      onBackPressed: onBackPressed,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
