import 'dart:async';

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:http/http.dart' as http;

import 'package:table_now_app/model/store.dart';

class StoreNotifier extends AsyncNotifier<List<Store>> {
  final String baseUrl = "http://192.168.219.103:8000/api/store";

  @override
  FutureOr<List<Store>> build() async {
    return await fetchStores(); // 만들어지자마자 fetch함
  }

  List<Store> Stores = [];

  bool isLoading = false;

  String? error;

  Future<List<Store>> fetchStores() async {
    //   isLoading = true;

    //   error = null; try - catch 방법에서 수정

    final res = await http.get(Uri.parse("$baseUrl/select_stores/"));

    if (res.statusCode != 200) {
      throw Exception('불러오기 실패: ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));

    return (data['results'] as List)
        .map((d) => Store.fromJson(d))
        .toList(); // 차이점: list로 return
  }

  Future<String> insertStores(Store s) async {
    final url = Uri.parse("$baseUrl/insert_store");

    final response = await http.post(
      url,

      headers: {'Content-Type': 'application/json'},

      body: json.encode(s.toJson()),
    );

    final data = json.decode(utf8.decode(response.bodyBytes));

    await refreshStores();

    return data['result'];
  }

  Future<String> updateStores(Store s) async {
    final url = Uri.parse('$baseUrl/update_store');

    final response = await http.post(
      url,

      headers: {'Content-Type': 'application/json'},

      body: json.encode(s.toJson()),
    );

    final data = json.decode(utf8.decode(response.bodyBytes));

    await refreshStores();

    return data['result'];
  }

  Future<String> deleteStore(int seq) async {
    final url = Uri.parse('$baseUrl/delete');

    final response = await http.post(
      url,

      headers: {'Content-Type': 'application/json'},

      body: json.encode({'option_seq': seq}),
    );

    final data = json.decode(utf8.decode(response.bodyBytes));

    await refreshStores();

    return data['result'];
  }

  Future<void> refreshStores() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () async => await fetchStores(),
    ); // null 데이터 체크
  }
}

final storeNotifierProvider = AsyncNotifierProvider<StoreNotifier, List<Store>>(
  StoreNotifier.new,
);
