import 'package:flutter/material.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/theme/palette_context.dart';
import 'package:table_now_app/view/map/storebooking.dart';

class StoreDetailSheet extends StatelessWidget {
  final Store store;
  const StoreDetailSheet(this.store, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
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
          // 제목/매장 이름
          Text(
            store.store_description ?? "매장 이름 없음",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12),

          // 매장 주소
          _buildInfoRow(
            Icons.location_on_outlined,
            store.store_address ?? "주소 정보 없음",
          ),

          // 전화번호
          _buildInfoRow(
            Icons.phone_outlined,
            store.store_phone ?? "전화 정보 없음",
          ),

          // 영업시간
          _buildInfoRow(
            Icons.access_time_outlined,
            "${store.store_open_time ?? "-"} ~ ${store.store_close_time ?? "-"}",
          ),

          SizedBox(height: 20),

          // 예약 버튼
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StoreBookingInfoScreen(store),
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
                "매장 예약",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          SizedBox(height: 16),
        ],
      ),
    );
  }

  // 세로 정렬 정보 Row
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

/*
변화없음-stateless
수동 단순 전달
 */
