import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/custom_common_util.dart';
import 'package:table_now_app/vm/menu_notifier.dart';
import 'package:table_now_app/vm/option_notifier.dart';
import 'package:table_now_app/vm/option_select_notifier.dart';

class MenuDetailScreen extends ConsumerStatefulWidget {
  const MenuDetailScreen({super.key, required this.menu_seq});
  final int menu_seq;

  @override
  ConsumerState<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends ConsumerState<MenuDetailScreen> {
  // final box = GetStorage();
  int menuQuantity = 1;
  int optionQuantity = 0;
  int optionQuantity2 = 0;
  int optionQuantity3 = 0;

  @override
  void initState() {
    super.initState();
    // initStorage();
  }

  // void initStorage(){ // key, value
  //   box.write('p_userid', '');
  //   box.write('p_password', '');
  // }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final menuAsync = ref.watch(menuNotifierProvider);
    final optionAsync = ref.watch(optionNotifierProvider);
    int totalPrice = 0;

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
            flex: 2,
            child: menuAsync.when(
              data: (menu) {
                return menu.isEmpty
                ? const Center(child: Text('점검 중'),)
                : Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center, 
                        child: Image.network(
                          'https://cheng80.myqnapcloud.com/tablenow/${menu[widget.menu_seq].menu_image}'
                        )
                      ),
                      Text(menu[widget.menu_seq].menu_name),
                      Text(menu[widget.menu_seq].menu_description),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(CustomCommonUtil.formatCurrency(menu[widget.menu_seq].menu_price)),
                          // cartButton('+', ref.read(optionSelectProvider.notifier).increment),
                          ElevatedButton(
                            onPressed: () {
                              //
                            },
                            child: Text('+')
                          ),
                          ElevatedButton(
                            onPressed: () {
                              //
                            },
                            child: Text('-')
                          ),
                          // cartButton('-', ref.read(optionSelectProvider.notifier).decrement),
                        ],
                      ),
                    ],
                  ),
                );
              }, 
              error: (error, stackTrace) => Center(child: Text('Error: $error')),
              loading: () => Center(child: CircularProgressIndicator(),)
            ),
          ),
          Expanded(
            flex: 1,
            child: optionAsync.when(
              data: (options) {
                return options.isEmpty
                ? const Center(child: Text('점검 중'),)
                : ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final o = options[index];
                    final count = ref.watch(optionSelectProvider).counts[o.option_seq] ?? 0;
                    return Card(
                      color: p.background,
                      shadowColor: Colors.transparent,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(o.option_name, maxLines: 1, overflow: TextOverflow.ellipsis,),
                              ),
                              const SizedBox(width: 8),
                              Text(CustomCommonUtil.formatCurrency(count == 0 ? o.option_price : o.option_price * count,)),
                              const SizedBox(width: 8),
                              cartButton(
                                '+',
                                () => ref.read(optionSelectProvider.notifier).increment(o.option_seq),
                              ),
                              const SizedBox(width: 4),
                              SizedBox(
                                width: 24,
                                child: Center(child: Text('$count')),
                              ),
                              const SizedBox(width: 4),
                              cartButton(
                                '-',
                                () => ref.read(optionSelectProvider.notifier).decrement(o.option_seq),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                );
              }, 
              error: (error, stackTrace) => Center(child: Text('Error: $error')),
              loading: () => Center(child: CircularProgressIndicator())
            ),
          ),
          ElevatedButton(
            onPressed: () {
              //
            }, 
            child: Text('담기') // 추후 가격 표시 예정
          )
        ],
      )
    );
  } // build

  // ---- widgets ----
  Widget cartButton(String text, VoidCallback onpressed){
    return ElevatedButton(
      onPressed: onpressed,
      child: Text(text)
    );
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
// 2026-01-19 임소연: +, - 