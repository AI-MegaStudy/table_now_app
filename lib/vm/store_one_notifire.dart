import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:table_now_app/model/store.dart';

class StoreOneNotifier extends AsyncNotifier<Store> {
  final String baseUrl = "http://127.0.0.1:8000/api/store";

  @override
  Future<Store> build() async {
    return fetchOneStore(1);
  }

  Future<Store> fetchOneStore(int seq) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/select_store/$seq"));

      if (res.statusCode != 200) {
        throw Exception('스토어 불러오기 실패: ${res.statusCode}');
      }

      final data = json.decode(utf8.decode(res.bodyBytes));

      return Store.fromJson(data);
    } catch (e) {
      // 에러가 날 경우 상태를 error로 바꿔줌
      throw Exception("스토어 로딩 에러: $e");
    }
  }
}

// provider 선언
final storeOneNotifierProvider = AsyncNotifierProvider<StoreOneNotifier, Store>(
  StoreOneNotifier.new,
);
