import 'package:table_now_app/model/store.dart';

class Region {
  final String name;
  final List<Store> stores;

  Region({required this.name, required this.stores});

  // API의 'results' 리스트를 바로 Region 객체로 변환할 때 사용
  factory Region.fromRawJson(
    String regionName,
    Map<String, dynamic> json,
  ) {
    var list = json['results'] as List? ?? [];
    List<Store> storeList = list
        .map((i) => Store.fromJson(i))
        .toList();

    return Region(name: regionName, stores: storeList);
  }
}
