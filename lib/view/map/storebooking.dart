import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/theme/palette_context.dart';

class StoreBookingInfoScreen extends ConsumerWidget {
  final Store store;
  const StoreBookingInfoScreen(this.store, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              store.store_description ?? '매장 상세',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '예약 정보',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
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
                shadowColor: Colors.black,
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
                        store.store_image ??
                            'https://via.placeholder.com/400x200',
                        //'https://cheng80.myqnapcloud.com/tablenow/${menus[widget.menu_seq].menu_image}'
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
                              color: Colors.grey,
                              child: Icon(
                                Icons.image_not_supported,
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
                                    "",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
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
                                  store.store_address ?? "",
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
                                '영업시간: ${store.store_open_time ?? ""} - ${store.store_close_time ?? ""}',
                                style: TextStyle(
                                  color:
                                      Colors.grey.shade700,
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      '다음',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
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
              color: isActive ? Colors.white : Colors.grey,
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
