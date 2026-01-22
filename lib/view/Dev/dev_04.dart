// dev_04.dart (작업자: 임소연)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/view/menu/menu_list_screen.dart';
import '../../config/ui_config.dart';
import '../../theme/app_colors.dart';

class Dev_04 extends ConsumerStatefulWidget {
  const Dev_04({super.key});

  @override
  ConsumerState<Dev_04> createState() => _Dev_04State();
}

class _Dev_04State extends ConsumerState<Dev_04> {
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
              '임소연 페이지',
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
                  Center(
                    child: SizedBox(
                      width: mainButtonMaxWidth,
                      height: mainButtonHeight,
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuListScreen(),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: p.divider),
                        ),
                        child: Text(
                          'Menu',
                          style: mainMediumTitleStyle.copyWith(
                            color: p.textPrimary,
                          ),
                        ),
                      ),
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
