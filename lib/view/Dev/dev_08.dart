// dev_08.dart (----)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/utils/common_app_bar.dart';
import 'package:table_now_app/view/drawer/drawer.dart';
import 'package:table_now_app/view/drawer/profile_drawer.dart';

import '../../config/ui_config.dart';
import '../../theme/app_colors.dart';

class Dev_08 extends ConsumerStatefulWidget {
  const Dev_08({super.key});

  @override
  ConsumerState<Dev_08> createState() => _Dev_05State();
}

class _Dev_05State extends ConsumerState<Dev_08> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); //<<<< 드로워 호출용 글로벌키
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
          key: _scaffoldKey, //<<<<< 스캐폴드 키 지정
          backgroundColor: p.background,
          drawer: const AppDrawer(), //<<<<< 프로필 드로워 세팅
          // drawer: const ProfileDrawer(), 
          appBar: CommonAppBar(
            title: Text(
              '공용앱바 & 드로워',
              style: mainAppBarTitleStyle.copyWith(color: p.textPrimary),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.account_circle,
                  color: p.textOnPrimary,
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ],
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
                      '공용앱바 & 드로워 테스트',
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
