import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/view/auth/login_tab.dart';

import '../../../custom/custom_drawer.dart';
import '../../../custom/custom_text.dart';
import '../../../vm/auth_notifier.dart';
import '../../../core/global_storage.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.customer;

    return CustomDrawer(
      header: _buildHeader(user),
      items: [
        DrawerItem(
          label: '예약 내역',
          icon: Icons.receipt_long,
          onTap: () {
            // TODO: 예약 내역 화면 이동
          },
        ),
        DrawerItem(
          label: '회원 정보 수정',
          icon: Icons.edit,
          onTap: () {
            // TODO: 프로필 수정 화면 이동
          },
        ),
        DrawerItem(
          label: '로그아웃',
          icon: Icons.logout,
          onTap: () => _handleLogout(context, ref),
        ),
      ],
    );
  }

  /// 로그아웃 처리
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    // 로그아웃 실행
    ref.read(authNotifierProvider.notifier).logout();

    // 저장소 초기화
    final storage = GlobalStorage.instance;
    storage.clear();

    // 로그인 화면으로 이동
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginTab()),
        (_) => false,
      );
    }
  }

  /// 드로어 헤더 빌드
  Widget _buildHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 30,
            child: Icon(Icons.person),
          ),
          const SizedBox(height: 12),
          CustomText(
            user?.name ?? 'Guest',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 4),
          CustomText(
            user?.email ?? '',
            fontSize: 14,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}