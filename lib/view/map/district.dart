import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/view/map/map_screen.dart';

class DistrictListScreen extends ConsumerWidget {
  final String regionName; // 예: "서울" 또는 "서울특별시"
  final List<Store> storesInRegion; // 부모로부터 받은 해당 시/도의 매장들

  const DistrictListScreen({
    super.key,
    required this.regionName,
    required this.storesInRegion,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;

    // 1. 데이터를 "구" 단위로 그룹화 (주소의 두 번째 단어 추출)
    final Map<String, List<Store>> groupedDistricts = {};
    for (var store in storesInRegion) {
      final parts = store.store_address.split(' ');
      // 주소가 "서울시 구로구 ..." 형태일 때 인덱스 [1]이 "구로구"가 됨
      final district = parts.length > 1 ? parts[1] : '기타';

      groupedDistricts
          .putIfAbsent(district, () => [])
          .add(store);
    }

    final districts = groupedDistricts.keys.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '$regionName 세부지역',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // subtitle: Text(
        //   '지역을 선택하세요',
        //   style: TextStyle(color: Colors.white70, fontSize: 14),
        // ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: districts.length,
        itemBuilder: (context, index) {
          final districtName = districts[index];
          final count =
              groupedDistricts[districtName]!.length;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              // border: Border.all(color: Colors.grey),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              leading: CircleAvatar(
                backgroundColor: p.primary.withOpacity(0.1),
                child: Icon(Icons.map, color: p.primary),
              ),
              title: Text(
                districtName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('매장 $count개'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: () {
                // 선택한 "구"의 매장 리스트만 가지고 지도로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                      storeList:
                          groupedDistricts[districtName]!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
