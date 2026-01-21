import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/common_app_bar.dart';
import 'package:table_now_app/view/drawer/profile_drawer.dart';
import 'package:table_now_app/view/map/map_screen.dart';

class DistrictListScreen extends ConsumerWidget {
  final String regionName;
  final List<Store> storesInRegion;

  const DistrictListScreen({
    super.key,
    required this.regionName,
    required this.storesInRegion,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<ScaffoldState> _scaffoldKey =
        GlobalKey<ScaffoldState>();
    final p = context.palette;

    final Map<String, List<Store>> groupedDistricts = {};
    for (var store in storesInRegion) {
      final parts = store.store_address.split(' ');

      final district = parts.length > 1 ? parts[1] : '기타';

      groupedDistricts
          .putIfAbsent(district, () => [])
          .add(store);
    }

    final districts = groupedDistricts.keys.toList();

    return Scaffold(
      key: _scaffoldKey, //<<<<< 스캐폴드 키 지정
      backgroundColor: p.background,
      // drawer: const AppDrawer(),
      drawer: const ProfileDrawer(), //<<<<< 프로필 드로워 세팅
      appBar: CommonAppBar(
        title: Text(
          '$regionName 세부지역',
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),

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
                  color: p.chipSelectedBg,
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
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
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
  }
}
