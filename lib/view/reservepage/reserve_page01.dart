import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/custom/custom_text_field.dart';
import 'package:table_now_app/custom/util/navigation/custom_navigation_util.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/common_app_bar.dart';
import 'package:table_now_app/utils/custom_common_util.dart';
import 'package:table_now_app/utils/customer_storage.dart';
import 'package:table_now_app/utils/reservation_validator.dart';
import 'package:table_now_app/view/drawer/profile_drawer.dart';
import 'package:table_now_app/view/reservepage/reserve_page02.dart';
import 'package:table_now_app/vm/reserve_page01_notifier.dart';

class ReservePage01 extends ConsumerStatefulWidget {
  const ReservePage01({super.key,});

  @override
  ConsumerState<ReservePage01> createState() => _ReservePage01State();
}

class _ReservePage01State extends ConsumerState<ReservePage01> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController numberController;

  int store_seq = 1;
  int customer_seq = 1;
  String date = DateTime.now().toString();

  final customer = CustomerStorage.getCustomer();
  final box = GetStorage();

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    phoneController = TextEditingController();
    numberController = TextEditingController();
    customer_seq = customer == null ? 1 : customer!.customerSeq;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = CustomNavigationUtil.arguments<Map<String, dynamic>>(context);
      if (args != null) {
        store_seq = args['store_seq'] as int;
      }

      ref.read(reservePage01NotifierProvider.notifier).fetchData(store_seq, customer_seq, date);
    });
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
    final p = context.palette;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: p.background,
      drawer: const ProfileDrawer(),
      appBar: CommonAppBar(
        title: Text(
          '예약 정보',
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
        data: (data){
          Store store = data.store;
          List<String> times = data.times;
          nameController.text = data.name;
          phoneController.text = data.phone;
          return Column(
            children: [
              /// STEP INDICATOR
              _buildStepIndicator(p, currentStep: 0),

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
                                    style: mainTitleStyle.copyWith(
                                      color: p.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    store.store_address,
                                    style: mainBodyTextStyle.copyWith(
                                      color: p.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '영업시간: ${store.store_open_time} ~ ${store.store_close_time}',
                                    style: mainSmallTextStyle.copyWith(
                                      color: p.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      /// TextField Card
                      const SizedBox(height: 16),
                      Text(
                        '예약자 정보',
                        style: mainTitleStyle.copyWith(color: p.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        color: p.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                controller: nameController,
                                labelText: '이름 *',
                                filled: true,
                                fillColor: p.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: p.divider),
                                ),
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: phoneController,
                                labelText: '연락처 *',
                                keyboardType: TextInputType.phone,
                                filled: true,
                                fillColor: p.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: p.divider),
                                ),
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: numberController,
                                labelText: '인원 *',
                                keyboardType: TextInputType.number,
                                filled: true,
                                fillColor: p.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: p.divider),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// CALENDAR
                      Text(
                        '날짜 선택',
                        style: mainTitleStyle.copyWith(color: p.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        color: p.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.now(),
                          lastDay: DateTime.now().add(const Duration(days: 7)),
                          focusedDay: data.focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(data.selectedDay, day),
                          onDaySelected: (selected, focused) {
                            ref.read(reservePage01NotifierProvider.notifier).selectDay(selected, focused);
                          },
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: mainMediumTitleStyle.copyWith(
                              color: p.textPrimary,
                            ),
                            leftChevronIcon: Icon(Icons.chevron_left, color: p.textPrimary),
                            rightChevronIcon: Icon(Icons.chevron_right, color: p.textPrimary),
                          ),
                          calendarStyle: CalendarStyle(
                            defaultTextStyle: TextStyle(color: p.textPrimary),
                            weekendTextStyle: TextStyle(color: p.textSecondary),
                            outsideTextStyle: TextStyle(color: p.textSecondary.withOpacity(0.5)),
                            selectedDecoration: BoxDecoration(
                              color: p.primary,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: p.textSecondary.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: TextStyle(color: p.textPrimary),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(color: p.textSecondary),
                            weekendStyle: TextStyle(color: p.textSecondary),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// TIME SELECT
                      Text(
                        '시간 선택',
                        style: mainTitleStyle.copyWith(color: p.textPrimary),
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
                          
                          // 현재 선택된 날짜에서 이 시간에 이미 예약이 있는지 확인
                          final dateKey = data.selectedDay?.toString().substring(0, 10) ?? '';
                          final bool hasExistingReservation = ReservationValidator.hasCustomerReservation(
                            customerReservations: data.customerReservations,
                            date: dateKey,
                            time: time,
                          );

                          return GestureDetector(
                            onTap: () {
                              if (hasExistingReservation) {
                                CustomCommonUtil.showErrorSnackbar(
                                  context: context,
                                  message: '이미 해당 시간에 예약이 있습니다.',
                                );
                                return;
                              }
                              ref.read(reservePage01NotifierProvider.notifier).selectTime(time);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: hasExistingReservation 
                                      ? Colors.grey 
                                      : selected 
                                          ? p.primary 
                                          : p.divider,
                                ),
                                color: hasExistingReservation
                                    ? Colors.grey.shade300
                                    : selected 
                                        ? p.primary 
                                        : p.cardBackground,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    time,
                                    style: mainBodyTextStyle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: hasExistingReservation
                                          ? Colors.grey.shade600
                                          : selected 
                                              ? p.textOnPrimary 
                                              : p.textPrimary,
                                    ),
                                  ),
                                  if (hasExistingReservation)
                                    Text(
                                      '예약됨',
                                      style: mainSmallTextStyle.copyWith(
                                        color: Colors.grey.shade600,
                                        fontSize: 10,
                                      ),
                                    ),
                                ],
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
                      if (nameController.text.trim().isEmpty) {
                        CustomCommonUtil.showErrorSnackbar(
                          context: context,
                          message: '이름을 입력해주세요.',
                        );
                        return;
                      }
                      if (phoneController.text.trim().isEmpty) {
                        CustomCommonUtil.showErrorSnackbar(
                          context: context,
                          message: '연락처를 입력해주세요.',
                        );
                        return;
                      }
                      if (numberController.text.trim().isEmpty) {
                        CustomCommonUtil.showErrorSnackbar(
                          context: context,
                          message: '인원을 입력해주세요.',
                        );
                        return;
                      }
                      if (data.selectedDay == null) {
                        CustomCommonUtil.showErrorSnackbar(
                          context: context,
                          message: '날짜를 선택해주세요.',
                        );
                        return;
                      }
                      if (data.selectedTime == null) {
                        CustomCommonUtil.showErrorSnackbar(
                          context: context,
                          message: '시간을 선택해주세요.',
                        );
                        return;
                      }
                      
                      //스토리지에 예약 정보 저장
                      final reserve = {
                        'store_seq' : store_seq,
                        'customer_seq': customer_seq,
                        'reserve_capacity': numberController.text,
                        'reserve_date': "${data.selectedDay.toString().substring(0,10)}T${data.selectedTime}:00"
                      };
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
                            'selectedTime': data.selectedTime,
                            'reserve_capacity': numberController.text,
                          }
                        ),
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
          );
        },
        error: (error, stackTrace) => Center(
          child: Text(
            'Error: $stackTrace',
            style: mainBodyTextStyle.copyWith(color: Colors.red),
          ),
        ),
        loading: () => Center(
          child: CircularProgressIndicator(color: p.primary),
        ),
      )
      
    );
  } // build

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
