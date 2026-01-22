import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/custom/util/navigation/custom_navigation_util.dart';
import 'package:table_now_app/utils/common_app_bar.dart';
import 'package:table_now_app/view/drawer/profile_drawer.dart';
import 'package:table_now_app/view/menu/menu_detail_screen.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/custom_common_util.dart';
import 'package:table_now_app/view/menu/reservation_complete_screen.dart';
import 'package:table_now_app/vm/menu_notifier.dart';
import 'package:table_now_app/vm/order_state_notifier.dart';

class MenuListScreen extends ConsumerStatefulWidget {
  const MenuListScreen({super.key});

  @override
  ConsumerState<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends ConsumerState<MenuListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int store_seq = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = CustomNavigationUtil.arguments<Map<String, dynamic>>(context);
      if (args != null) {
        store_seq = args['store_seq'] as int;
      }

      ref.read(menuNotifierProvider.notifier).fetchMenu(store_seq);
    });
    
  }

  @override
  Widget build(BuildContext context) {

    final p = context.palette;
    final menuAsync = ref.watch(menuNotifierProvider);
    final orderState = ref.watch(orderNotifierProvider);

    int totalPrice = 0;
    orderState.menus.forEach((menuSeq, menu) {
      totalPrice += menu.count * menu.price;
      menu.options.forEach((optionSeq, option) {
        totalPrice += option.count * option.price * menu.count;
      });
    });

    return Scaffold(
      key: _scaffoldKey, //<<<<< 스캐폴드 키 지정
      backgroundColor: p.background,
      drawer: const ProfileDrawer(),
      appBar: CommonAppBar(
        title: Text(
          '메뉴 선택',
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
          _buildStepIndicator(),
          Expanded(
            child: menuAsync.when(
              data: (menus) {
                return menus.isEmpty
                    ? Center(
                        child: Text(
                          '등록된 메뉴가 없습니다.',
                          style: mainBodyTextStyle.copyWith(color: p.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: menus.length,
                        itemBuilder: (context, index) {
                          final m = menus[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MenuDetailScreen(menu: m, index: index),
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: p.cardBackground,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: p.divider),
                                boxShadow: [
                                  BoxShadow(
                                    color: p.textSecondary.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      'https://cheng80.myqnapcloud.com/tablenow/${m.menu_image}',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.fill,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: p.divider),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m.menu_name,
                                          style: mainTitleStyle.copyWith(
                                            color: p.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          CustomCommonUtil.formatCurrency(
                                              m.menu_price),
                                          style: mainBodyTextStyle.copyWith(
                                            color: p.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: p.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
              },
              error: (error, stackTrace) =>
                  Center(
                    child: Text(
                      'Error: $error',
                      style: mainBodyTextStyle.copyWith(color: Colors.red),
                    ),
                  ),
              loading: () => Center(
                child: CircularProgressIndicator(color: p.primary),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: mainButtonHeight,
              child: ElevatedButton(
                onPressed: () {
                  if (totalPrice == 0) {
                    CustomCommonUtil.showErrorSnackbar(
                      context: context,
                      message: '메뉴를 선택해주세요.',
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ReservationCompleteScreen(price: totalPrice)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: totalPrice == 0 ? p.divider : p.primary,
                  foregroundColor: totalPrice == 0 ? p.textSecondary : p.textOnPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  totalPrice == 0
                      ? '메뉴를 선택하세요'
                      : '${CustomCommonUtil.formatCurrency(totalPrice)} · 예약 진행하기',
                  style: mainMediumTitleStyle.copyWith(
                    color: totalPrice == 0 ? p.textSecondary : p.textOnPrimary,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  } // build
  // 상단 스텝 바 (숫자 아이콘)
  Widget _buildStepIndicator() {
    final p = context.palette;
    final labels = ['정보', '좌석', '메뉴', '확인'];
    final currentStep = 2; // 메뉴 선택 단계

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
  
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-19
// 작성자: 임소연
// 설명: Menu List Screen
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-19 임소연: 초기 생성
// 2026-01-19 임소연: 디자인 수정, 공용앱바 추가