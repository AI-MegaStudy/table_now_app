import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_now_app/custom/util/navigation/custom_navigation_util.dart';
import 'package:table_now_app/model/store_table.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/view/reservepage/reserve_page01.dart';
import 'package:table_now_app/vm/reserve_page02_notifier.dart';

class ReservePage02 extends ConsumerStatefulWidget {
  ReservePage02({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReservePage02State();
  }

class _ReservePage02State extends ConsumerState<ReservePage02>{
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
      appBar: AppBar(title: const Text('테이블 선택')),
      body: reserveAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (state) {
          if (selectedDay == "" || selectedTime == "") {
            return const Center(child: Text('날짜와 시간을 선택해주세요'));
          }

          final dateKey =
              selectedDay!.toString().substring(0, 10);
          final timeKey = selectedTime!;

          // 예약된 테이블 맵
          final Map<String, dynamic> reservedTables = tablesData[dateKey]?[timeKey] ?? {};

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
                          if (!isSelected && left <= 0) return;

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
                        
                      );
                    },
                  ),
                ),
                /// NEXT BUTTON
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      //스토리지에 예약 정보 저장
                      if(state.selectedTable == null || state.selectedTable!.isEmpty){
                        return;
                      }
                      final reserve = {
                        'reserve_tables' : state.selectedTable!.join(','),
                      };
                      box.write('reserve2', reserve);
                      //다음 페이지로
                      CustomNavigationUtil.to(
                        context,
                        ReservePage01(),
                      );
                    },
                    child: Text(
                      '다음',
                      style: TextStyle(
                        fontSize: 16,
                        color: p.textOnPrimary
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

  const TableItem({
    super.key,
    required this.name,
    required this.capacity,
    required this.isReserved,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double size = 48 + (capacity * 6); // 인원수 → 크기

    return GestureDetector(
      onTap: isReserved ? null : onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isReserved ? Colors.grey.shade400 : isSelected ? Colors.orange : Colors.green,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$capacity인',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}