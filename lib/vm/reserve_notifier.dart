import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:table_now_app/model/reserve.dart';

class ReserveNotifier extends AsyncNotifier<List<Reserve>>{

  final String baseUrl = "http://127.0.0.1:8000/api/reserve";

  @override
  FutureOr<List<Reserve>> build() async{
    return await fetchReserves();
  }

  Future<List<Reserve>> fetchReserves() async{
    final res = await http.get(Uri.parse("$baseUrl/select_reserves"));

    if(res.statusCode != 200){
      throw Exception("불러오기 실패: ${res.statusCode}");
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((d) => Reserve.fromJson(d)).toList();

  }

  Future<Reserve> selectReserve(int seq) async{
    final res = await http.get(Uri.parse("$baseUrl/select_reserve/$seq"));

    if(res.statusCode != 200){
      throw Exception("불러오기 실패: ${res.statusCode}");
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return Reserve.fromJson(data['result']);

  }  

  Future<String> insertReserve(Reserve s)async{
    final url = Uri.parse("$baseUrl/insert_reserve");
    final response = await http.post(
      url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(s.toJson()),
      );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshReserves();
    return data['result'];
  }

  Future<String> updateReserve(Reserve s) async {
    final url = Uri.parse('$baseUrl/update_reserve');
    final response = await http.post(
      url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(s.toJson()),
      );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshReserves();
    return data['result'];
  }

  Future<String> deleteReserve(String item_id) async {
    final url = Uri.parse('$baseUrl/delete_reserve');
    final response = await http.post(
      url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'item_id':item_id}),
      );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshReserves();
    return data['result'];
  }

  Future<void> refreshReserves() async{
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await fetchReserves(),);
  }


} // reserveNotifier

final reserveNotifierProvider = AsyncNotifierProvider<ReserveNotifier, List<Reserve>>(
  ReserveNotifier.new
);