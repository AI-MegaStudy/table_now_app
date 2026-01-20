import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/vm/reserve_page01_notifier.dart';

class ReservePage02 extends ConsumerWidget {
  const ReservePage02({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(reservePage01NotifierProvider);
    final tableCount = 15;

    return Scaffold(
      appBar: AppBar(title: const Text('테이블 선택')),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (state) {
          if (state.selectedDay == null || state.selectedTime == null) {
            return const Center(child: Text('날짜와 시간을 선택해주세요'));
          }

          final dateKey =
              state.selectedDay!.toString().substring(0, 10);
          final timeKey = state.selectedTime!;

          // 예약된 테이블 맵
          final Map<String, dynamic> reservedTables =
              state.tablesData[dateKey]?[timeKey] ?? {};

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: tableCount ?? 0, // 매장 테이블 수
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // 최대 15개 → 5 x 3
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final tableSeq = (index + 1).toString();

                final bool isReserved =
                    reservedTables.containsKey(tableSeq);

                final tableInfo = reservedTables[tableSeq];
                final String tableName =
                    tableInfo != null ? tableInfo[0] : 'T$tableSeq';
                final int capacity =
                    tableInfo != null ? int.parse(tableInfo[1]) : 4;

                return TableItem(
                  name: tableName,
                  capacity: capacity,
                  isReserved: isReserved,
                  onTap: () {
                    if (!isReserved) {
                      print('선택된 테이블: $tableSeq');
                    }
                  },
                );
              },
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
  final VoidCallback onTap;

  const TableItem({
    super.key,
    required this.name,
    required this.capacity,
    required this.isReserved,
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
          color: isReserved ? Colors.grey.shade400 : Colors.orange,
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