// dev_06.dart (작업자: 김택권)
// Google Maps 길찾기 테스트 페이지

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/utils/common_app_bar.dart';
import 'package:table_now_app/view/drawer/profile_drawer.dart';
import 'package:table_now_app/view/map/map_google/destination_input_screen.dart';
import '../../config/ui_config.dart';
import '../../theme/app_colors.dart';

class Dev_06 extends ConsumerStatefulWidget {
  const Dev_06({super.key});

  @override
  ConsumerState<Dev_06> createState() => _Dev_06State();
}

class _Dev_06State extends ConsumerState<Dev_06> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); //<<<< 드로워 호출용 글로벌키

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final p = context.palette;
        return Scaffold(
          key: _scaffoldKey, //<<<<< 스캐폴드 키 지정
          backgroundColor: p.background,
          // drawer: const AppDrawer(), 
          drawer: const ProfileDrawer(), //<<<<< 프로필 드로워 세팅
          appBar: CommonAppBar(
            title: Text(
              '김택권 - Google Maps 길찾기',
              style: mainAppBarTitleStyle.copyWith(color: p.textOnPrimary),
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
          body: Center(
            child: Padding(
              padding: mainDefaultPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.map,
                    size: 80,
                    color: p.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Google Maps 길찾기 테스트',
                    textAlign: TextAlign.center,
                    style: mainLargeTitleStyle.copyWith(color: p.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '목적지 좌표를 입력하여 경로를 찾을 수 있습니다.',
                    textAlign: TextAlign.center,
                    style: mainBodyTextStyle.copyWith(color: p.textSecondary),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DestinationInputScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions, size: 24),
                    label: const Text(
                      '목적지 입력하기',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.primary,
                      foregroundColor: p.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 20),
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

}
