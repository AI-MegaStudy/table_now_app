import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:table_now_app/model/store.dart';

class StoreOneNotifier extends AsyncNotifier<List<Store>> {
  final String baseUrl = "http://127.0.0.1:8000/api/store";

  @override
  Future<List<Store>> build() async {
    return fetchOneStore();
  }

  Future<List<Store>> fetchOneStore() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/select_stores/"));

      if (res.statusCode != 200) {
        throw Exception('스토어 불러오기 실패: ${res.statusCode}');
      }

      final data = json.decode(utf8.decode(res.bodyBytes));

      // API 결과 구조에 맞게 수정
      if (data is Map && data.containsKey('results')) {
        return (data['results'] as List).map((e) => Store.fromJson(e)).toList();
      }

      // fallback
      return (data as List).map((e) => Store.fromJson(e)).toList();
    } catch (e) {
      // 에러가 날 경우 상태를 error로 바꿔줌
      throw Exception("스토어 로딩 에러: $e");
    }
  }
}

// provider 선언
final storeNotifierProvider = AsyncNotifierProvider<StoreOneNotifier, List<Store>>(
  StoreOneNotifier.new,
);
