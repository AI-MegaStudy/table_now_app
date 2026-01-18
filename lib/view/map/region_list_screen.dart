import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/view/map/map_screen.dart';
import 'package:table_now_app/vm/store_notifire.dart';

class RegionListScreen extends ConsumerWidget {
  const RegionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. 상태 감시: AsyncNotifier인 regionNotifierProvider를 지켜봅니다.
    final asyncStore = ref.watch(storeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('카레하우스 - 지역 선택'), centerTitle: true),
      // 2. AsyncValue.when을 사용하여 상태별 UI 분기
      body: asyncStore.when(
        // [A] 데이터 로드가 성공했을 때
        data: (storeList) {
          if (storeList.isEmpty) {
            return const Center(child: Text("지역 정보가 없습니다."));
          }

          return ListView.builder(
            itemCount: storeList.length,
            itemBuilder: (context, index) {
              final store = storeList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Icon(Icons.location_on, color: Colors.orange),
                  title: Text(
                    store.store_description!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('매장 ${storeList.length}개'),
                  onTap: () {
                    // 선택된 지역 데이터를 가지고 MapScreen으로 이동
                    // (MapScreen에서 다시 ref.watch(regionNotifierProvider)를 통해 데이터를 사용합니다)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MapScreen()),
                    );
                  },
                ),
              );
            },
          );
        },
        // [B] 데이터 로딩 중일 때 (서버 통신 중)
        loading: () => Center(child: CircularProgressIndicator()),
        // [C] 에러가 발생했을 때
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 40),
              SizedBox(height: 10),
              Text("데이터 로드 실패: $error"),
              TextButton(
                onPressed: () => ref.refresh(storeNotifierProvider),
                child: Text("다시 시도"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
