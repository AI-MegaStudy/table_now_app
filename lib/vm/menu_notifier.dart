import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:table_now_app/model/menu.dart';

class MenuNotifier extends AsyncNotifier<List<Menu>>{
  final String baseUrl = "http://127.0.0.1:8000/api/menu";

  @override
  FutureOr<List<Menu>> build() async{
    return await fetchMenus(); // 만들어지자마자 fetch함
  }

  List<Menu> menus = [];
  bool isLoading = false;
  String? error;


  Future<List<Menu>> fetchMenus() async{ 
  //   isLoading = true;
  //   error = null; try - catch 방법에서 수정
    final res = await http.get(Uri.parse("$baseUrl/select_menu/"));

    if(res.statusCode != 200){
      throw Exception('불러오기 실패: ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((d) => Menu.fromJson(d)).toList(); // 차이점: list로 return
  }

  Future<String> insertMenus(Menu m)async{
    final url = Uri.parse("$baseUrl/insert_option");
    final response = await http.post(
      url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(m.toJson()),
      );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshMenus();
    return data['result'];
  }

  Future<String> updateMenus(Menu m) async {
    final url = Uri.parse('$baseUrl/update_option');
    final response = await http.post(
      url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(m.toJson()),
      );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshMenus();
    return data['result'];
  }

  Future<String> deleteMenus(int seq) async {
    final url = Uri.parse('$baseUrl/delete');
    final response = await http.post(
      url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'option_seq':seq}),
      );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshMenus();
    return data['result'];
  }

  Future<void> refreshMenus() async{
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await fetchMenus()); // null 데이터 체크
  }

} // StudentNotifier

final studentNotifierProvider = AsyncNotifierProvider<MenuNotifier, List<Menu>>(
  MenuNotifier.new
);