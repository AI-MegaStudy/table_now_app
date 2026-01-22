import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/model/menu.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/common_app_bar.dart';
import 'package:table_now_app/utils/custom_common_util.dart';
import 'package:table_now_app/view/drawer/profile_drawer.dart';
import 'package:table_now_app/vm/menu_notifier.dart';
import 'package:table_now_app/vm/option_notifier.dart';
import 'package:table_now_app/vm/order_state_notifier.dart';

class MenuDetailScreen extends ConsumerStatefulWidget {
  const MenuDetailScreen({super.key, required this.menu, required this.index});
  final Menu menu;
  final int index;

  @override
  ConsumerState<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends ConsumerState<MenuDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    final p = context.palette;
    final menuAsync = ref.watch(menuNotifierProvider);
    final optionAsync = ref.watch(optionNotifierProvider);
    final orderState = ref.watch(orderNotifierProvider);

    final menuTotalPrice = menuAsync.maybeWhen(
      data: (menu) {
        final count = orderState.menus[widget.menu.menu_seq]?.count ?? 1;
        return menu[widget.index].menu_price * count;
      },
      orElse: () => 0,
    );

    final optionTotalPrice = optionAsync.maybeWhen(
      data: (options) {
        int total = 0;
        for (final o in options) {
          final menuCount = orderState.menus[widget.menu.menu_seq]?.count ?? 1;
          final optionCount = orderState.menus[widget.menu.menu_seq]?.options[o.option_seq]?.count ?? 0;
          total += o.option_price * optionCount * menuCount;
        }
        return total;
      },
      orElse: () => 0,
    );

    return Scaffold(
      key: _scaffoldKey, //<<<<< 스캐폴드 키 지정
      backgroundColor: p.background,
      drawer: const ProfileDrawer(),
      appBar: CommonAppBar(
        title: Text(
          '메뉴 선택',
          style: mainAppBarTitleStyle.copyWith(color: p.textOnPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.account_circle,
              color: p.textOnPrimary,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: menuAsync.maybeWhen(
                data: (menu) => Image.network(
                  'https://cheng80.myqnapcloud.com/tablenow/${menu[widget.index].menu_image}',
                  fit: BoxFit.cover,
                ),
                orElse: () => Container(color: Colors.grey[200]),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: menuAsync.when(
              data: (menu) {
                final menuCount = orderState.menus[widget.menu.menu_seq]?.count ?? 1;
                final m = menu[widget.index];
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.menu_name, style: mainLargeTitleStyle),
                      const SizedBox(height: 8),
                      Text(m.menu_description, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            CustomCommonUtil.formatCurrency(m.menu_price),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          _buildQuantityControl(
                            count: menuCount,
                            onAdd: () => ref.read(orderNotifierProvider.notifier).addOrIncrementMenu(widget.menu.menu_seq, widget.menu.menu_name, m.menu_price),
                            onRemove: () => ref.read(orderNotifierProvider.notifier).decrementMenu(widget.menu.menu_seq),
                          ),
                        ],
                      ),
                      const Divider(height: 40),
                      const Text("추가 옵션", style: mainTitleStyle),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
              error: (e, _) => Center(child: Text('Error: $e')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),

          optionAsync.when(
            data: (options) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final o = options[index];
                  final optionCount = orderState.menus[widget.menu.menu_seq]?.options[o.option_seq]?.count ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(o.option_name, style: mainMediumTextStyle),
                                Text("+ ${CustomCommonUtil.formatCurrency(o.option_price)}",
                                    style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                              ],
                            ),
                          ),
                          _buildQuantityControl(
                            count: optionCount,
                            onAdd: () => ref.read(orderNotifierProvider.notifier).incrementOption(widget.menu.menu_seq, o.option_seq, o.option_name, o.option_price),
                            onRemove: () => ref.read(orderNotifierProvider.notifier).decrementOption(widget.menu.menu_seq, o.option_seq),
                            isSmall: true,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: options.length,
              ),
            ),
            error: (e, _) => const SliverToBoxAdapter(child: SizedBox()),
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: p.background,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: ElevatedButton(
          onPressed: () {
            ref.read(orderNotifierProvider.notifier).confirmMenu(widget.menu.menu_seq);
            Navigator.pop(context, menuTotalPrice + optionTotalPrice);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            '${CustomCommonUtil.formatCurrency(menuTotalPrice + optionTotalPrice)} 담기',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityControl({
    required int count,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
    bool isSmall = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.palette.chipUnselectedBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: context.palette.accent)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _circleButton(Icons.remove, onRemove, isSmall),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('$count', style: TextStyle(fontSize: isSmall ? 14 : 16, fontWeight: FontWeight.bold)),
          ),
          _circleButton(Icons.add, onAdd, isSmall),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onPressed, bool isSmall) {
    return IconButton(
      constraints: BoxConstraints(minWidth: isSmall ? 32 : 40, minHeight: isSmall ? 32 : 40),
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: isSmall ? 18 : 22, color: Colors.black87),
      onPressed: onPressed,
    );
  }
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-19
// 작성자: 임소연
// 설명: Menu Detail Screen
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-19 임소연: 초기 생성
// 2026-01-19 임소연: totalPrice 계산, 추가/제거 버튼 추가
// 2026-01-20 임소연: totalPrice 수정, 디자인 수정
// 2026-01-21 임소연: totalPrice 수정, 공용앱바 추가