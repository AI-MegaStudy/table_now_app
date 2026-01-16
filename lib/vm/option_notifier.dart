import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:table_now_app/model/option.dart';

class OptionNotifier extends AsyncNotifier<List<Option>>{
  final String baseUrl = "http://127.0.0.1:8000/api/option";

  @override
  FutureOr<List<Option>> build() async{
    return await fetchOptions(); // 만들어지자마자 fetch함
  }

  List<Option> options = [];
  bool isLoading = false;
  String? error;


  Future<List<Option>> fetchOptions() async{ 
  //   isLoading = true;
  //   error = null; try - catch 방법에서 수정
    final res = await http.get(Uri.parse("$baseUrl/select_options"));

    if(res.statusCode != 200){
      throw Exception('불러오기 실패: ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((d) => Option.fromJson(d)).toList(); // 차이점: list로 return
  }

  Future<String> insertOption(Option o)async{
    final url = Uri.parse("$baseUrl/insert_option");
    final response = await http.post(
      url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(o.toJson()),
      );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshOptions();
    return data['result'];
  }

  Future<String> updateOption(Option o) async {
    final url = Uri.parse('$baseUrl/update_option');
    final response = await http.post(
      url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(o.toJson()),
      );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshOptions();
    return data['result'];
  }

  Future<String> deleteOptions(int seq) async {
    final url = Uri.parse('$baseUrl/delete');
    final response = await http.post(
      url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'option_seq':seq}),
      );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshOptions();
    return data['result'];
  }

  Future<void> refreshOptions() async{
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await fetchOptions()); // null 데이터 체크
  }

} // StudentNotifier

final studentNotifierProvider = AsyncNotifierProvider<OptionNotifier, List<Option>>(
  OptionNotifier.new
);