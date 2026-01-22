import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:table_now_app/config.dart';
import 'package:table_now_app/model/menu.dart';

class MenuNotifier extends AsyncNotifier<List<Menu>>{
  final String baseUrl = "${getApiBaseUrl()}/api/menu";

  @override
  FutureOr<List<Menu>> build() async{
    return [];
  }

  List<Menu> menus = [];
  bool isLoading = false;
  String? error;

  Future<void> loadMenuDetail(int seq) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => fetchMenu(seq));
  }


  Future<List<Menu>> fetchMenus() async{ 
  //   isLoading = true;
  //   error = null; try - catch 방법에서 수정
    final res = await http.get(Uri.parse("$baseUrl/select_menu"));

    if(res.statusCode != 200){
      throw Exception('불러오기 실패: ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((d) => Menu.fromJson(d)).toList(); // 차이점: list로 return
  }

  Future<List<Menu>> fetchMenu(int seq) async{ 
  //   isLoading = true;
  //   error = null; try - catch 방법에서 수정
    final res = await http.get(Uri.parse("$baseUrl/select_menu/$seq")); // 일단 해보고 수정

    if(res.statusCode != 200){
      throw Exception('불러오기 실패: ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((d) => Menu.fromJson(d)).toList(); // 차이점: list로 return
  }

  Future<String> insertMenus(Menu m)async{
    final url = Uri.parse("$baseUrl/insert_menu");
    final response = await http.post(
      url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(m.toJson()),
      );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshMenus();
    return data['results'];
  }

  Future<String> updateMenus(Menu m) async {
    final url = Uri.parse('$baseUrl/update_menu');
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
    final url = Uri.parse('$baseUrl/delete_menu/$seq');
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

} // MenuNotifier

final menuNotifierProvider = AsyncNotifierProvider<MenuNotifier, List<Menu>>(
  MenuNotifier.new
);

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-16
// 작성자: 임소연
// 설명: Menu Notifier
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-16 임소연: 초기 생성
// 2026-01-22 임소연: 화면에서 받은 store sequence로 매장별 메뉴 조회