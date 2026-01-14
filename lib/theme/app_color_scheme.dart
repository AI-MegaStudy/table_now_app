import 'package:flutter/material.dart';
import 'common_color_scheme.dart';
import 'table_now_color_scheme.dart';

/// 앱 전체 컬러 스키마 (조합 클래스)
///
/// CommonColorScheme과 ShoesShopColorScheme을 조합하여
/// 전체 앱에서 사용할 수 있는 통합 컬러 스키마를 제공합니다.
///
/// 기존 코드 호환성을 위해 모든 컬러에 대한 getter를 제공합니다.
class AppColorScheme {
  // 공용 컬러 스키마
  final CommonColorScheme common;

  const AppColorScheme({required this.common});

  // ============================================================================
  // 공용 컬러 접근자 (기존 코드 호환성)
  // ============================================================================

  // 전체 배경 색
  Color get background => common.background;

  // 카드/패널 배경 색
  Color get cardBackground => common.cardBackground;

  // 주요 포인트 색
  Color get primary => common.primary;

  // 보조 포인트 색
  Color get accent => common.accent;

  // 기본 텍스트 색
  Color get textPrimary => common.textPrimary;

  // 보조 텍스트 색
  Color get textSecondary => common.textSecondary;

  // 구분선 색
  Color get divider => common.divider;

  // 필터 칩 선택 배경 색
  Color get chipSelectedBg => common.chipSelectedBg;

  // 필터 칩 선택 텍스트 색
  Color get chipSelectedText => common.chipSelectedText;

  // 필터 칩 비선택 배경 색
  Color get chipUnselectedBg => common.chipUnselectedBg;

  // 필터 칩 비선택 텍스트 색
  Color get chipUnselectedText => common.chipUnselectedText;

  // Primary 색상 배경에 사용할 텍스트 색 (반전색, 기본: 흰색)
  Color get textOnPrimary => common.textOnPrimary;

  // ============================================================================
  // TableNow 앱 전용 컬러 접근자
  // ============================================================================
}
