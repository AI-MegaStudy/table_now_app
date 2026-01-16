// dev_02.dart (작업자: 이예은)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/custom/util/navigation/custom_navigation_util.dart';
import 'package:table_now_app/view/map/region_list_screen.dart';
import '../../config/ui_config.dart';
import '../../theme/app_colors.dart';

class Dev_02 extends ConsumerStatefulWidget {
  const Dev_02({super.key});

  @override
  ConsumerState<Dev_02> createState() => _Dev_02State();
}

class _Dev_02State extends ConsumerState<Dev_02> {
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
              '이예은 페이지',
              style: mainAppBarTitleStyle.copyWith(
                color: p.textPrimary,
              ),
            ),
            centerTitle: mainAppBarCenterTitle,
            backgroundColor: p.background,
            foregroundColor: p.textPrimary,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: mainDefaultPadding,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                spacing: mainLargeSpacing,
                children: [
                  // 여기에 컨텐츠 추가
                  Center(
                    child: SizedBox(
                      width: mainButtonMaxWidth,
                      height: mainButtonHeight,
                      child: ElevatedButton(
                        onPressed: () => _navigateToMap(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: p.primary,
                          foregroundColor: p.textOnPrimary,
                        ),
                        child: Text(
                          'map',
                          style: mainMediumTitleStyle
                              .copyWith(
                                color: p.textOnPrimary,
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
  void _navigateToMap() async {
    await CustomNavigationUtil.to(
      context,
      RegionListScreen(),
    );
  }

  //------------------------------
}
