import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/vm/map_notifier.dart';

class RegionListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regions = ref.watch(
      appStateProvider.select((state) => state.regions),
    );

    return Scaffold(
      appBar: AppBar(title: Text('카레하우스 - 지역 선택')),
      body: ListView.builder(
        itemCount: regions.length,
        itemBuilder: (context, index) {
          final region = regions[index];

          return Card(
            margin: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: ListTile(
              leading: Icon(
                Icons.location_on,
                color: Colors.orange,
              ),
              title: Text(
                region.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('매장 ${region.stores.length}개'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // 지역 선택 후 첫 번째 매장 선택
                ref
                    .read(appStateProvider.notifier)
                    .selectStore(region.stores.first);
                Navigator.pushNamed(context, '/map');
              },
            ),
          );
        },
      ),
    );
  }
}
