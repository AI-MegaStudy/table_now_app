library;

import 'package:flutter/material.dart';

//-----------------------------------------------------
//  UI Constants
//
// ⚠️ 색상은 context.palette를 사용하세요.
// 하드코딩된 색상 대신 테마 시스템을 활용하세요.

// ============================================
// AppBar 설정
// ============================================

/// AppBar 제목 텍스트 스타일
///
/// 색상은 copyWith(color: ...)로 테마에 맞게 설정해야 함
const TextStyle mainAppBarTitleStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

/// AppBar 중앙 정렬 여부 (기본값: true)
const bool mainAppBarCenterTitle = true;

// ============================================
// Scaffold 배경색
// ============================================

/// Scaffold 배경색 (기본값: Colors.white)
///
/// ⚠️ 테마를 사용하는 경우 context.palette.background를 사용하세요.
const Color mainScaffoldBackgroundColor = Colors.white;

// ============================================
// 텍스트 스타일
// ============================================

/// 큰 제목 텍스트 스타일
const TextStyle mainLargeTitleStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

/// 제목 텍스트 스타일 (섹션 제목 등)
const TextStyle mainTitleStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

/// 중간 제목 텍스트 스타일
const TextStyle mainMediumTitleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

/// 작은 제목 텍스트 스타일
const TextStyle mainSmallTitleStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
);

/// 본문 텍스트 스타일
const TextStyle mainBodyTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
);

/// 중간 텍스트 스타일
const TextStyle mainMediumTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
);

/// 작은 텍스트 스타일 (부가 정보)
const TextStyle mainSmallTextStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal,
);

// ============================================
// 버튼 스타일
// ============================================

/// 기본 버튼 높이
const double mainButtonHeight = 56.0;

/// 버튼 최대 너비 (적당한 크기로 제한)
const double mainButtonMaxWidth = 400.0;

/// 기본 버튼 패딩
const EdgeInsets mainButtonPadding = EdgeInsets.symmetric(
  horizontal: 24,
  vertical: 16,
);

// ============================================
// 카드 스타일
// ============================================

/// 일반 카드 elevation
const double mainCardElevation = 6.0;

// ============================================
// 간격 및 패딩
// ============================================

/// 기본 간격
const double mainDefaultSpacing = 16.0;

/// 작은 간격
const double mainSmallSpacing = 8.0;

/// 큰 간격
const double mainLargeSpacing = 24.0;

/// 기본 패딩
const EdgeInsets mainDefaultPadding = EdgeInsets.all(16.0);

/// 작은 패딩
const EdgeInsets mainSmallPadding = EdgeInsets.all(8.0);

/// 중간 패딩 (카드 내부 등)
const EdgeInsets mainMediumPadding = EdgeInsets.all(12.0);

/// 매우 작은 패딩
const EdgeInsets mainTinyPadding = EdgeInsets.symmetric(vertical: 2);

/// 기본 SizedBox 높이 (요소 간 수직 간격)
const SizedBox mainDefaultVerticalSpacing = SizedBox(height: 16);

/// 작은 SizedBox 높이 (작은 요소 간 수직 간격)
const SizedBox mainSmallVerticalSpacing = SizedBox(height: 8);

/// 큰 SizedBox 높이 (큰 요소 간 수직 간격)
const SizedBox mainLargeVerticalSpacing = SizedBox(height: 24);

/// 매우 작은 SizedBox 높이
const SizedBox mainTinyVerticalSpacing = SizedBox(height: 2);

// ============================================
// BorderRadius
// ============================================

/// 기본 BorderRadius
const BorderRadius mainDefaultBorderRadius = BorderRadius.all(
  Radius.circular(12),
);

/// 작은 BorderRadius
const BorderRadius mainSmallBorderRadius = BorderRadius.all(Radius.circular(8));

/// 중간 BorderRadius (큰 카드 등)
const BorderRadius mainMediumBorderRadius = BorderRadius.all(
  Radius.circular(16),
);

/// BottomSheet 상단 BorderRadius
const BorderRadius mainBottomSheetTopBorderRadius = BorderRadius.vertical(
  top: Radius.circular(20),
);

// ============================================
// 기타 UI 상수
// ============================================

/// 검색바 borderRadius
const double mainSearchBarBorderRadius = 10.0;
