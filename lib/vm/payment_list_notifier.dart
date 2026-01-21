import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config.dart';
import 'package:table_now_app/model/customer.dart';
import 'package:table_now_app/model/payment.dart';
import 'package:http/http.dart' as http;
import 'package:table_now_app/utils/utils.dart';
import 'package:table_now_app/vm/reservation_notifier.dart';

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

Map<String, dynamic> receiveData = {
  "reserve": {
    "store_seq": 1,
    "customer_seq": 1,
    "reserve_capacity": "4",
    "reserve_tables": "1,2,3",
    "reserve_date": "2026-01-16 00:00:00",
    "payment_key": "payment_key",
    "payment_status": "PROCESS",
  },
  "items": {
    "menus": {
      "1": {
        "count": 2,
        "options": {
          "1": {"count": 1, "price": 3000},
          "2": {"count": 1, "price": 500},
        },
        "price": 10000,
        "date": "2026-01-20 02:00:00",
      },
      "2": {
        "count": 2,
        "options": {
          "1": {"count": 1, "price": 3000},
          "2": {"count": 3, "price": 500},
        },
        "price": 20000,
        "date": "2026-01-20 02:00:20",
      },
      "3": {
        "count": 1,
        "options": {},
        "price": 8000,
        "date": "2026-01-20 02:00:30",
      },
    },
  },
};

class PaymentListAsyncNotifier extends AsyncNotifier<List<PaymentResponse>> {
  late final String url = getApiBaseUrl();
  final String error = '';

  int _reserve_seq = 0;
  int _total_payment = 0;
  bool _isPurchaseInsertSuccess = false;

  // decrypt key
  late String _k = '';
  // iv
  late String _iv = '';

  // customer seq
  late final int? _customerSeq;

  // =======================================
  int get total_payment => _total_payment;
  String get k => _k;
  String get iv => _iv;
  int get reserve_seq => _reserve_seq;

  @override
  FutureOr<List<PaymentResponse>> build() async {
    // Get CustomerSeq from Storage
    final Customer? customer = CustomerStorage.getCustomer();
    if (customer != null) {
      _customerSeq = customer.customerSeq;
    }
    await getKey();
    // Get Reservation OBJ

    // Need MenuList picked
    // 메뉴리스트를 받는다. 어떤 형식?

    return [];
  }

  // decrypt key, iv를 가져오기 위한 부분.
  Future<void> getKey() async {
    final uri = Uri.parse('$url/api/pay/get_toss_client_key');
    final response = await http.post(uri);
    if (response.statusCode != 200) {
      throw Exception("데이터 로딩 실패: ${response.statusCode}");
    }
    final jsonData = json.decode(utf8.decode(response.bodyBytes));
    final result = jsonData["result"];
    _k = result["k"]!;
    _iv = result["iv"]!;
  }

  // id가 있다면 특정 payment만 가져온다.
  // 유저의 payments를 전부 가져온다.
  Future<void> fetchData(int id) async {
    // Get Data from Backend
    if (_reserve_seq != id) {
      try {
        // _total_payment = 0;
        // _reserve_seq = id;

        final uri = Uri.parse('$url/api/pay/select_group_by_reserve/${id}');
        final response = await http.get(uri);
        if (response.statusCode != 200) {
          throw Exception("데이터 로딩 실패: ${response.statusCode}");
        }
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        final List results = jsonData["results"];

        // 총 가격을 뽑는다.
        for (final pay in results) _total_payment += pay['total_pay'] as int;

        state = AsyncValue.data(
          results.map((data) => PaymentResponse.fromJson(data)).toList(),
        );
      } catch (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      }
  
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

  // Future<void> purchase(Map<String,dynamic> data) async {
  Future<void> purchase() async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/pay/purchase'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(receiveData),
      );
      if (response.statusCode != 200) {
        throw Exception("지불 실패(1): ${response.statusCode}");
      } else {
        // 결과가 성공했음. reserve id를 받아서 저장.
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        final results = jsonData["results"];
        if(results == "Error") {
          throw Exception("지불 실패(2): ${response.statusCode}");
        }else{
          print('${results['reserve_seq']}');
          _reserve_seq = results['reserve_seq'];
          print('================== xxxxx $_reserve_seq');

          _isPurchaseInsertSuccess = true;
        }
      
      }
    } catch (error, stackTrace) {
      _isPurchaseInsertSuccess = false;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> purchaseUpdate(Map<String,dynamic> data) async {
    try{
      data['reserve_seq'] = _reserve_seq;
      print("======================= $_reserve_seq");
      // reserve_seq를 업데이트 시켜야 함. 
      //payment_key:str, payment_status:str, reserve_seq:int
       final response = await http.post(
        Uri.parse('$url/api/pay/purchase/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
     
      if (response.statusCode != 200) {
        throw Exception("P업데이트 실패(1): ${response.statusCode}");
      } else {
        // 결과가 성공했음. reserve id를 받아서 저장.
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        final result = jsonData["result"];
        if(result == "Error") {
          throw Exception("P업데이트 실패(2): ${response.statusCode}");
        }
      }
      return true;
    }catch(error){
      //
      print('===== ERROR: $error');
      return false;
    }
  }

  // 유저의 Payment를 추가 한다.
  Future<void> addData(PaymentResponse payment) async {
    final currentPayment = state.value ?? [];
    state = AsyncValue.data([...currentPayment, payment]);

    try {
      // Insert
      final response = await http.post(
        Uri.parse('$url/api/pay/insert'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode([
          Payment(
            reserve_seq: 1,
            store_seq: 1,
            menu_seq: 5,
            pay_quantity: 2,
            pay_amount: 500,
            created_at: DateTime.now(),
          ).toJson(),
          Payment(
            reserve_seq: 1,
            store_seq: 1,
            menu_seq: 5,
            pay_quantity: 2,
            pay_amount: 500,
            created_at: DateTime.now(),
          ).toJson(),
        ]),
      );
      if (response.statusCode != 200) {
        throw Exception("데이터 추가 실패: ${response.statusCode}");
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

  Future<String> getDecodedData() async {
    print(await http.get(Uri.parse(url + "api/pay/get_toss_client_key")));
    return 'aaaa';
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

final paymentListAsyncNotifierProvider =
    AsyncNotifierProvider.autoDispose<
      PaymentListAsyncNotifier,
      List<PaymentResponse>
    >(PaymentListAsyncNotifier.new);
