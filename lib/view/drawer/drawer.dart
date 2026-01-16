// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:table_now_app/view/auth/login_tab.dart';

// import '../../../custom/custom_drawer.dart';
// import '../../../custom/custom_text.dart';
// import '../../../vm/auth_notifier.dart';
// import '../../../core/global_storage.dart';

// class AppDrawer extends ConsumerWidget {
//   const AppDrawer({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(authNotifierProvider).customer;
//     final reservation = ref.watch(reservationProvider);

//     return CustomDrawer(
//       header: _buildTopHeader(user),
//       items: [
//         DrawerItem(label: _buildMyInfoSection(user)),
//         DrawerItem(label: _buildReservationSection(reservation)),
//         DrawerItem(label: _buildLogoutButton(context, ref)),
//       ],
//     );
//   }

//   // =========================
//   // 상단 프로필
//   // =========================
//   Widget _buildTopHeader(dynamic user) {
//     return Container(
//       height: 200,
//       padding: const EdgeInsets.all(20),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFFFF8A00), Color(0xFFFF6A00)],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const CircleAvatar(
//             radius: 36,
//             backgroundColor: Colors.white,
//             child: Icon(Icons.person, size: 32, color: Colors.orange),
//           ),
//           const SizedBox(height: 12),
//           CustomText(
//             user?.customerName ?? 'Guest',
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ],
//       ),
//     );
//   }

//   // =========================
//   // 내 정보
//   // =========================
//   Widget _buildMyInfoSection(dynamic user) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _sectionHeader(title: '내 정보', actionText: '수정'),
//         _infoCard(children: [
//           _infoRow(Icons.person, user?.customerName ?? ''),
//           _infoRow(Icons.email, user?.customerEmail ?? ''),
//         ]),
//       ],
//     );
//   }

//   // =========================
//   // 예약 내역
//   // =========================
//   Widget _buildReservationSection(Reservation? reservation) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _sectionHeader(title: '예약 내역'),
//         reservation == null
//             ? _infoCard(
//                 children: const [
//                   CustomText('예약 내역이 없습니다'),
//                 ],
//               )
//             : _infoCard(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       CustomText(reservation.storeName,
//                           fontWeight: FontWeight.bold),
//                       _statusBadge('예약중'),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   CustomText(
//                       '예약번호: ${reservation.reservationNumber}'),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(Icons.calendar_today, size: 16),
//                       const SizedBox(width: 6),
//                       CustomText(
//                         '${reservation.dateTime.month}월 '
//                         '${reservation.dateTime.day}일 '
//                         '${reservation.dateTime.hour}:00',
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//       ],
//     );
//   }

//   // =========================
//   // 로그아웃
//   // =========================
//   Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: OutlinedButton.icon(
//         onPressed: () {
//           ref.read(authNotifierProvider.notifier).logout();
//           ref.read(reservationProvider.notifier).clear();
//           GlobalStorage.instance.clear();

//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (_) => const LoginTab()),
//             (_) => false,
//           );
//         },
//         icon: const Icon(Icons.logout, color: Colors.red),
//         label: const Text('로그아웃',
//             style: TextStyle(color: Colors.red)),
//       ),
//     );
//   }

//   // =========================
//   // 공통 UI
//   // =========================
//   Widget _sectionHeader({required String title, String? actionText}) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           CustomText(title,
//               fontSize: 16, fontWeight: FontWeight.bold),
//           if (actionText != null)
//             CustomText(actionText, color: Colors.orange),
//         ],
//       ),
//     );
//   }

//   Widget _infoCard({required List<Widget> children}) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Column(children: children),
//     );
//   }

//   Widget _infoRow(IconData icon, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: Colors.grey),
//           const SizedBox(width: 8),
//           Expanded(child: CustomText(value)),
//         ],
//       ),
//     );
//   }

//   Widget _statusBadge(String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.green.shade100,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: CustomText(text, fontSize: 12, color: Colors.green),
//     );
//   }
// }
