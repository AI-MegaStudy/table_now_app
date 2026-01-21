import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config.dart';
import 'package:http/http.dart' as http;
import 'package:table_now_app/model/store_table.dart';

class ReservePage02State{
  final List tableModelList;
  final List<String>? selectedTable;
  final int? usedCapacity;

  ReservePage02State({
    required this.tableModelList,
    this.selectedTable,
    this.usedCapacity
  });

  ReservePage02State copyWith({
    List<String>? selectedTable,
    int? leftCapacity
  }){
    return ReservePage02State(
      tableModelList: tableModelList,
      selectedTable: selectedTable ?? this.selectedTable,
      usedCapacity: leftCapacity ?? this.usedCapacity
    );
  }
}

class ReservePage02Notifier extends AsyncNotifier<ReservePage02State>{
  final String baseUrl = "${getApiBaseUrl()}/api";

  @override
  FutureOr<ReservePage02State> build() {
    return ReservePage02State(
      tableModelList: [],
      usedCapacity: 0
    );
  }

  Future<void> fetchData(int seq) async {
    try {
      //테이블 정보 받아오기
      final res = await http.get(Uri.parse("$baseUrl/store_table/select_StoreTables_store/$seq"));

      if (res.statusCode != 200) {
        throw Exception('테이블 불러오기 실패: ${res.statusCode}');
      }

      final data = json.decode(utf8.decode(res.bodyBytes));

      List<StoreTable> tableData = (data['results'] as List).map((d) => StoreTable.fromJson(d)).toList();

      //테이블 갯수 갱신
      state = AsyncValue.data(
        ReservePage02State(
          tableModelList: tableData,
          selectedTable: state.value?.selectedTable,
          usedCapacity: state.value?.usedCapacity ?? 0,
        )
      );
    }catch (e, stack) {
      // 에러가 날 경우 상태를 error로 바꿔줌
      print("🔥 ERROR: $e");
      print(stack);
      throw Exception("스토어 로딩 에러: $e");
    }
  }

  void selectTable(List<String> seqList) {
    state = AsyncValue.data(
      state.value!.copyWith(selectedTable: seqList),
    );
  }

  void updateUsedCapacity(int number){
    state = AsyncValue.data(
      state.value!.copyWith(leftCapacity: state.value!.usedCapacity! + number),
    );
  }
}

// provider 선언
final reservePage02NotifierProvider = AsyncNotifierProvider<ReservePage02Notifier, ReservePage02State>(
  ReservePage02Notifier.new,
);