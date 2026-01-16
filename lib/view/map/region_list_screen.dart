import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/custom/util/navigation/custom_navigation_util.dart';
import 'package:table_now_app/view/map/map_screen.dart';
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
              onTap: () async {
                ref
                    .read(appStateProvider.notifier)
                    .selectStore(region.stores.first);
                await CustomNavigationUtil.to(
                  context,
                  MapScreen(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
