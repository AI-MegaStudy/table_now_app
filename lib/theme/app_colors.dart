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
import 'table_now_color_scheme.dart';

/// 라이트 / 다크 팔레트 정의
///
/// 각 테마 모드에 맞는 CommonColorScheme과 TableNowColorScheme을 조합하여
/// AppColorScheme을 생성합니다.
/// TableNowColorScheme이 있으면 우선 사용하고, 없으면 CommonColorScheme을 사용합니다.
class AppColors {
  const AppColors._();

  /// 라이트 테마 컬러 스키마
  /// CommonColorScheme은 기본값 유지, TableNowColorScheme에 노란색/주황색 테마 적용
  static const AppColorScheme light = AppColorScheme(
    common: CommonColorScheme(
      background: Color(0xFFFAFAFA), // 기본 회색 배경
      cardBackground: Colors.white,
      primary: Color(0xFF212121), // 기본 검은색
      accent: Color(0xFF757575), // 기본 회색
      textPrimary: Color(0xFF212121),
      textSecondary: Color(0xFF757575),
      divider: Color(0xFFE0E0E0),
      chipSelectedBg: Color(0xFF212121),
      chipSelectedText: Colors.white,
      chipUnselectedBg: Color(0xFFF5F5F5),
      chipUnselectedText: Color(0xFF424242),
      textOnPrimary: Colors.white,
      stepActive: Color(0xFF4CAF50), // 기본 초록색
      stepInactive: Color(0xFFE0E0E0), // 기본 회색
    ),
    tableNow: TableNowColorScheme(
      background: Color(0xFFFFF8F0), // 따뜻한 크림색 배경
      cardBackground: Colors.white, // 순수 흰색 카드
      primary: Color(0xFFFF6B35), // 따뜻한 주황색 (커리 스파이스 색상)
      accent: Color(0xFFFFC107), // 밝은 노란색 (커리 골드)
      textPrimary: Color(0xFF2C1810), // 따뜻한 갈색 텍스트
      textSecondary: Color(0xFF6B4E3D), // 중간 갈색 텍스트
      divider: Color(0xFFFFE0B2), // 연한 주황색 구분선
      chipSelectedBg: Color(0xFFFF6B35), // 주황색 배경
      chipSelectedText: Colors.white, // 흰색 텍스트
      chipUnselectedBg: Color(0xFFFFF3E0), // 연한 주황색 배경
      chipUnselectedText: Color(0xFF6B4E3D), // 갈색 텍스트
      textOnPrimary: Colors.white, // Primary 배경에 사용할 흰색 텍스트
      stepActive: Color(0xFF2E7D32), // 진한 초록색 (커리 허브 느낌)
      stepInactive: Color(0xFFE8D5C4), // 연한 베이지 (테마 조화)
    ),
  );

  /// 다크 테마 컬러 스키마
  /// CommonColorScheme은 기본값 유지, TableNowColorScheme에 노란색/주황색 테마 적용
  static const AppColorScheme dark = AppColorScheme(
    common: CommonColorScheme(
      background: Color(0xFF121212), // 기본 다크 배경
      cardBackground: Color(0xFF1E1E1E),
      primary: Color(0xFFE0E0E0), // 기본 밝은 회색
      accent: Color(0xFF9E9E9E), // 기본 회색
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFFB0B0B0),
      divider: Color(0xFF424242),
      chipSelectedBg: Color(0xFF424242),
      chipSelectedText: Colors.white,
      chipUnselectedBg: Color(0xFF2C2C2C),
      chipUnselectedText: Color(0xFFB0B0B0),
      textOnPrimary: Color(0xFF212121),
      stepActive: Color(0xFF81C784), // 밝은 초록색 (다크 모드용)
      stepInactive: Color(0xFF424242), // 다크 회색
    ),
    tableNow: TableNowColorScheme(
      background: Color(0xFF1A1612), // 따뜻한 다크 갈색 배경
      cardBackground: Color(0xFF2C2418), // 약간 밝은 다크 갈색 카드
      primary: Color(0xFFFF8C65), // 밝은 주황색 (다크 모드용)
      accent: Color(0xFFFFD54F), // 밝은 노란색 (다크 모드용)
      textPrimary: Color(0xFFFFF8F0), // 따뜻한 크림색 텍스트
      textSecondary: Color(0xFFD4C4B0), // 밝은 베이지색 텍스트
      divider: Color(0xFF4A3A2A), // 어두운 갈색 구분선
      chipSelectedBg: Color(0xFFFF6B35), // 주황색 배경
      chipSelectedText: Colors.white, // 흰색 텍스트
      chipUnselectedBg: Color(0xFF3A2E20), // 약간 밝은 다크 갈색 배경
      chipUnselectedText: Color(0xFFD4C4B0), // 밝은 베이지색 텍스트
      textOnPrimary: Colors.white, // Primary 배경에 사용할 흰색 텍스트
      stepActive: Color(0xFF66BB6A), // 밝은 초록색 (다크 모드용)
      stepInactive: Color(0xFF4A3A2A), // 다크 갈색
    ),
  );
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-15
// 작성자: 김택권
// 설명: 앱 컬러 시스템 - 라이트/다크 테마 팔레트 정의
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-15 김택권: 초기 생성
//   - 라이트/다크 테마용 AppColorScheme 정의
//   - CommonColorScheme과 TableNowColorScheme 조합
//   - 커리 전문점 테마에 맞는 노란색/주황색 컬러 적용
