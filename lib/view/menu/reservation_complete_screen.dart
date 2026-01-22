import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/custom/custom_common_util.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/common_app_bar.dart';
import 'package:table_now_app/view/drawer/profile_drawer.dart';
import 'package:table_now_app/view/payment/list_group_view.dart';
import 'package:table_now_app/vm/menu_notifier.dart';
import 'package:table_now_app/vm/order_state_notifier.dart';

class ReservationCompleteScreen extends ConsumerStatefulWidget {
  const ReservationCompleteScreen({super.key, required this.price});
  final int price;

  @override
  ConsumerState<ReservationCompleteScreen> createState() => _ReservationCompleteScreenState();
}

class _ReservationCompleteScreenState extends ConsumerState<ReservationCompleteScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    
    final p = context.palette;
    final menuAsync = ref.watch(menuNotifierProvider);
    final orderState = ref.watch(orderNotifierProvider);
    final menus = orderState.menus;
    
    final box = GetStorage();
    final reserveData = box.read('reserve') ?? {};
    
    // 날짜 포맷팅 가공 (예: 2026년 1월 20일 (화))
    String rawDate = reserveData['reserve_date'] ?? '2026-01-01';
    List<String> dateParts = rawDate.split('T')[0].split('-');
    String formattedDate = "${dateParts[0]}년 ${dateParts[1]}월 ${dateParts[2]}일";

    return Scaffold(
      key: _scaffoldKey, //<<<<< 스캐폴드 키 지정
      backgroundColor: p.background,
      drawer: const ProfileDrawer(),
      appBar: CommonAppBar(
        title: Text(
          '예약 확인',
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
      body: Column(
        children: [
          // 1. 단계 표시기 (Step Indicator)
          _buildStepIndicator(),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: p.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.divider),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '예약 상세 정보',
                      style: mainTitleStyle.copyWith(color: p.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Divider(color: p.divider),
                    const SizedBox(height: 20),
                    
                    // 상세 정보 항목들
                    _buildInfoRow(Icons.calendar_today_outlined, '날짜', formattedDate, p),
                    _buildInfoRow(Icons.access_time, '시간', '${reserveData['reserve_time'] ?? '11:30'}', p),
                    _buildInfoRow(Icons.people_outline, '인원', '${reserveData['reserve_capacity'] ?? '2'}명', p),
                    _buildInfoRow(Icons.location_on_outlined, '좌석', '${box.read('reserve2')['reserve_tables'] ?? 'T4'}', p),
                    
                    // 메뉴 섹션
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.restaurant_menu, color: p.stepActive, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '메뉴',
                                style: mainSmallTextStyle.copyWith(color: p.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              _buildMenuList(menuAsync, menus),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Divider(color: p.divider),
                    
                    // 총 결제 금액
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '총 결제 금액',
                            style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
                          ),
                          Text(
                            CustomCommonUtil.formatCurrency(widget.price),
                            style: mainMediumTitleStyle.copyWith(
                              color: p.stepActive,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 하단 결제 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: mainButtonHeight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PaymentListGroupView(totalPrice: widget.price),
                              ),
                            );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.primary,
                  foregroundColor: p.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  '결제하기',
                  style: mainMediumTitleStyle.copyWith(color: p.textOnPrimary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 상단 스텝 바 (숫자 아이콘)
  Widget _buildStepIndicator() {
    final p = context.palette;
    final labels = ['정보', '좌석', '메뉴', '확인'];
    final currentStep = 3; // 확인 단계

    return Container(
      color: p.cardBackground,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(labels.length, (index) {
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;
          
          return Row(
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isActive || isCompleted 
                        ? p.stepActive 
                        : p.stepInactive,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive || isCompleted 
                            ? Colors.white 
                            : p.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[index],
                    style: mainSmallTextStyle.copyWith(
                      color: isActive ? p.stepActive : p.textSecondary,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              if (index < labels.length - 1)
                Container(
                  width: 30,
                  height: 1,
                  margin: const EdgeInsets.only(bottom: 16),
                  color: isCompleted ? p.stepActive : p.stepInactive,
                ),
            ],
          );
        }),
      ),
    );
  }

  // 정보 한 줄 (아이콘 + 제목 + 내용)
  Widget _buildInfoRow(IconData icon, String title, String content, dynamic p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Row(
        children: [
          Icon(icon, color: p.stepActive, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: mainSmallTextStyle.copyWith(color: p.textSecondary),
              ),
              Text(
                content,
                style: mainBodyTextStyle.copyWith(
                  color: p.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 선택한 메뉴 리스트 가젯
  Widget _buildMenuList(AsyncValue<List<dynamic>> menuAsync, Map<int, dynamic> orderMenus) {
    final allMenus = menuAsync.maybeWhen(data: (d) => d, orElse: () => []);
    final p = context.palette;
    
    return Column(
      children: orderMenus.entries.map((entry) {
        final menu = allMenus.cast<dynamic>().firstWhere((m) => m.menu_seq == entry.key, orElse: () => null);
        if (menu == null) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: p.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: p.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                menu.menu_name,
                style: mainSmallTitleStyle.copyWith(color: p.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                '수량: ${entry.value.count}',
                style: mainSmallTextStyle.copyWith(color: p.textSecondary),
              ),
              Text(
                entry.value.options.isEmpty
                    ? '옵션 없음'
                    : '옵션: ${entry.value.options.values
                            .map((o) => '${o.name} x ${o.count}')
                            .join(', ')}',
                style: mainSmallTextStyle.copyWith(color: p.textSecondary),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-19
// 작성자: 임소연
// 설명: Menu Notifier
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-19 임소연: 초기 생성
// 2026-01-20 임소연: 주문 메뉴 리스트 추가
// 2026-01-21 임소연: 예약 데이터 추가, 디자인 수정, 공용앱바 추가
// 2026-01-22 임소연: 옵션 데이터 추가