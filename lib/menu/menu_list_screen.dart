import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/menu/menu_detail_screen.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/custom_common_util.dart';
import 'package:table_now_app/vm/menu_notifier.dart';

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

    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        centerTitle: mainAppBarCenterTitle,
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
      ),
      body: menuAsync.when(
        data: (menus) {
          return menus.isEmpty
          ? const Center(child: Text('점검 중'),)
          : ListView.builder(
            itemCount: menus.length,
            itemBuilder: (context, index) {
              final m = menus[index];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MenuDetailScreen(menu_seq: 1,))),
                child: Card(
                              color: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Colors.grey[300]!, // 테두리 색상
                                  width: 1.0,               // 테두리 두께
                                ),
                                borderRadius: BorderRadius.circular(12.0), // 모서리 곡률
                              ),
                  child: Column(
                    children: [
                      Text(m.menu_name,),
                      Text(CustomCommonUtil.formatCurrency(m.menu_price)),
                    ],
                  ),
                ),
              );
            }
          );
        }, 
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        loading: () => Center(child: CircularProgressIndicator(),)
      )
    );
  }
}