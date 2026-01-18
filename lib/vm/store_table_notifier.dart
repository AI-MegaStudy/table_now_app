import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:table_now_app/model/storetable.dart';

class StoreTableNotifier extends AsyncNotifier<List<StoreTable>> {
  // 서버 주소 (실제 서버 IP로 수정 필요)
  final String baseUrl = "http://192.168.219.103:8000";

  @override
  FutureOr<List<StoreTable>> build() async {
    return await fetchStoreTables(); // 공급자가 생성될 때 데이터를 처음으로 가져옴
  }

  // 1. 전체 조회 (Read)
  Future<List<StoreTable>> fetchStoreTables() async {
    final res = await http.get(Uri.parse("$baseUrl/select_StoreTables"));

    if (res.statusCode != 200) {
      throw Exception('테이블 목록 불러오기 실패: ${res.statusCode}');
    }

    // 한글 깨짐 방지를 위해 utf8.decode 처리
    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List)
        .map((d) => StoreTable.fromJson(d))
        .toList();
  }

  // 2. 추가 (Create)
  Future<String> insertStoreTable(StoreTable table) async {
    final url = Uri.parse("$baseUrl/insert_StoreTable");

    // FastAPI에서 Form(...)으로 받으므로 MultipartRequest 또는 body에 맵 전달
    // 여기서는 일반적인 POST 전송 방식을 사용합니다.
    final response = await http.post(
      url,
      body: {
        'store_seq': table.store_seq.toString(),
        'store_table_name': table.store_table_name.toString(),
        'store_table_capacity': table.store_table_capacity.toString(),
        'store_table_inuse': table.store_table_inuse,
      },
    );

    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshStoreTables(); // 성공 후 목록 새로고침
    return data['result']; // "OK" 반환
  }

  // 3. 수정 (Update)
  Future<String> updateStoreTable(StoreTable table) async {
    final url = Uri.parse('$baseUrl/update_StoreTable');
    final response = await http.post(
      url,
      body: {
        'store_table_seq': table.store_table_seq.toString(),
        'store_seq': table.store_seq.toString(),
        'store_table_name': table.store_table_name.toString(),
        'store_table_capacity': table.store_table_capacity.toString(),
        'store_table_inuse': table.store_table_inuse,
      },
    );

    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshStoreTables();
    return data['result'];
  }

  // 4. 삭제 (Delete)
  Future<String> deleteStoreTable(int seq) async {
    final url = Uri.parse('$baseUrl/delete_StoreTable/$seq');
    final response = await http.delete(url); // DELETE 방식 사용

    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshStoreTables();
    return data['result'];
  }

  // 5. 새로고침 로직
  Future<void> refreshStoreTables() async {
    state = const AsyncLoading(); // 로딩 상태로 변경
    state = await AsyncValue.guard(
      () async => await fetchStoreTables(),
    ); // 성공 시 데이터 업데이트, 실패 시 에러 처리
  }
}

// UI에서 접근하기 위한 전역 프로바이더
final storeTableNotifierProvider =
    AsyncNotifierProvider<StoreTableNotifier, List<StoreTable>>(
      StoreTableNotifier.new,
    );
