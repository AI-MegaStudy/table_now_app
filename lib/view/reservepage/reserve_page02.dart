import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/custom/util/navigation/custom_navigation_util.dart';
import 'package:table_now_app/model/store_table.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/common_app_bar.dart';
import 'package:table_now_app/utils/custom_common_util.dart';
import 'package:table_now_app/view/drawer/profile_drawer.dart';
import 'package:table_now_app/view/menu/menu_list_screen.dart';
import 'package:table_now_app/vm/reserve_page02_notifier.dart';

class ReservePage02 extends ConsumerStatefulWidget {
  const ReservePage02({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReservePage02State();
  }

class _ReservePage02State extends ConsumerState<ReservePage02>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = true;

  int store_seq = 1;
  String selectedDay = "";
  String selectedTime = "";
  int reserve_capacity = 0;
  Map tablesData = {};

  final box = GetStorage();

  @override
  void initState() {
    super.initState();

    // build 끝난 뒤 안전하게 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          CustomNavigationUtil.arguments<Map<String, dynamic>>(context);

      if (args != null) {
        store_seq = args['store_seq'] as int;

        final selectedDateTime = args['selectedDate'] as DateTime;
        selectedDay = selectedDateTime.toString().substring(0, 10);
        selectedTime = args['selectedTime'] as String;

        tablesData = args['tablesData'] as Map;

        reserve_capacity = int.parse(args['reserve_capacity'] as String);

        final notifier =
            ref.read(reservePage02NotifierProvider.notifier);

        notifier.fetchData(store_seq);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reserveAsync = ref.watch(reservePage02NotifierProvider);
    final reserveValue = ref.read(reservePage02NotifierProvider.notifier);
    final p = context.palette;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: p.background,
      drawer: const ProfileDrawer(),
      appBar: CommonAppBar(
        title: Text(
          '테이블 선택',
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
      body: reserveAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: p.primary)),
        error: (e, _) => Center(
          child: Text(
            e.toString(),
            style: mainBodyTextStyle.copyWith(color: Colors.red),
          ),
        ),
        data: (state) {
          if (selectedDay == "" || selectedTime == "") {
            return Center(
              child: Text(
                '날짜와 시간을 선택해주세요',
                style: mainBodyTextStyle.copyWith(color: p.textSecondary),
              ),
            );
          }

          final dateKey = selectedDay.substring(0, 10);
          final timeKey = selectedTime;

          // 예약된 테이블 맵
          final Map<String, dynamic> reservedTables = tablesData[dateKey]?[timeKey] ?? {};

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// STEP INDICATOR
                _buildStepIndicator(p, currentStep: 1),

                Expanded(
                  child: GridView.builder(
                    itemCount: state.tableModelList.length, // 매장 테이블 수
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5, // 최대 15개 → 5 x 3
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                  
                      //평범한 테이블들
                      final StoreTable tableInfo = state.tableModelList[index];
                      final String tableName = "T${tableInfo.store_table_name}";
                      final int capacity = tableInfo.store_table_capacity;
                  
                      final int tableSeq = tableInfo.store_table_seq;
                      final bool isReserved = reservedTables.containsKey(tableSeq.toString());
                      bool isSelected = false;
                      if(state.selectedTable != null){
                        isSelected = state.selectedTable!.contains(tableInfo.store_table_seq.toString());
                      }
                      // //예약된 테이블들
                      // final bool isReserved =
                      //     reservedTables.containsKey(tableSeq);
                  
                      // final tableInfo = reservedTables[tableSeq];
                      // final String tableName =
                      //     tableInfo != null ? tableInfo[0] : 'T$tableSeq';
                      // final int capacity =
                      //     tableInfo != null ? int.parse(tableInfo[1]) : 4;
                  
                      return TableItem(
                        name: tableName,
                        capacity: capacity,
                        isReserved: isReserved,
                        isSelected: isSelected,
                        onTap: () {
                          final int left = reserve_capacity - state.usedCapacity!;

                          // 선택하려는데 인원 부족하면 차단
                          if (!isSelected && left <= 0) {
                            CustomCommonUtil.showErrorSnackbar(
                              context: context,
                              message: '선택 가능한 인원을 초과했습니다.',
                            );
                            return;
                          }

                          final List<String> selectedTableList = List<String>.from(state.selectedTable ?? []);
                          
                          //눌러서 테이블 토글 (인원 차감)
                          if (!isSelected) {
                            selectedTableList.add(tableSeq.toString());
                            reserveValue.updateUsedCapacity(capacity);
                          } else {
                            selectedTableList.remove(tableSeq.toString());
                            reserveValue.updateUsedCapacity(-capacity);
                          }

                          reserveValue.selectTable(selectedTableList);
                        },
                        onReservedTap: () {
                          CustomCommonUtil.showErrorSnackbar(
                            context: context,
                            message: '이미 예약된 테이블입니다.',
                          );
                        },
                      );
                    },
                  ),
                ),
                /// NEXT BUTTON
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: mainButtonHeight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.primary,
                        foregroundColor: p.textOnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // 유효성 검사
                        if (state.selectedTable == null || state.selectedTable!.isEmpty) {
                          CustomCommonUtil.showErrorSnackbar(
                            context: context,
                            message: '테이블을 선택해주세요.',
                          );
                          return;
                        }
                        
                        //스토리지에 예약 정보 저장
                        final reserve = {
                          'reserve_tables' : state.selectedTable!.join(','),
                        };
                        box.write('reserve2', reserve);
                        //다음 페이지로
                        CustomNavigationUtil.to(
                          context,
                          MenuListScreen()
                        );
                      },
                      child: Text(
                        '다음',
                        style: mainMediumTitleStyle.copyWith(
                          color: p.textOnPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  //-----Widgets------
  
  /// Step Indicator 위젯
  Widget _buildStepIndicator(dynamic p, {required int currentStep}) {
    final labels = ['정보', '좌석', '메뉴', '확인'];
    
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

/// ------------------------------
/// 테이블 하나 UI
/// ------------------------------
class TableItem extends StatelessWidget {
  final String name;
  final int capacity;
  final bool isReserved;
  final bool isSelected;
  final VoidCallback onTap;
  /// 예약된 테이블 클릭 시 호출되는 콜백 (피드백 제공용)
  final VoidCallback? onReservedTap;

  const TableItem({
    super.key,
    required this.name,
    required this.capacity,
    required this.isReserved,
    required this.isSelected,
    required this.onTap,
    this.onReservedTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final double size = 48 + (capacity * 6); // 인원수 → 크기

    return GestureDetector(
      onTap: isReserved ? onReservedTap : onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isReserved 
              ? p.divider 
              : isSelected 
                  ? p.primary 
                  : Colors.green,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: p.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: mainSmallTitleStyle.copyWith(
                color: isReserved ? Colors.grey.shade600 : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isReserved ? '예약됨' : '$capacity인',
              style: mainSmallTextStyle.copyWith(
                color: isReserved ? Colors.grey.shade600 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}