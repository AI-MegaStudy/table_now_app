import 'package:flutter/material.dart';
import 'current_screen_tracker.dart';

/// 라우트 변경을 감지하여 현재 화면을 자동으로 추적하는 RouteObserver
class ScreenTrackingRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateCurrentScreen(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _updateCurrentScreen(previousRoute);
    } else {
      CurrentScreenTracker.clearCurrentScreen();
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _updateCurrentScreen(newRoute);
    }
  }

  void _updateCurrentScreen(Route<dynamic> route) {
    // 라우트 이름이 있으면 사용
    final routeName = route.settings.name;
    if (routeName != null && routeName.isNotEmpty) {
      CurrentScreenTracker.setCurrentScreen(routeName);
      return;
    }

    // 라우트 이름이 없으면 추적하지 않음
    // CustomNavigationUtil.to()를 사용하면 자동으로 라우트 이름이 설정되므로
    // 일반 Navigator.push()를 사용하는 경우에는 수동으로 CurrentScreenTracker를 사용해야 함
  }
}
