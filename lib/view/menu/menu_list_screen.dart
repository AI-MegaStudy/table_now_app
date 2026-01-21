import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/view/menu/menu_detail_screen.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/custom_common_util.dart';
import 'package:table_now_app/view/menu/reservation_complete_screen.dart';
import 'package:table_now_app/vm/menu_notifier.dart';
import 'package:table_now_app/vm/order_state_notifier.dart';

class MenuListScreen extends ConsumerStatefulWidget {
  const MenuListScreen({super.key});

  @override
  ConsumerState<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends ConsumerState<MenuListScreen> {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final menuAsync = ref.watch(menuNotifierProvider);
    final orderState = ref.watch(orderNotifierProvider);

    int totalPrice = 0;
    orderState.menus.forEach((menuSeq, menu) {
      totalPrice += menu.count * menu.price;
      menu.options.forEach((optionSeq, option) {
        totalPrice += option.count * option.price * menu.count;
      });
    });

    // ref.read(menuNotifierProvider.notifier).fetchMenu(2);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("메뉴 선택", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: mainAppBarCenterTitle,
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: menuAsync.when(
              data: (menus) {
                return menus.isEmpty
                    ? const Center(child: Text('등록된 메뉴가 없습니다.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: menus.length,
                        itemBuilder: (context, index) {
                          final m = menus[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MenuDetailScreen(menu: m, index: index),
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      'https://cheng80.myqnapcloud.com/tablenow/${m.menu_image}',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: Colors.grey[200]),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(m.menu_name,
                                            style: mainTitleStyle),
                                        const SizedBox(height: 4),
                                        Text(
                                          CustomCommonUtil.formatCurrency(
                                              m.menu_price),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios,
                                      size: 16, color: Colors.grey[400]),
                                ],
                              ),
                            ),
                          );
                        },
                      );
              },
              error: (error, stackTrace) =>
                  Center(child: Text('Error: $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                if (totalPrice == 0) {
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ReservationCompleteScreen(price: totalPrice)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: totalPrice == 0 ? Colors.grey : Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                  totalPrice == 0
                      ? '메뉴를 선택하세요'
                      : '${CustomCommonUtil.formatCurrency(totalPrice)} · 예약 진행하기',
                  style: mainTitleStyle),
            ),
          )
        ],
      ),
    );
  }
}