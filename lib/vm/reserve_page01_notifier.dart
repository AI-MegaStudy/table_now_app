import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:table_now_app/config.dart';
import 'package:table_now_app/model/reserve.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/model/store_table.dart';

class ReservePage01State {
  final Store store;
  final List<String> times;
  final List<String> leftDates;
  final List<String> leftTimes;
  final List<String> leftTables;

  ReservePage01State({
    required this.store,
    required this.times,
    required this.leftDates,
    required this.leftTimes,
    required this.leftTables
  });
}

class ReservePage01Notifier extends AsyncNotifier<ReservePage01State> {
  final String baseUrl = "${getApiBaseUrl()}/api";

  @override
  Future<ReservePage01State> build() async {
    return fetchData(1, "2026-01-15 00:00:00");
  }

  Future<ReservePage01State> fetchData(int seq, String date) async {
    //가게 정보 받아오기
    try {
      final res = await http.get(Uri.parse("$baseUrl/store/select_store/$seq"));

      if (res.statusCode != 200) {
        throw Exception('스토어 불러오기 실패: ${res.statusCode}');
      }

      final data = json.decode(utf8.decode(res.bodyBytes));

      Store storeData = Store.fromJson(data['result']);

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
      final res2 = await http.get(Uri.parse("$baseUrl/reserve/select_reserves_8/${date.split(" ")[0]}"));
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

      //{날짜,{시간{테이블 번호, [테이블 이름, 테이블 인원]}} 생성
      Map<String, Map<String, List<String>>> bigMap = {};
      Map<String, List<String>> smallMap = {};
      for(int i=0; i<=reserveData.length; i++){
        String rdate = reserveData[i].reserve_date.split(' ')[0];
        String rtime = reserveData[i].reserve_date.split(' ')[1];
        List<String> tables = reserveData[i].reserve_tables.split(",");
        smallMap[rtime] = [];
        for(int j=0; j<=tables.length; j++){
          //smallMap[rtime]!.add({tables[j],[]});
        }
        
      }
      

      return ReservePage01State(store: storeData, times: timesData, leftDates: [], leftTimes: [], leftTables: []);
    } catch (e) {
      // 에러가 날 경우 상태를 error로 바꿔줌
      throw Exception("스토어 로딩 에러: $e");
    }
  }

}

// provider 선언
final reservePage01NotifierProvider = AsyncNotifierProvider<ReservePage01Notifier, ReservePage01State>(
  ReservePage01Notifier.new,
);
