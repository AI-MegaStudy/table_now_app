import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_now_app/custom/custom_common_util.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/vm/menu_notifier.dart';
import 'package:table_now_app/vm/order_state_notifier.dart';

class ReservationCompleteScreen extends ConsumerStatefulWidget {
  const ReservationCompleteScreen({super.key, required this.price});
  final int price;

  @override
  ConsumerState<ReservationCompleteScreen> createState() => _ReservationCompleteScreenState();
}

class _ReservationCompleteScreenState extends ConsumerState<ReservationCompleteScreen> {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final menuAsync = ref.watch(menuNotifierProvider);
    final orderState = ref.watch(orderNotifierProvider);
    final menus = orderState.menus;
    
    final box = GetStorage();
    final reserveData = box.read('reserve') ?? {};
    
    // 날짜 포맷팅 가공 (예: 2026년 1월 20일 (화))
    String rawDate = reserveData['reserve_date'] ?? '2026-01-01';
    List<String> dateParts = rawDate.split('T')[0].split('-');
    String formattedDate = "${dateParts[0]}년 ${dateParts[1]}월 ${dateParts[2]}일";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // 연한 회색 배경
      appBar: AppBar(
        title: const Text('잠실점', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.person_outline), onPressed: () {})],
      ),
      body: Column(
        children: [
          // 1. 단계 표시기 (Step Indicator)
          _buildStepIndicator(),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('예약 상세 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 20),
                    
                    // 상세 정보 항목들
                    _buildInfoRow(Icons.calendar_today_outlined, '날짜', '$formattedDate'),
                    _buildInfoRow(Icons.access_time, '시간', '${reserveData['reserve_time'] ?? '11:30'}'),
                    _buildInfoRow(Icons.people_outline, '인원', '${reserveData['reserve_capacity'] ?? '2'}명'),
                    _buildInfoRow(Icons.location_on_outlined, '좌석', '${reserveData['reserve_seat'] ?? 'T4'}'),
                    
                    // 메뉴 섹션
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.restaurant_menu, color: Colors.green, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('메뉴', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              const SizedBox(height: 8),
                              _buildMenuList(menuAsync, menus),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    
                    // 총 결제 금액
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('총 결제 금액', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(CustomCommonUtil.formatCurrency(widget.price), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 하단 결제 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('결제하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 상단 스텝 바 (숫자 아이콘)
  Widget _buildStepIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stepCircle("1", "정보", isCompleted: true),
          _stepLine(),
          _stepCircle("2", "메뉴", isCompleted: true),
          _stepLine(),
          _stepCircle("3", "좌석", isCompleted: true),
          _stepLine(),
          _stepCircle("4", "확인", isCurrent: true),
        ],
      ),
    );
  }

  Widget _stepCircle(String num, String label, {bool isCompleted = false, bool isCurrent = false}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isCurrent ? Colors.green : (isCompleted ? Colors.green : Colors.grey.shade300),
          child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: isCurrent || isCompleted ? Colors.green : Colors.grey)),
      ],
    );
  }

  Widget _stepLine() => Container(width: 40, height: 1, color: Colors.green);

  // 정보 한 줄 (아이콘 + 제목 + 내용)
  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Text(content, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  // 선택한 메뉴 리스트 가젯
  Widget _buildMenuList(AsyncValue<List<dynamic>> menuAsync, Map<int, dynamic> orderMenus) {
    final allMenus = menuAsync.maybeWhen(data: (d) => d, orElse: () => []);
    
    return Column(
      children: orderMenus.entries.map((entry) {
        final menu = allMenus.cast<dynamic>().firstWhere((m) => m.menu_seq == entry.key, orElse: () => null);
        if (menu == null) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(menu.menu_name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('수량: ${entry.value.count}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        );
      }).toList(),
    );
  }
}