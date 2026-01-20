import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:table_now_app/view/auth/auth_screen.dart';

import '../../../custom/custom_text.dart';
import '../../../vm/auth_notifier.dart';
import '../../../utils/customer_storage.dart';
import '../../../theme/app_colors.dart';
import '../../../config.dart';
import '../../../model/reserve.dart';
import '../../../model/store.dart';
import '../auth/profile_edit_screen.dart';
import '../../custom/util/navigation/custom_navigation_util.dart';

/// 프로필 드로워
///
/// 사용자 정보와 예약 내역을 표시하는 사이드 드로워입니다.
class ProfileDrawer extends ConsumerStatefulWidget {
  const ProfileDrawer({super.key});

  @override
  ConsumerState<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends ConsumerState<ProfileDrawer> {
  List<Reserve>? _reserves;
  Map<int, String> _storeNames = {};
  Map<int, int> _reserveCapacities = {}; // reserve_seq -> capacity 매핑
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  // ============================================================
  // 데이터 로딩
  // ============================================================

  /// 예약 내역 불러오기
  Future<void> _loadReservations() async {
    final user = CustomerStorage.getCustomer();
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _reserves = [];
        });
      }
      return;
    }

    try {
      final apiBaseUrl = getApiBaseUrl();
      final response = await http
          .get(Uri.parse('$apiBaseUrl/api/reserve/select_reserves'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final results = data['results'] as List;

        // 현재 사용자의 예약만 필터링
        final userReservesData = results
            .where((r) => r['customer_seq'] == user.customerSeq)
            .toList();
        
        final userReserves = userReservesData
            .map((r) => Reserve.fromJson(r))
            .toList();

        // capacity 정보 저장 (reserve_seq -> capacity)
        final capacitiesMap = <int, int>{};
        for (final r in userReservesData) {
          final reserveSeq = r['reserve_seq'] as int? ?? 0;
          final capacity = r['reserve_capacity'] as int? ?? 0;
          capacitiesMap[reserveSeq] = capacity;
        }

        // 매장 정보 가져오기
        final storeSeqs = userReserves.map((r) => r.store_seq).toSet();
        await _loadStoreNames(storeSeqs.toList());

        if (mounted) {
          setState(() {
            _reserves = userReserves;
            _reserveCapacities = capacitiesMap;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _reserves = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reserves = [];
          _isLoading = false;
        });
      }
    }
  }

  /// 매장 이름 가져오기
  Future<void> _loadStoreNames(List<int> storeSeqs) async {
    if (storeSeqs.isEmpty) return;

    final apiBaseUrl = getApiBaseUrl();
    final storeNamesMap = <int, String>{};

    for (final storeSeq in storeSeqs) {
      try {
        final response = await http
            .get(Uri.parse('$apiBaseUrl/api/store/select_store/$storeSeq'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(utf8.decode(response.bodyBytes));
          final store = Store.fromJson(data['result']);
          
          // 주소를 그대로 저장
          storeNamesMap[storeSeq] = store.store_address;
        } else {
          storeNamesMap[storeSeq] = '매장 $storeSeq';
        }
      } catch (e) {
        storeNamesMap[storeSeq] = '매장 $storeSeq';
      }
    }

    if (mounted) {
      setState(() {
        _storeNames = storeNamesMap;
      });
    }
  }

  // ============================================================
  // UI 빌드
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = CustomerStorage.getCustomer();
    final p = context.palette;

    return Drawer(
      backgroundColor: p.cardBackground,
      child: Column(
        children: [
          _buildTopHeader(context, user, p),
          _buildProfileEditButton(context, ref, p),
          Expanded(child: _buildReservationSection(p)),
          _buildLogoutButton(context, ref, p),
        ],
      ),
    );
  }

  /// 상단 헤더 (사용자 정보)
  Widget _buildTopHeader(BuildContext context, dynamic user, dynamic p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [p.primary, p.primary.withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 닫기 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: p.textOnPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 사용자 정보
            if (user != null) ...[
              if (user.customerName.isNotEmpty)
                CustomText(
                  user.customerName,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: p.textOnPrimary,
                ),
              const SizedBox(height: 8),
              if (user.customerEmail.isNotEmpty)
                CustomText(
                  user.customerEmail,
                  fontSize: 14,
                  color: p.textOnPrimary.withOpacity(0.9),
                ),
              if (user.customerPhone != null && user.customerPhone!.isNotEmpty) ...[
                const SizedBox(height: 4),
                CustomText(
                  user.customerPhone!,
                  fontSize: 14,
                  color: p.textOnPrimary.withOpacity(0.9),
                ),
              ],
            ] else
              CustomText(
                '로그인이 필요합니다',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: p.textOnPrimary,
              ),
          ],
        ),
      ),
    );
  }

  /// 프로필 수정 버튼
  Widget _buildProfileEditButton(BuildContext context, WidgetRef ref, dynamic p) {
    final user = CustomerStorage.getCustomer();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('로그인이 필요합니다.'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }
            CustomNavigationUtil.to(context, const ProfileEditScreen());
          },
          icon: Icon(Icons.edit, color: p.primary),
          label: CustomText(
            '프로필 수정',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: p.primary,
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: p.primary),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  /// 예약 내역 섹션
  Widget _buildReservationSection(dynamic p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: CustomText(
            '예약 내역',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: p.textPrimary,
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: p.primary))
              : _reserves == null || _reserves!.isEmpty
                  ? _buildEmptyState(p)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _reserves!.length,
                      itemBuilder: (context, index) {
                        return _buildReservationCard(_reserves![index], p);
                      },
                    ),
        ),
      ],
    );
  }

  /// 빈 상태 UI
  Widget _buildEmptyState(dynamic p) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: p.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          CustomText(
            '예약 내역이 없습니다',
            fontSize: 14,
            color: p.textSecondary,
          ),
        ],
      ),
    );
  }

  /// 예약 카드
  Widget _buildReservationCard(Reserve reserve, dynamic p) {
    final reserveDate = DateTime.parse(reserve.reserve_date);
    final weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdayNames[reserveDate.weekday - 1];

    final formattedDate =
        '${reserveDate.month}월 ${reserveDate.day}일 ($weekday) '
        '${reserveDate.hour.toString().padLeft(2, '0')}:'
        '${reserveDate.minute.toString().padLeft(2, '0')}';
    // final reservationNumber = 'RES${reserve.reserve_seq}';
    final mm = reserveDate.month.toString().padLeft(2, '0');
    final dd = reserveDate.day.toString().padLeft(2, '0');
    final capacity = _reserveCapacities[reserve.reserve_seq] ?? 0;
    final capacityStr = capacity.toString().padLeft(2, '0');
    final reservationNumber = 'CUR${reserve.reserve_seq}${reserve.store_seq}${reserve.customer_seq}$mm$dd$capacityStr';
    
    final storeName = _storeNames[reserve.store_seq] ?? '매장 ${reserve.store_seq}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.divider),
        color: p.cardBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomText(
                  storeName,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: p.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              _statusBadge('예약중', p),
            ],
          ),
          const SizedBox(height: 12),
          CustomText(
            
            '예약번호: $reservationNumber',
            fontSize: 14,
            color: p.textSecondary,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: p.textSecondary),
              const SizedBox(width: 6),
              CustomText(
                formattedDate,
                fontSize: 14,
                color: p.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 로그아웃 버튼
  Widget _buildLogoutButton(BuildContext context, WidgetRef ref, dynamic p) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.divider)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            if (!mounted) return;
            
            // ref를 먼저 사용하여 notifier 가져오기 (위젯이 unmount되기 전에)
            final authNotifier = ref.read(authNotifierProvider.notifier);
            
            // 드로워를 닫기 전에 Scaffold context 찾기
            final scaffold = Scaffold.maybeOf(context);
            final scaffoldContext = scaffold?.context ?? context;
            
            // 드로워 먼저 닫기
            Navigator.of(context).pop();
            
            // 드로워 애니메이션이 완전히 끝날 때까지 대기 (300ms)
            await Future.delayed(const Duration(milliseconds: 300));
            
            // 로그아웃 처리 (내부에서 GetStorage의 customer 정보 삭제 및 FCM 동기화 상태 초기화)
            await authNotifier.logout();
            
            // 다음 프레임에서 네비게이션 실행
            await Future.delayed(const Duration(milliseconds: 100));
            
              // rootNavigator를 사용하여 네비게이션 (AuthScreen으로 이동 - Scaffold 포함)
              Navigator.of(scaffoldContext, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (_) => false,
              );
          },
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const CustomText(
            '로그아웃',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.red,
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 공통 UI 컴포넌트
  // ============================================================

  /// 상태 배지
  Widget _statusBadge(String text, dynamic p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomText(
        text,
        fontSize: 12,
        color: Colors.green.shade700,
      ),
    );
  }
}
