import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/custom_common_util.dart';
import 'package:table_now_app/vm/menu_notifier.dart';
import 'package:table_now_app/vm/option_notifier.dart';

class MenuDetailScreen extends ConsumerStatefulWidget {
  const MenuDetailScreen({super.key, required this.menu_seq});
  final int menu_seq;

  @override
  ConsumerState<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends ConsumerState<MenuDetailScreen> {
  final box = GetStorage();

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
                    children: [
                      Image.network('https://cheng80.myqnapcloud.com/tablenow/${menu[widget.menu_seq].menu_image}'),
                      Text(menu[widget.menu_seq].menu_name),
                      Text(menu[widget.menu_seq].menu_description),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(CustomCommonUtil.formatCurrency(menu[widget.menu_seq].menu_price)),
                          cartButton('+', addToCart),
                          cartButton('-', removeFromCart),
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
                    return Card(
                      color: p.background,
                      shadowColor: Colors.transparent,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(o.option_name,),
                              Text(CustomCommonUtil.formatCurrency(o.option_price)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                );
              }, 
              error: (error, stackTrace) => Center(child: Text('Error: $error')),
              loading: () => Center(child: CircularProgressIndicator(),)
            ),
          ),
          ElevatedButton(
            onPressed: () => {
              //
            }, 
            child: Text('담기') // 추후 가격 표시 예정
          )
        ],
      )
    );
  } // build

  // ---- widgets ----
  Widget cartButton(String text, VoidCallback function){
    return ElevatedButton(
      onPressed: () => function,
      child: Text(text)
    );
  }
  
  // ---- functions ----
  void addToCart(){
    
  }
  void removeFromCart(){
    
  }
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
// 2026-01-19 임소연: +, - 버튼 추가