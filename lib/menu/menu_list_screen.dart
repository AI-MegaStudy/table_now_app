import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/vm/menu_notifier.dart';

class MenuListScreen extends ConsumerStatefulWidget {
  const MenuListScreen({super.key});

  @override
  ConsumerState<MenuListScreen> createState() => _MenuListScreenState();
}



class _MenuListScreenState extends State<MenuListScreen> {
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
      body: Center(
        child: Column(
          children: [

          ],
        ),
      ),
    );
  }
}