import 'package:flutter/material.dart';
import 'package:table_now_app/model/store.dart';

class StoreBookingInfoScreen extends StatelessWidget {
  final Store store;
  const StoreBookingInfoScreen(this.store, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(store.store_description ?? "예약하기")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "📌 ${store.store_description}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text("주소: ${store.store_address ?? "-"}"),
            const SizedBox(height: 8),
            Text("전화: ${store.store_phone ?? "-"}"),
            const SizedBox(height: 8),
            Text(
              "영업시간: ${store.store_open_time ?? "-"} ~ ${store.store_close_time ?? "-"}",
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "예약하기 진행",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
