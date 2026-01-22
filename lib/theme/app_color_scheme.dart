import 'package:flutter/material.dart';
import 'common_color_scheme.dart';
import 'table_now_color_scheme.dart';

/// 앱 전체 컬러 스키마 (조합 클래스)
///
/// CommonColorScheme과 TableNowColorScheme을 조합하여
/// 전체 앱에서 사용할 수 있는 통합 컬러 스키마를 제공합니다.
///
/// TableNowColorScheme이 있으면 우선 사용하고, 없으면 CommonColorScheme을 사용합니다.
class AppColorScheme {
  // 공용 컬러 스키마
  final CommonColorScheme common;
  
  // TableNow 앱 전용 컬러 스키마 (선택사항)
  final TableNowColorScheme? tableNow;

  const AppColorScheme({
    required this.common,
    this.tableNow,
  });

  // ============================================================================
  // 공용 컬러 접근자 (기존 코드 호환성)
  // TableNowColorScheme이 있으면 우선 사용, 없으면 CommonColorScheme 사용
  // ============================================================================

  // 전체 배경 색
  Color get background => tableNow?.background ?? common.background;

  // 카드/패널 배경 색
  Color get cardBackground => tableNow?.cardBackground ?? common.cardBackground;

  // 주요 포인트 색
  Color get primary => tableNow?.primary ?? common.primary;

  // 보조 포인트 색
  Color get accent => tableNow?.accent ?? common.accent;

  // 기본 텍스트 색
  Color get textPrimary => tableNow?.textPrimary ?? common.textPrimary;

  // 보조 텍스트 색
  Color get textSecondary => tableNow?.textSecondary ?? common.textSecondary;

  // 구분선 색
  Color get divider => tableNow?.divider ?? common.divider;

  // 필터 칩 선택 배경 색
  Color get chipSelectedBg => tableNow?.chipSelectedBg ?? common.chipSelectedBg;

  // 필터 칩 선택 텍스트 색
  Color get chipSelectedText => tableNow?.chipSelectedText ?? common.chipSelectedText;

  // 필터 칩 비선택 배경 색
  Color get chipUnselectedBg => tableNow?.chipUnselectedBg ?? common.chipUnselectedBg;

  // 필터 칩 비선택 텍스트 색
  Color get chipUnselectedText => tableNow?.chipUnselectedText ?? common.chipUnselectedText;

  // Primary 색상 배경에 사용할 텍스트 색 (반전색, 기본: 흰색)
  Color get textOnPrimary => tableNow?.textOnPrimary ?? common.textOnPrimary;

  // 스텝 인디케이터 활성/완료 색상 (초록색 계열)
  Color get stepActive => tableNow?.stepActive ?? common.stepActive;

  // 스텝 인디케이터 비활성 색상
  Color get stepInactive => tableNow?.stepInactive ?? common.stepInactive;

  // ============================================================================
  // TableNow 앱 전용 컬러 접근자
  // ============================================================================
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-15
// 작성자: 김택권
// 설명: 앱 전체 컬러 스키마 조합 클래스 - CommonColorScheme과 TableNowColorScheme 통합
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-15 김택권: 초기 생성
//   - CommonColorScheme과 TableNowColorScheme을 조합하는 AppColorScheme 클래스 생성
//   - TableNowColorScheme이 있으면 우선 사용, 없으면 CommonColorScheme 사용하는 로직 구현
//   - 기존 코드 호환성을 위한 모든 컬러 접근자 getter 구현
