import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/utils/common_app_bar.dart';
import 'package:table_now_app/view/drawer/profile_drawer.dart';
import 'package:table_now_app/view/map/yeeun/navigator.dart';

class StoreBookingInfoScreen extends ConsumerWidget {
  final Store store;

  const StoreBookingInfoScreen({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final GlobalKey<ScaffoldState> scaffoldKey =
        GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: p.background,
      drawer: const ProfileDrawer(),
      appBar: CommonAppBar(
        title: Text(
          '${store.store_description ?? "매장상세"}',
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
              scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 30,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                _buildStep(1, '정보', isActive: true),
                _buildLine(),
                _buildStep(2, '메뉴'),
                _buildLine(),
                _buildStep(3, '좌석'),
                _buildLine(),
                _buildStep(4, '확인'),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                      child: Image.network(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSHP5M5s5eCfRsmmEp0KVGz7E1mPYbbRz7dqg&s',
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (
                              context,
                              error,
                              stackTrace,
                            ) => Container(
                              height: 220,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                              ),
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.restaurant,
                                color: Colors.orange,
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                store.store_description ??
                                    "매장 정보 없음",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.grey,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  store.store_address ??
                                      "주소 정보 없음",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.grey,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '영업시간: ${store.store_open_time ?? "-"} - ${store.store_close_time ?? "-"}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              24,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NavigatorScreen(store: store),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "다음",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
    int number,
    String title, {
    bool isActive = false,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isActive
              ? Colors.green
              : Colors.grey,
          child: Text(
            '$number',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.green : Colors.grey,
            fontWeight: isActive
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildLine() => Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 1,
      color: Colors.grey,
    ),
  );
}
