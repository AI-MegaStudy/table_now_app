import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:table_now_app/config.dart';
import 'package:table_now_app/model/customer.dart';
import 'package:table_now_app/model/reserve.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/model/store_table.dart';

class ReservePage01State {
  final Store store;
  final List<String> times;
  final List<String> reservedDates;
  final List<String> reservedTimes;
  final List<String> reservedTables;
  final String name;
  final String phone;

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final String? selectedTime;

  ReservePage01State({
    required this.store,
    required this.times,
    required this.reservedDates,
    required this.reservedTimes,
    required this.reservedTables,
    required this.name,
    required this.phone,
    required this.focusedDay,
    this.selectedDay,
    this.selectedTime
  });

  ReservePage01State copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    String? selectedTime,
  }) {
    return ReservePage01State(
      store: store,
      times: times,
      reservedDates: reservedDates,
      reservedTimes: reservedTimes,
      reservedTables: reservedTables,
      name: name,
      phone: phone,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      selectedTime: selectedTime ?? this.selectedTime,
    );
  }
}

class ReservePage01Notifier extends AsyncNotifier<ReservePage01State> {
  final String baseUrl = "${getApiBaseUrl()}/api";

  @override
  Future<ReservePage01State> build() async {
    return ReservePage01State(
    store: Store(store_seq: 0, store_address: "", store_lat: 0, store_lng: 0, store_phone: "", store_image: "coco_hapjeong.jpg", store_description: "", store_placement: "", created_at: DateTime.now()),
    times: [],
    name: "",
    phone: "",
    focusedDay: DateTime.now(),
    reservedDates: [],
    reservedTimes: [],
    reservedTables: [],
  );
  }

  Future<void> fetchData(int seq, int cseq, String date) async {
    //가게 정보 받아오기
    try {
      final res = await http.get(Uri.parse("$baseUrl/store/select_store/$seq"));

      if (res.statusCode != 200) {
        throw Exception('스토어 불러오기 실패: ${res.statusCode}');
      }

      final data = json.decode(utf8.decode(res.bodyBytes));

      Store storeData = Store.fromJson(data['result']);

      //고객 정보 받아오기
      final res1 = await http.get(Uri.parse("$baseUrl/customer/$cseq"));

      if (res1.statusCode != 200) {
        throw Exception('고객 불러오기 실패: ${res1.statusCode}');
      }

      final data1 = json.decode(utf8.decode(res1.bodyBytes));

      Customer customerData = Customer.fromJson(data1['result']);

      //시간 테이블 만들기
      List<String> openStr = storeData.store_open_time!.split(":");
      List<int> open = [int.parse(openStr[0]),int.parse(openStr[1])];
      List<String> closeStr = storeData.store_close_time!.split(":");
      List<int> close = [int.parse(closeStr[0]),int.parse(closeStr[1])];
      List<String> timesData = [];

      int timeRange = ((close[0]*60+close[1])-(open[0]*60+open[1]))~/60;
      for (int i=1; i<=timeRange; i++){
        timesData.add(
          "${open[0].toString().padLeft(2, '0')}:${open[1].toString().padLeft(2, '0')}"
        );
        open[0]=open[0]+1;
      }

      //예약 정보 받아오기
      final res2 = await http.get(Uri.parse("$baseUrl/reserve/select_reserves_8_store/${date.split(" ")[0]}/$seq"));
      if (res2.statusCode != 200) {
        throw Exception('예약 불러오기 실패: ${res2.statusCode}');
      }

      final data2 = json.decode(utf8.decode(res2.bodyBytes));

      List<Reserve> reserveData = (data2['results'] as List).map((d) => Reserve.fromJson(d)).toList();

      //테이블 정보 받아오기
      final res3 = await http.get(Uri.parse("$baseUrl/store_table/select_StoreTables_store/$seq"));

      if (res3.statusCode != 200) {
        throw Exception('테이블 불러오기 실패: ${res3.statusCode}');
      }

      final data3 = json.decode(utf8.decode(res3.bodyBytes));

      List<StoreTable> tableData = (data3['results'] as List).map((d) => StoreTable.fromJson(d)).toList();

      //{'2025-01-15': { '12:00:00': {'1': ['1','4']}} 형식으로 만들기
      Map<String, Map<String, Map<String, List<String>>>> map = {};

      for (int i = 0; i < reserveData.length; i++) {
        final reserve = reserveData[i];

        final rdate = reserve.reserve_date.split('T')[0];
        final rtime = reserve.reserve_date.split('T')[1].substring(0, 5);
        final tables = reserve.reserve_tables.split(',');

        map.putIfAbsent(rdate, () => {});
        map[rdate]!.putIfAbsent(rtime, () => {});

        for(int j = 0; j < tables.length; j++){
          String tableNum = tables[j];
          map[rdate]![rtime]!.putIfAbsent(tableNum, () => []);

          for(int k = 0; k < tableData.length; k++){
            if(tableData[k].store_table_seq == int.parse(tableNum)){
              map[rdate]![rtime]![tableNum]!.add('${tableData[k].store_table_name}');
              map[rdate]![rtime]![tableNum]!.add('${tableData[k].store_table_capacity}');
              break;
            }
          }
        }
      }

      // // 막혀있는 날짜, 시간, 테이블 리스트 만들기
      // List list = map.values.toList();
      // for (var l in list){
        
      // }
      
      //state 변경
      state = AsyncValue.data(
        ReservePage01State(
          store: storeData,
          times: timesData,
          reservedDates: [],
          reservedTimes: [],
          reservedTables: [],
          name: customerData.customerName,
          phone: customerData.customerPhone!,
          focusedDay: DateTime.now()
        ),
      );

      //return ReservePage01State(store: storeData, times: timesData, reservedDates: [], reservedTimes: [], reservedTables: []);
    } catch (e, stack) {
      // 에러가 날 경우 상태를 error로 바꿔줌
      print("🔥 ERROR: $e");
      print(stack);
      throw Exception("스토어 로딩 에러: $e");
    }
  }

  /// 날짜 선택
  void selectDay(DateTime selected, DateTime focused) {
    state = AsyncValue.data(
      state.value!.copyWith(
        selectedDay: selected,
        focusedDay: focused,
      ),
    );
  }

  /// 시간 선택
  void selectTime(String time) {
    state = AsyncValue.data(
      state.value!.copyWith(selectedTime: time),
    );
  }

}

// provider 선언
final reservePage01NotifierProvider = AsyncNotifierProvider<ReservePage01Notifier, ReservePage01State>(
  ReservePage01Notifier.new,
);
