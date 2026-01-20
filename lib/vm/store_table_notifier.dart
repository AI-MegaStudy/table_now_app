import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:table_now_app/config.dart';
import 'package:table_now_app/model/store_table.dart';

class StoreTableNotifier
    extends AsyncNotifier<List<StoreTable>> {
  //final String baseUrl = "http://192.168.219.103:8000";
  String get baseUrl => "${getApiBaseUrl()}/api/storetable";

  @override
  FutureOr<List<StoreTable>> build() async {
    return await fetchStoreTables();
  }

  Future<List<StoreTable>> fetchStoreTables() async {
    final res = await http.get(
      Uri.parse("$baseUrl/select_StoreTables"),
    );

    if (res.statusCode != 200) {
      throw Exception('테이블 목록 불러오기 실패: ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List)
        .map((d) => StoreTable.fromJson(d))
        .toList();
  }

  Future<String> insertStoreTable(StoreTable table) async {
    final url = Uri.parse("$baseUrl/insert_StoreTable");

    final response = await http.post(
      url,
      body: {
        'store_seq': table.store_seq.toString(),
        'store_table_name': table.store_table_name
            .toString(),
        'store_table_capacity': table.store_table_capacity
            .toString(),
        'store_table_inuse': table.store_table_inuse,
      },
    );

    final data = json.decode(
      utf8.decode(response.bodyBytes),
    );
    await refreshStoreTables();
    return data['result'];
  }

  Future<String> updateStoreTable(StoreTable table) async {
    final url = Uri.parse('$baseUrl/update_StoreTable');
    final response = await http.post(
      url,
      body: {
        'store_table_seq': table.store_table_seq.toString(),
        'store_seq': table.store_seq.toString(),
        'store_table_name': table.store_table_name
            .toString(),
        'store_table_capacity': table.store_table_capacity
            .toString(),
        'store_table_inuse': table.store_table_inuse,
      },
    );

    final data = json.decode(
      utf8.decode(response.bodyBytes),
    );
    await refreshStoreTables();
    return data['result'];
  }

  Future<String> deleteStoreTable(int seq) async {
    final url = Uri.parse(
      '$baseUrl/delete_StoreTable/$seq',
    );
    final response = await http.delete(url);

    final data = json.decode(
      utf8.decode(response.bodyBytes),
    );
    await refreshStoreTables();
    return data['result'];
  }

  Future<void> refreshStoreTables() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => await fetchStoreTables(),
    );
  }
}

final storeTableNotifierProvider =
    AsyncNotifierProvider<
      StoreTableNotifier,
      List<StoreTable>
    >(StoreTableNotifier.new);
