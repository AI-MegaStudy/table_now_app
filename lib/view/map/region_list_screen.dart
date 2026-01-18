import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/view/map/map_screen.dart';
import 'package:table_now_app/vm/store_notifire.dart';

class RegionListScreen extends ConsumerWidget {
  const RegionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStore = ref.watch(storeNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: Text(
          '카레하우스',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // subtitle: Text(
        //   '지역을 선택하세요',
        //   style: TextStyle(color: Colors.white70, fontSize: 14),
        // ),
        centerTitle: false,
      ),
      body: asyncStore.when(
        data: (storeList) {
          final Map<String, List<Store>> groupedStores = {};
          for (var store in storeList) {
            final region = store.store_address.split(' ')[0]; // 첫 단어 추출
            groupedStores.putIfAbsent(region, () => []).add(store);
          }

          final regions = groupedStores.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: regions.length,
            itemBuilder: (context, index) {
              final regionName = regions[index];
              final count = groupedStores[regionName]!.length;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
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
                    backgroundColor: Colors.orange.shade50,
                    child: Icon(Icons.location_on, color: Colors.orange),
                  ),
                  title: Text(
                    regionName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '매장 $count개',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    final storesInRegion = groupedStores[regionName]!;
                    _navigateToMap(context, storesInRegion);
                  },
                ),
              );
            },
          );
        },
        loading: () =>
            Center(child: CircularProgressIndicator(color: Colors.orange)),
        error: (err, stack) => Center(child: Text("데이터 로드 실패: $err")),
      ),
    );
  } //

  void _navigateToMap(BuildContext context, List<Store> storeList) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen(storeList: storeList)),
    );
  }
}
