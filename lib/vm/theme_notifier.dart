import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

/// 테마 모드 상태를 관리하는 Notifier
///
/// 사용 예시:
/// ```dart
/// final themeNotifier = ref.read(themeNotifierProvider.notifier);
/// themeNotifier.toggleTheme();
/// ```
class ThemeNotifier extends Notifier<ThemeMode> {
  static const String _storageKey = 'theme_mode';
  final GetStorage _storage = GetStorage();

  @override
  ThemeMode build() {
    // 초기화 시 저장된 테마 모드 불러오기
    final savedTheme = _storage.read<String>(_storageKey);
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
        default:
          return ThemeMode.system;
      }
    }
    // 기본값: 시스템 설정 따르기
    return ThemeMode.system;
  }

  /// 테마 모드 변경
  void setThemeMode(ThemeMode mode) {
    state = mode;
    _saveThemeMode(mode);
  }

  /// 테마 토글 (라이트 ↔ 다크)
  /// 시스템 모드인 경우 라이트 모드로 변경
  void toggleTheme() {
    final currentMode = state;
    ThemeMode newMode;

    if (currentMode == ThemeMode.light) {
      newMode = ThemeMode.dark;
    } else if (currentMode == ThemeMode.dark) {
      newMode = ThemeMode.light;
    } else {
      // 시스템 모드인 경우 현재 시스템 설정 확인
      // 여기서는 간단히 라이트 모드로 변경
      newMode = ThemeMode.light;
    }

    setThemeMode(newMode);
  }

  /// 테마 모드를 로컬 스토리지에 저장
  void _saveThemeMode(ThemeMode mode) {
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    _storage.write(_storageKey, modeString);
  }

  /// 현재 다크 모드인지 확인
  bool isDarkMode(BuildContext context) {
    final currentMode = state;
    if (currentMode == ThemeMode.dark) return true;
    if (currentMode == ThemeMode.light) return false;
    // 시스템 모드인 경우 시스템 설정 확인
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }
}

/// 테마 Notifier Provider
final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
