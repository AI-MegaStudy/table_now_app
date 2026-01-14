// dev_05.dart (작업자: 정진석)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/ui_config.dart';
import '../../theme/app_colors.dart';

class Dev_05 extends ConsumerStatefulWidget {
  const Dev_05({super.key});

  @override
  ConsumerState<Dev_05> createState() => _Dev_05State();
}

class _Dev_05State extends ConsumerState<Dev_05> {
  // Property
  // late는 초기화를 나중으로 미룸

  @override
  void initState() {
    // 페이지가 새로 생성될 때 무조건 1번 사용됨
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final p = context.palette;
        return Scaffold(
          backgroundColor: p.background,
          appBar: AppBar(
            title: Text(
              '정진석 페이지',
              style: mainAppBarTitleStyle.copyWith(color: p.textPrimary),
            ),
            centerTitle: mainAppBarCenterTitle,
            backgroundColor: p.background,
            foregroundColor: p.textPrimary,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: mainDefaultPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: mainLargeSpacing,
                children: [
                  // 여기에 컨텐츠 추가
                  Center(
                    child: Text(
                      'Hello World!',
                      style: mainMediumTextStyle.copyWith(color: p.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //--------Functions ------------

  //------------------------------
}
