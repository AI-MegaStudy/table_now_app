import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config.dart';
import 'package:table_now_app/model/payment.dart';
import 'package:http/http.dart' as http;

class PaymentResponse {
  final int? pay_id;
  final int total_count;
  final int reserve_seq;
  final int store_seq;
  final int menu_seq;
  final int? option_seq;
  final int total_quantity;
  final int total_pay;
  final String menu_name;
  final String store_description;
  final String? option_name;
  final String? menu_image;

  PaymentResponse({
    this.pay_id,
    required this.total_count,
    required this.reserve_seq,
    required this.store_seq,
    required this.menu_seq,
    this.option_seq,
    required this.total_quantity,
    required this.total_pay,
    required this.menu_name,
    required this.store_description,
    this.option_name,
    this.menu_image,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      pay_id: json['pay_id'],
      total_count: json['total_count'],
      reserve_seq: json['reserve_seq'],
      store_seq: json['store_seq'],
      menu_seq: json['menu_seq'],
      option_seq: json['option_seq'],
      total_quantity: json['total_quantity'],
      total_pay: json['total_pay'],
      menu_name: json['menu_name'],
      store_description: json['store_description'],
      option_name: json['option_name'],
      menu_image: json['menu_image'],
    );
  }
}

class PaymentListAsyncNotifier extends AsyncNotifier<List<PaymentResponse>> {
  int _reserve_seq = 0;
  int _total_payment = 0;
  late final String url;
  final String error = '';

  @override
  FutureOr<List<PaymentResponse>> build() async {
    url = getApiBaseUrl();
    return [];
  }

  int get total_payment => _total_payment;

  // id가 있다면 특정 payment만 가져온다.
  // 유저의 payments를 전부 가져온다.
  Future<void> fetchData(int id) async {
    // Get Data from Backend
    if (_reserve_seq != id) {
      _total_payment = 0;
      _reserve_seq = id;

      await Future.delayed(Duration(seconds: 1));
      final uri = Uri.parse('$url/api/pay/select_group_by_reserve/${id}');
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception("데이터 로딩 실패: ${response.statusCode}");
      }
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      final List results = jsonData["results"];

      // 총 가격을 뽑는다.
      for (final pay in results) {
        _total_payment += pay['total_pay'] as int;
        print(pay['menu_image']);
      }

      state = AsyncValue.data(results.map((data) => PaymentResponse.fromJson(data)).toList());
    }
  }

  // id가 있다면 특정 payment만 가져온다.
  // 유저의 payments를 전부 가져온다.
  // Future<void> refreshData(int? id) async {
  //   if (customerSeq == null)
  //     state = AsyncValue.error(Exception('401: no access'), StackTrace.empty);
  //   else
  //     state = AsyncValue.data(await _fetchData(id));
  // }

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
  Future<void> addData(PaymentResponse payment) async {
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
  Future<void> updateData(PaymentResponse payment) async {
    final currentPayment = state.value ?? [];

    // 업데이트
    final updatedList = currentPayment.map((p) {
      return p.reserve_seq == payment.reserve_seq ? payment : p;
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

  // // 유저의 payment를 지운다
  // Future<void> deleteData(int id) async {
  //   final currentPayment = state.value ?? [];

  //   // 낙관적 업데이트
  //   final updatedList = currentPayment.where((m) => m.pay_id != id).toList();
  //   state = AsyncValue.data(updatedList);

  //   try {
  //     // Delete
  //     final response = await http.delete(Uri.parse('...'));
  //     if (response.statusCode != 200) {
  //       throw Exception("데이터 로딩 실패: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     // 실패 시 원래 상태로 복구
  //     state = AsyncValue.data(currentPayment);
  //     rethrow;
  //   }
  // }
}

//    final r = ref.watch(authNotifierProvider);

final paymentListAsyncNotifierProvider = AsyncNotifierProvider.autoDispose<PaymentListAsyncNotifier, List<PaymentResponse>>(
  PaymentListAsyncNotifier.new,
);
