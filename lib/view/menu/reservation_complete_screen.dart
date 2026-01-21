import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/model/menu.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/vm/menu_notifier.dart';
import 'package:table_now_app/vm/option_notifier.dart';
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
    final optionAsync = ref.watch(optionNotifierProvider);
    final menuAsync = ref.watch(menuNotifierProvider);
    final orderState = ref.watch(orderNotifierProvider);

//     final menu = menuAsync.maybeWhen(
//   data: (menus) => menus,
//   orElse: () => [], // 아직 로딩 중이면 빈 리스트
// );

final menus = ref.watch(orderNotifierProvider).menus;


    final box = GetStorage();
    final data = box.read('order'); // Map<String, dynamic>
    print(data);
    
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

Expanded(
  child: ListView(
    children: menus.entries.map((entry) {
      final menu_seq = entry.key;
      final orderMenu = entry.value;

      // AsyncValue에서 List<Menu> 추출
      final allMenus = menuAsync.maybeWhen(
        data: (menus) => menus,
        orElse: () => [],
      );

      // menu_seq에 대응되는 메뉴 찾기 (nullable 변수 사용)
      final menu = allMenus.where((m) => m.menu_seq == menu_seq).toList();
      if (menu.isEmpty) return SizedBox.shrink(); // 없으면 표시 안함

      return Card(
        child: Column(
          children: [
        Text(menu.first.menu_name),
        Text('수량: ${orderMenu.count}'),
        Text('${menu.first.menu_price * orderMenu.count}원')

          ],
        )
      );
    }).toList(),
  ),
),



  // menuAsync.when(
  //   data: (menus) {
  //     return menus.isEmpty
  //     ? Center(child: Text('예약 내역이 없습니다.'),)
  //     : ListView.builder(
  //       itemCount: menus.length,
  //       itemBuilder: (context, index) {
  //         final m = menus[index];
  //         return Card(
            
  //         );
  //       });
  //   }, 
  //             error: (error, stackTrace) => Center(child: Text('Error: $error')),
  //             loading: () => const Center(child: CircularProgressIndicator()),
  // )

  
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