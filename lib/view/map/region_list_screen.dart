import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/vm/store_notifire.dart';
// import 'store_booking_info_screen.dart'; // 다음 화면

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
        title: const Text(
          '카레하우스',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // subtitle: const Text(
        //   '지역을 선택하세요',
        //   style: TextStyle(color: Colors.white70, fontSize: 14),
        // ),
        centerTitle: false,
      ),
      body: asyncStore.when(
        data: (storeList) {
          // 1. 주소 기반 지역 그룹화 로직 (예: "서울 강남구..." -> "서울")
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
                    child: const Icon(Icons.location_on, color: Colors.orange),
                  ),
                  title: Text(
                    regionName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                    // 해당 지역의 첫 번째 매장 상세로 이동하거나,
                    // 해당 지역 매장들만 필터링해서 맵화면으로 이동하도록 구현 가능
                    // 여기서는 이미지 디자인에 맞춰 상세화면으로 예시를 듭니다.
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
        error: (err, stack) => Center(child: Text("데이터 로드 실패: $err")),
      ),
    );
  }
}
