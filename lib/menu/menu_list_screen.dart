import 'package:flutter/material.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/theme/palette_context.dart';

class MenuListScreen extends StatefulWidget {
  const MenuListScreen({super.key});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
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