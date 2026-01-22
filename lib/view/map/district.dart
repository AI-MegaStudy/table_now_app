import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/common_app_bar.dart';
import 'package:table_now_app/view/drawer/profile_drawer.dart';
import 'package:table_now_app/view/map/map_screen.dart';

class DistrictListScreen extends ConsumerStatefulWidget {
  final String regionName;
  final List<Store> storesInRegion;

  const DistrictListScreen({
    super.key,
    required this.regionName,
    required this.storesInRegion,
  });

  @override
  ConsumerState<DistrictListScreen> createState() => _DistrictListScreenState();
}

class _DistrictListScreenState extends ConsumerState<DistrictListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    final Map<String, List<Store>> groupedDistricts = {};
    for (var store in widget.storesInRegion) {
      final parts = store.store_address.split(' ');

      final district = parts.length > 1 ? parts[1] : '기타';

      groupedDistricts
          .putIfAbsent(district, () => [])
          .add(store);
    }

    final districts = groupedDistricts.keys.toList();

    return Builder(
      builder: (context) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: p.background,
          // drawer: const AppDrawer(),
          drawer: const ProfileDrawer(),
          appBar: CommonAppBar(
        title: Text(
          '${widget.regionName} 세부지역',
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              leading: CircleAvatar(
                backgroundColor: p.background,
                child: Icon(Icons.map, color: p.primary),
              ),
              title: Text(
                districtName,
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
      },
    );
  }
}
