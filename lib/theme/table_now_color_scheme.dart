import 'package:flutter/material.dart';

/// TableNow 앱 전용 컬러 스키마
///
/// 커리 전문점 예약 앱에 특화된 노란색/주황색 위주의 컬러를 정의합니다.
class TableNowColorScheme {
  /// 전체 배경 색
  final Color background;

  /// 카드/패널 배경 색
  final Color cardBackground;

  /// 주요 포인트 색 (주황색 - 커리 스파이스)
  final Color primary;

  /// 보조 포인트 색 (노란색 - 골드)
  final Color accent;

  /// 기본 텍스트 색
  final Color textPrimary;

  /// 보조 텍스트 색
  final Color textSecondary;

  /// 구분선 색
  final Color divider;

  /// 필터 칩 선택 배경 색
  final Color chipSelectedBg;

  /// 필터 칩 선택 텍스트 색
  final Color chipSelectedText;

  /// 필터 칩 비선택 배경 색
  final Color chipUnselectedBg;

  /// 필터 칩 비선택 텍스트 색
  final Color chipUnselectedText;

  /// Primary 색상 배경에 사용할 텍스트 색 (반전색)
  final Color textOnPrimary;

  /// 스텝 인디케이터 활성/완료 색상 (초록색 계열)
  final Color stepActive;

  /// 스텝 인디케이터 비활성 색상
  final Color stepInactive;

  const TableNowColorScheme({
    required this.background,
    required this.cardBackground,
    required this.primary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.chipSelectedBg,
    required this.chipSelectedText,
    required this.chipUnselectedBg,
    required this.chipUnselectedText,
    required this.textOnPrimary,
    required this.stepActive,
    required this.stepInactive,
  });
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-15
// 작성자: 김택권
// 설명: TableNow 앱 전용 컬러 스키마 - 커리 전문점 테마 컬러 정의
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-15 김택권: 초기 생성
//   - 커리 전문점 예약 앱에 특화된 노란색/주황색 위주의 컬러 스키마 정의
//   - CommonColorScheme과 분리하여 앱 전용 컬러 관리
//   - 모든 컬러 속성 정의 (background, primary, accent, text 등)
