import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/view/map/district.dart';
import 'package:table_now_app/view/map/map_screen.dart';
import 'package:table_now_app/vm/store_notifier.dart';

class RegionListScreen extends ConsumerWidget {
  const RegionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStore = ref.watch(storeNotifierProvider);
    final p = context.palette;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '카레하우스',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // subtitle: Text(
        //   '지역을 선택하세요',
        //   style: TextStyle(color: Colors.white70, fontSize: 14),
        // ),
        // centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: asyncStore.when(
        data: (storeList) {
          final Map<String, List<Store>> groupedStores = {};
          for (var store in storeList) {
            final region = store.store_address.split(
              ' ',
            )[0]; // 첫 단어 추출
            groupedStores
                .putIfAbsent(region, () => [])
                .add(store);
          }

          final regions = groupedStores.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: regions.length,
            itemBuilder: (context, index) {
              final regionName = regions[index];
              final count =
                  groupedStores[regionName]!.length;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.location_on,
                      color: p.primary,
                    ),
                  ),
                  title: Text(
                    regionName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '매장 $count개',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    final storesInRegion =
                        groupedStores[regionName]!;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DistrictListScreen(
                              regionName: regionName,
                              storesInRegion:
                                  storesInRegion,
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: p.primary,
          ),
        ),
        error: (err, stack) =>
            Center(child: Text("데이터 로드 실패: $err")),
      ),
    );
  } //

  void _navigateToMap(
    BuildContext context,
    List<Store> storeList,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MapScreen(storeList: storeList),
      ),
    );
  }
}
/*
정적화면-consumer
데이터가공-notifier
감시-요약 및 필터링
 */