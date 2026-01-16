import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/view/auth/login_tab.dart';

import '../../../custom/custom_drawer.dart';
import '../../../custom/custom_text.dart';
import '../../../vm/auth_notifier.dart';
import '../../../core/global_storage.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  bool isEditing = false;

  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).customer;

    nameController = TextEditingController(text: user?.customerName ?? '');
    emailController = TextEditingController(text: user?.customerEmail ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.customer;

    return CustomDrawer(
      header: _buildEditableHeader(user),
      items: [
        DrawerItem(
          label: '예약 내역',
          icon: Icons.receipt_long,
          onTap: () {
            // TODO: 예약 내역 화면 이동
          },
        ),
        DrawerItem(
          label: isEditing ? '수정 취소' : '회원 정보 수정',
          icon: isEditing ? Icons.close : Icons.edit,
          onTap: () {
            setState(() {
              isEditing = !isEditing;
            });
          },
        ),
        DrawerItem(
          label: '로그아웃',
          icon: Icons.logout,
          onTap: () async {
            ref.read(authNotifierProvider.notifier).logout();
            GlobalStorage.instance.clear();

            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginTab()),
                (_) => false,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildEditableHeader(dynamic user) {
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

          /// 이름
          isEditing
              ? TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    isDense: true,
                  ),
                )
              : CustomText(
                  user?.customerName ?? 'Guest',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),

          const SizedBox(height: 8),

          /// 이메일
          isEditing
              ? TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    isDense: true,
                  ),
                )
              : CustomText(
                  user?.customerEmail ?? '',
                  fontSize: 14,
                  color: Colors.grey,
                ),

          const SizedBox(height: 12),

          /// 저장 버튼
          if (isEditing)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await ref
                      .read(authNotifierProvider.notifier)
                      .updateProfile(
                        name: nameController.text,
                        email: emailController.text,
                      );

                  setState(() {
                    isEditing = false;
                  });
                },
                child: const Text('저장'),
              ),
            ),
        ],
      ),
    );
  }
}
