import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/model/payment.dart';
import 'package:http/http.dart' as http;
import 'package:table_now_app/vm/auth_notifier.dart';

class PaymentAsyncNotifier extends AsyncNotifier<List<Payment>> {
  int? customerSeq;
  final String url = 'http://192.168.219.105:8000';
  final String error = '';
  @override
  FutureOr<List<Payment>> build() async {
    // Payment는 기본적으로 유저ID가 required됨.
    // 요청할때 유저가 없다면 return []
    final authState = ref.watch(authNotifierProvider);
    if (authState.customer == null) {
      state = AsyncValue.error(Exception('401: no access'), StackTrace.empty);
      return [];
    }
    customerSeq = authState.customer!.customerSeq;
    return await _fetchData(null);
  }

  // id가 있다면 특정 payment만 가져온다.
  // 유저의 payments를 전부 가져온다.
  Future<List<Payment>> _fetchData(int? id) async {
    print('=====customerSeq => $customerSeq');

    // Get Data from Backend
    final uri = Uri.parse('$url/api/pay');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception("데이터 로딩 실패: ${response.statusCode}");
    }
    final jsonData = json.decode(utf8.decode(response.bodyBytes));
    final List results = jsonData["results"];

    for (final i in results) {
      print('${i}');
    }

    return results.map((data) => Payment.fromJson(data)).toList();
  }

  // id가 있다면 특정 payment만 가져온다.
  // 유저의 payments를 전부 가져온다.
  Future<void> refreshData(int? id) async {
    if (customerSeq == null)
      state = AsyncValue.error(Exception('401: no access'), StackTrace.empty);
    else
      state = AsyncValue.data(await _fetchData(id));
  }

  Future<void> purchase(List<Payment> payments) async {
    final response = await http.post(
      Uri.parse('$url/api/pay/insert'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode([
        Payment(reserve_seq: 1, store_seq: 1, menu_seq: 5, pay_quantity: 2, pay_amount: 500, created_at: DateTime.now()).toJson(),
        Payment(reserve_seq: 1, store_seq: 1, menu_seq: 5, pay_quantity: 2, pay_amount: 500, created_at: DateTime.now()).toJson(),
      ]),
    );
    if (response.statusCode != 200) {
      throw Exception("데이터 로딩 실패: ${response.statusCode}");
    }
  }

  // 유저의 Payment를 추가 한다.
  Future<void> addData(Payment payment) async {
    final currentPayment = state.value ?? [];
    state = AsyncValue.data([...currentPayment, payment]);

    try {
      // Insert
      final response = await http.post(Uri.parse('...'));
      if (response.statusCode != 200) {
        throw Exception("데이터 로딩 실패: ${response.statusCode}");
      }
      // final jsonData = json.decode(utf8.decode(response.bodyBytes));
      // final List results = jsonData["results"];
    } catch (e) {
      state = AsyncValue.data(currentPayment);
      rethrow;
    }
  }

  // 유저의 payment를 업데이트 한다.
  Future<void> updateData(Payment payment) async {
    final currentPayment = state.value ?? [];

    // 업데이트
    final updatedList = currentPayment.map((p) {
      return p.pay_id == payment.pay_id ? payment : p;
    }).toList();

    state = AsyncValue.data(updatedList);

    try {
      // Update
      final response = await http.put(Uri.parse('...'));
      if (response.statusCode != 200) {
        throw Exception("데이터 로딩 실패: ${response.statusCode}");
      }
    } catch (e) {
      // 실패 시 원래 상태로 복구
      state = AsyncValue.data(currentPayment);
      rethrow;
    }
  }

  // 유저의 payment를 지운다
  Future<void> deleteData(int id) async {
    final currentPayment = state.value ?? [];

    // 낙관적 업데이트
    final updatedList = currentPayment.where((m) => m.pay_id != id).toList();
    state = AsyncValue.data(updatedList);

    try {
      // Delete
      final response = await http.delete(Uri.parse('...'));
      if (response.statusCode != 200) {
        throw Exception("데이터 로딩 실패: ${response.statusCode}");
      }
    } catch (e) {
      // 실패 시 원래 상태로 복구
      state = AsyncValue.data(currentPayment);
      rethrow;
    }
  }
}

//    final r = ref.watch(authNotifierProvider);
final paymentAsyncNotifierProvider = AsyncNotifierProvider<PaymentAsyncNotifier, List<Payment>>(PaymentAsyncNotifier.new);
