import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/vm/menu_notifier.dart';

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


    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        centerTitle: mainAppBarCenterTitle,
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
      ),
      body: menuAsync.when(
        data: (menus) {
          return menus.isEmpty
          ? const Center(child: Text('점검 중'),)
          : Center(
            child: Column(
              children: [
                Image.network('https://cheng80.myqnapcloud.com/tablenow/${menus[widget.menu_seq].menu_image}')
              ],
            ),
          );
        }, 
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        loading: () => Center(child: CircularProgressIndicator(),)
      )
      
      
      
      
      

    );
  }
}