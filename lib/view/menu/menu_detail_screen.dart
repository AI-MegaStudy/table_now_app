import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/custom_common_util.dart';
import 'package:table_now_app/vm/menu_notifier.dart';
import 'package:table_now_app/vm/option_notifier.dart';
import 'package:table_now_app/vm/order_state_notifier.dart';

class MenuDetailScreen extends ConsumerStatefulWidget {
  const MenuDetailScreen({super.key, required this.menu_seq});
  final int menu_seq;

  @override
  ConsumerState<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends ConsumerState<MenuDetailScreen> {

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final menuAsync = ref.watch(menuNotifierProvider);
    final optionAsync = ref.watch(optionNotifierProvider);
    final orderState = ref.watch(orderNotifierProvider);


    final menuTotalPrice = menuAsync.maybeWhen(
      data: (menu) {
        final count = orderState.menus[widget.menu_seq]?.count ?? 1;
        return menu[widget.menu_seq].menu_price * count;
      },
      orElse: () => 0,
    );

    final optionTotalPrice = optionAsync.maybeWhen(
      data: (options) {
        int total = 0;
        for (final o in options) {
          final menuCount = orderState.menus[widget.menu_seq]?.count ?? 1;
          final optionCount =
              orderState.menus[widget.menu_seq]?.options[o.option_seq] ?? 0;
          total += o.option_price * optionCount * menuCount;
        }
        return total;
      },
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        centerTitle: mainAppBarCenterTitle,
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: menuAsync.when(
              data: (menu) {
                final menuCount = orderState.menus[widget.menu_seq]?.count ?? 1;
                return menu.isEmpty
                    ? const Center(child: Text('점검 중'))
                    : Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Image.network(
                                'https://cheng80.myqnapcloud.com/tablenow/${menu[widget.menu_seq].menu_image}',
                              ),
                            ),
                            Text(menu[widget.menu_seq].menu_name),
                            Text(menu[widget.menu_seq].menu_description),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  CustomCommonUtil.formatCurrency(
                                    menuCount == 0
                                        ? menu[widget.menu_seq].menu_price
                                        : menu[widget.menu_seq].menu_price *
                                              menuCount,
                                  ),
                                ),
                                cartButton(
                                  '+',
                                  () => ref
                                      .read(orderNotifierProvider.notifier)
                                      .addOrIncrementMenu(widget.menu_seq),
                                ),
                                Text('$menuCount'),
                                cartButton(
                                  '-',
                                  () => ref
                                      .read(orderNotifierProvider.notifier)
                                      .decrementMenu(widget.menu_seq),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
              },
              error: (error, stackTrace) =>
                  Center(child: Text('Error: $error')),
              loading: () => Center(child: CircularProgressIndicator()),
            ),
          ),
          Expanded(
            flex: 3,
            child: optionAsync.when(
              data: (options) {
                return options.isEmpty
                    ? const Center(child: Text('점검 중'))
                    : ListView.builder(
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final o = options[index];
                          final optionCount =
                              orderState.menus[widget.menu_seq]?.options[o
                                  .option_seq] ??
                              0;
                          return Card(
                            color: p.background,
                            shadowColor: Colors.transparent,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        o.option_name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      CustomCommonUtil.formatCurrency(
                                        optionCount == 0
                                            ? o.option_price
                                            : o.option_price * optionCount,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    cartButton(
                                      '+',
                                      () => ref
                                          .read(orderNotifierProvider.notifier)
                                          .incrementOption(
                                            widget.menu_seq,
                                            o.option_seq,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    SizedBox(
                                      width: 24,
                                      child: Center(
                                        child: Text('$optionCount'),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    cartButton(
                                      '-',
                                      () => ref
                                          .read(orderNotifierProvider.notifier)
                                          .decrementOption(
                                            widget.menu_seq,
                                            o.option_seq,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
              },
              error: (error, stackTrace) =>
                  Center(child: Text('Error: $error')),
              loading: () => Center(child: CircularProgressIndicator()),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '${CustomCommonUtil.formatCurrency(menuTotalPrice + optionTotalPrice)} · 담기',
            ), // 추후 가격 표시 예정
          ),
        ],
      ),
    );
  } // build

  // ---- widgets ----
  Widget cartButton(String text, VoidCallback onpressed) {
    return ElevatedButton(onPressed: onpressed, child: Text(text));
  }

  // ---- functions ----
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-16
// 작성자: 임소연
// 설명: 사용자가 특정 메뉴의 옵션 사항을 선택하는 페이지
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-16 임소연: 초기 생성
// 2026-01-19 임소연: +, - 버튼 클릭 시 전체 가격 자동으로 계산
// 2026-01-20 임소연: 메뉴, 옵션 state 하나의 provider에 저장하여 적용
