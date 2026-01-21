import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:table_now_app/custom/util/navigation/custom_navigation_util.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/view/reservepage/reserve_page02.dart';
import 'package:table_now_app/vm/reserve_page01_notifier.dart';

class ReservePage01 extends ConsumerStatefulWidget {
  const ReservePage01({super.key,});

  @override
  ConsumerState<ReservePage01> createState() => _ReservePage01State();
}

class _ReservePage01State extends ConsumerState<ReservePage01> {

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController numberController;

  late bool loading;
  int store_seq = 2;
  int customer_seq = 1;
  String date = DateTime.now().toString();

  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    loading = true;
    nameController = TextEditingController();
    phoneController = TextEditingController();
    numberController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reserveAsync = ref.watch(reservePage01NotifierProvider);
    final reserveValue = ref.read(reservePage01NotifierProvider.notifier);
    if(loading == true) reserveValue.fetchData(store_seq, customer_seq, date);
    loading = false;
    final p = context.palette;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: p.primary,
        elevation: 0,
        leading: const BackButton(),
        title: const Text('예약 정보'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.person),
          ),
        ],
      ),
      body: reserveAsync.when(
        data: (data){
          Store store = data.store;
          List<String> times = data.times;
          nameController.text = data.name;
          phoneController.text = data.phone;
          return Column(
            children: [
              /// STEP INDICATOR
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(4, (index) {
                    final isActive = index == 0;
                    final labels = ['정보', '좌석', '메뉴', '확인'];

                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              isActive ? p.primary : Colors.grey.shade300,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          labels[index],
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive ? p.primary : Colors.grey,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// STORE CARD
                      Card(
                        elevation: 0,
                        color: p.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                'https://cheng80.myqnapcloud.com/tablenow/${store.store_image}',
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    store.store_description!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(store.store_address),
                                  SizedBox(height: 2),
                                  Text('영업시간: ${store.store_open_time} ~ ${store.store_close_time}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      /// TextField Card
                      const SizedBox(height: 12),
                      const Text(
                        '예약자 정보',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        color: p.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildTextField(
                                    label: '이름 *',
                                    controller: nameController,
                                    hint: '',
                                  ),
                                  const SizedBox(height: 16),

                                  buildTextField(
                                    label: '연락처 *',
                                    controller: phoneController,
                                    hint: '',
                                    keyboardType: TextInputType.phone,
                                  ),
                                  const SizedBox(height: 16),

                                  buildTextField(
                                    label: '인원 *',
                                    controller: numberController,
                                    hint: '',
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// CALENDAR
                      const Text(
                        '날짜 선택',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      TableCalendar(
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 7)),
                        focusedDay: data.focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(data.selectedDay, day),
                        onDaySelected: (selected, focused) {
                          ref.read(reservePage01NotifierProvider.notifier).selectDay(selected, focused);
                        },
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        calendarStyle: CalendarStyle(
                          selectedDecoration: BoxDecoration(
                            color: p.primary,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle
                          )
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// TIME SELECT
                      const Text(
                        '시간 선택',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: times.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.4,
                        ),
                        itemBuilder: (context, index) {
                          final time = times[index];
                          final selected = data.selectedTime == time;

                          return GestureDetector(
                            onTap: () {
                              ref.read(reservePage01NotifierProvider.notifier).selectTime(time);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? p.primary
                                      : Colors.grey.shade300,
                                ),
                                color: selected
                                    ? p.primary
                                    : Colors.white,
                              ),
                              child: Text(
                                time,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      selected ? p.textOnPrimary : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
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
                      final reserve = {
                        'store_seq' : store_seq,
                        'customer_seq': customer_seq,
                        'reserve_capacity': numberController.text,
                        'reserve_date': "${data.selectedDay.toString().substring(0,10)}T${data.selectedTime}:00"
                      };
                      print(reserve);
                      box.write('reserve', reserve);
                      //다음 페이지로
                      CustomNavigationUtil.to(
                        context,
                        ReservePage02(),
                        settings: RouteSettings(
                          arguments: {
                            'tablesData': data.tablesData,
                            'store_seq': store_seq,
                            'selectedDate': data.selectedDay,
                            'selectedTime': data.selectedTime
                          }
                        ),
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
          );
        },
        error: (error, stackTrace) => Center(child: Text('Error: $stackTrace')), 
        loading: () => Center(child: CircularProgressIndicator()),
      )
      
    );
  } // build

  //-----Widgets------
  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

} // class
