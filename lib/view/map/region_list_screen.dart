import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/common_app_bar.dart';
import 'package:table_now_app/view/drawer/profile_drawer.dart';
import 'package:table_now_app/view/map/district.dart';
import 'package:table_now_app/vm/store_notifier.dart';

class RegionListScreen extends ConsumerStatefulWidget {
  const RegionListScreen({super.key});

  @override
  ConsumerState<RegionListScreen> createState() => _RegionListScreenState();
}

class _RegionListScreenState extends ConsumerState<RegionListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final asyncStore = ref.watch(storeNotifierProvider);
    final p = context.palette;

    // final expandedList = [];
    // for (int i = 0; i < 6; i++) {
    //   expandedList.addAll(storeList);
    // }

    return Builder(
      builder: (context) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: p.background,
          // drawer: const AppDrawer(),
          drawer: const ProfileDrawer(),
          appBar: CommonAppBar(
            title: Text(
              '카레하우스',
              style: mainAppBarTitleStyle.copyWith(
                color: p.textOnPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.account_circle,
                  color: p.textOnPrimary,
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ],
          ),
          body: asyncStore.when(
            data: (storeList) {
              final Map<String, List<Store>> groupedStores = {};
              for (var store in storeList) {
                final region = store.store_address.split(
                  ' ',
                )[0];
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
                      color: p.cardBackground,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: p.divider),
                      boxShadow: [
                        BoxShadow(
                          color: p.textSecondary.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
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
                        backgroundColor: p.background,
                        child: Icon(
                          Icons.location_on,
                          color: p.primary,
                        ),
                      ),
                      title: Text(
                        regionName,
                        style: mainTitleStyle.copyWith(
                          color: p.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '매장 $count개',
                        style: mainSmallTextStyle.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: p.textSecondary,
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
          error: (err, stack) => Center(
            child: Text(
              "데이터 로드 실패: $err",
              style: mainBodyTextStyle.copyWith(color: Colors.red),
            ),
          ),
        ),
        );
      },
    );
  }
}
/*
정적화면-consumer
데이터가공-notifier
감시-요약 및 필터링
 */