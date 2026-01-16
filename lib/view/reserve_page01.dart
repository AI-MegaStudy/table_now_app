import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:table_now_app/theme/palette_context.dart';

// ----------------------
// Providers (UI state only)
// ----------------------
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);
final selectedTimeProvider = StateProvider<String?>((ref) => null);

// ----------------------
// Entry Widget
// ----------------------
class ReservePage01 extends ConsumerWidget {
  const ReservePage01({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTime = ref.watch(selectedTimeProvider);
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: _ReservationAppBar(),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _StepIndicator(step: 1),
                const SizedBox(height: 16),
                const _StoreCard(),
                const SizedBox(height: 20),
                const _UserInfoCard(),
                const SizedBox(height: 24),
                const _SectionTitle(title: '날짜 선택'),
                const SizedBox(height: 12),
                _CalendarCard(
                  selectedDate: selectedDate,
                  onSelect: (date) =>
                      ref.read(selectedDateProvider.notifier).state = date,
                ),
                const SizedBox(height: 24),
                const _SectionTitle(title: '시간 선택'),
                const SizedBox(height: 12),
                _TimeGrid(
                  selectedTime: selectedTime,
                  onSelect: (time) =>
                      ref.read(selectedTimeProvider.notifier).state = time,
                ),
                const SizedBox(height: 120), // ⭐ 하단 버튼 여백
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: p.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              // 다음 단계 이동
            },
            child: const Text('다음', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

// ----------------------
// AppBar
// ----------------------
class _ReservationAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppBar(
      backgroundColor: p.primary,
      elevation: 0,
      leading: const Icon(Icons.arrow_back),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('이태원점', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('예약 정보', style: TextStyle(fontSize: 12)),
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
        )
      ],
    );
  }
}

// ----------------------
// Step Indicator
// ----------------------
class _StepIndicator extends StatelessWidget {
  final int step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    Widget buildStep(int index, String label) {
      final p = context.palette;
      final isActive = step == index;
      return Column(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isActive ? p.accent : Colors.grey.shade300,
            child: Text('$index', style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildStep(1, '정보'),
        buildStep(2, '메뉴'),
        buildStep(3, '좌석'),
        buildStep(4, '확인'),
      ],
    );
  }
}

// ----------------------
// Store Card
// ----------------------
class _StoreCard extends StatelessWidget {
  const _StoreCard();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Card(
      color: p.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              'https://cheng80.myqnapcloud.com/tablenow/abiko_100h.jpg',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('카레하우스 이태원점', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('서울 용산구 이태원로 지하 200'),
                Text('영업시간: 11:00 - 23:00'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------
// User Info Card
// ----------------------
class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    InputDecoration deco(String hint) => InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        );

    return Card(
      color: p.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('예약자 정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(decoration: deco('이름 *')),
            const SizedBox(height: 10),
            TextField(decoration: deco('연락처 *')),
            const SizedBox(height: 10),
            TextField(decoration: deco('인원 *'), keyboardType: TextInputType.number),
          ],
        ),
      ),
    );
  }
}

// ----------------------
// Section Title
// ----------------------
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }
}

// ----------------------
// Calendar (table_calendar)
// ----------------------
class _CalendarCard extends ConsumerWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onSelect;

  const _CalendarCard({required this.selectedDate, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: selectedDate ?? normalizedToday,

          locale: 'ko_KR',

          // ⭐ 지난 날짜 비활성화
          enabledDayPredicate: (day) {
            return !day.isBefore(normalizedToday);
          },

          selectedDayPredicate: (day) {
            return selectedDate != null && isSameDay(selectedDate, day);
          },

          onDaySelected: (selectedDay, focusedDay) {
            onSelect(selectedDay);
          },

          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
          ),

          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.orange.shade200,
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            disabledTextStyle: TextStyle(color: Colors.grey.shade400),
          ),
        ),
      ),
    );
  }
}

// ----------------------
// Time Grid
// ----------------------
class _TimeGrid extends StatelessWidget {
  final String? selectedTime;
  final ValueChanged<String> onSelect;

  const _TimeGrid({required this.selectedTime, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final times = [
      '11:00','11:30','12:00','12:30','13:00','13:30',
      '17:00','17:30','18:00','18:30','19:00','19:30'
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.4,
      ),
      itemCount: times.length,
      itemBuilder: (context, index) {
        final time = times[index];
        final isSelected = selectedTime == time;
        return GestureDetector(
          onTap: () => onSelect(time),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? p.accent : p.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(time, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
          ),
        );
      },
    );
  }
}
