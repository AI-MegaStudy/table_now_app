import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/vm/order_state_notifier.dart';
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

    final box = GetStorage();
    final data = box.read('order'); // Map<String, dynamic>

final orderState = ref.watch(orderNotifierProvider);

    orderState.menus.forEach((menuSeq, orderMenu) {
  print('메뉴 $menuSeq: ${orderMenu.count}개');
});

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        centerTitle: mainAppBarCenterTitle,
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
      ),
      body: Center(
        child: Column(
          children: [
            // Text('${orderState.menus}'),
          ],
        ),
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