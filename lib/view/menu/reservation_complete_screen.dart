import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/vm/reservation_notifier.dart';

class ReservationCompleteScreen extends ConsumerStatefulWidget {
  const ReservationCompleteScreen({super.key});

  @override
  ConsumerState<ReservationCompleteScreen> createState() => _ReservationCompleteScreenState();
}

class _ReservationCompleteScreenState extends ConsumerState<ReservationCompleteScreen> {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final reservationAsync = ref.watch(reservationNotifierProvider);

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        centerTitle: mainAppBarCenterTitle,
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
      ),
    );
  }
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-16
// 작성자: 임소연
// 설명: 사용자가 결제 전 예약된 사항을 확인하는 페이지
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-16 임소연: 초기 생성
// 2026-01-19 임소연: 