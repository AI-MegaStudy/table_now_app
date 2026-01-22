import 'package:flutter/material.dart';
import 'package:table_now_app/custom/util/navigation/custom_navigation_util.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/view/map/storebooking.dart'; // 클래스명 확인 필요

class StoreDetailSheet extends StatelessWidget {
  final Store store;
  final String? distance;

  const StoreDetailSheet(
    this.store, {
    super.key,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            store.store_description ?? "매장 이름 없음",
            style: TextStyle(
              color: p.primary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12),

          if (distance != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.near_me,
                    size: 18,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "내 위치에서 $distance",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

          _buildInfoRow(
            Icons.location_on_outlined,
            store.store_address ?? "주소 정보 없음",
          ),
          _buildInfoRow(
            Icons.phone_outlined,
            store.store_phone ?? "전화 정보 없음",
          ),
          _buildInfoRow(
            Icons.access_time_outlined,
            "${store.store_open_time ?? "-"} ~ ${store.store_close_time ?? "-"}",
          ),

          SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                CustomNavigationUtil.to(
                  context,
                  StoreBookingInfoScreen(store: store),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                "매장 예약",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
