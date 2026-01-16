import 'package:flutter/material.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/theme/palette_context.dart';

class ReservationCompleteScreen extends StatefulWidget {
  const ReservationCompleteScreen({super.key});

  @override
  State<ReservationCompleteScreen> createState() => _ReservationCompleteScreenState();
}

class _ReservationCompleteScreenState extends State<ReservationCompleteScreen> {
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
      
    );
  }
}