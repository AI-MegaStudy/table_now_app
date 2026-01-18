import 'package:flutter/material.dart';
import 'package:table_now_app/model/store.dart';

class StoreDetailSheet extends StatelessWidget {
  final Store store;
  const StoreDetailSheet(this.store, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //     Text(
          // //store.store_description,
          //       style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          //     ),
          const SizedBox(height: 8),
          Text(store.store_address),
          Text(store.store_phone),
          Text("${store.store_open_time} - ${store.store_close_time}"),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () {}, child: const Text("이 매장 예약하기")),
        ],
      ),
    );
  }
}
