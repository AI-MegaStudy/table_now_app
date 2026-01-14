/// 앱 컬러 시스템 - 모든 컬러 관련 클래스와 확장을 export
///
/// 기존 코드 호환성을 위해 이 파일에서 모든 컬러 관련 요소를 export합니다.
///
/// 사용 예시:
/// ```dart
/// import 'package:table_now_app/view/cheng/theme/app_colors.dart';
///
/// final p = context.palette; // AppColorScheme
/// Container(color: p.primary)
/// ```
library;

export 'common_color_scheme.dart';
export 'table_now_color_scheme.dart';
export 'app_color_scheme.dart';
export 'app_theme_mode.dart';
export 'palette_context.dart';

import 'package:flutter/material.dart';
import 'common_color_scheme.dart';
import 'app_color_scheme.dart';

/// 라이트 / 다크 팔레트 정의
///
/// 각 테마 모드에 맞는 CommonColorScheme과 ShoesShopColorScheme을 조합하여
/// AppColorScheme을 생성합니다.
class AppColors {
  const AppColors._();

  /// 라이트 테마 컬러 스키마 (무채색 계열)
  static const AppColorScheme light = AppColorScheme(
    common: CommonColorScheme(
      background: Color(0xFFFAFAFA), // 매우 연한 회색 배경
      cardBackground: Colors.white, // 순수 흰색 카드
      primary: Color(0xFF212121), // 거의 검은색 (무채색)
      accent: Color(0xFF757575), // 중간 회색 (무채색)
      textPrimary: Color(0xFF212121), // 거의 검은색 텍스트
      textSecondary: Color(0xFF757575), // 중간 회색 텍스트
      divider: Color(0xFFE0E0E0), // 연한 회색 구분선
      chipSelectedBg: Color(0xFF212121), // 검은색 배경
      chipSelectedText: Colors.white, // 흰색 텍스트
      chipUnselectedBg: Color(0xFFF5F5F5), // 연한 회색 배경
      chipUnselectedText: Color(0xFF424242), // 어두운 회색 텍스트
      textOnPrimary: Colors.white, // Primary 배경에 사용할 흰색 텍스트
    ),
  );

  /// 다크 테마 컬러 스키마 (무채색 계열)
  static const AppColorScheme dark = AppColorScheme(
    common: CommonColorScheme(
      background: Color(0xFF121212), // Material Dark 배경
      cardBackground: Color(0xFF1E1E1E), // 약간 밝은 다크 카드
      primary: Color(0xFFE0E0E0), // 밝은 회색 (무채색)
      accent: Color(0xFF9E9E9E), // 중간 회색 (무채색)
      textPrimary: Color(0xFFFFFFFF), // 순수 흰색 텍스트
      textSecondary: Color(0xFFB0B0B0), // 밝은 회색 텍스트
      divider: Color(0xFF424242), // 중간 회색 구분선
      chipSelectedBg: Color(0xFF424242), // 중간 회색 배경
      chipSelectedText: Colors.white, // 흰색 텍스트
      chipUnselectedBg: Color(0xFF2C2C2C), // 약간 밝은 다크 배경
      chipUnselectedText: Color(0xFFB0B0B0), // 밝은 회색 텍스트
      textOnPrimary: Color(0xFF212121), // Primary 배경에 사용할 어두운 회색 텍스트
    ),
  );
}
