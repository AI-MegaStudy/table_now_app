import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_now_app/model/payment.dart';
import 'package:http/http.dart' as http;
import 'package:table_now_app/vm/auth_notifier.dart';



class PaymentAsyncNotifier extends AsyncNotifier<List<Payment>>{
  int? customerSeq;

  @override
  FutureOr<List<Payment>> build() async {
    
    // Payment는 기본적으로 유저ID가 required됨. 
    // 요청할때 유저가 없다면 return []
    final authState = ref.watch(authNotifierProvider);   
    if (authState.customer==null) return [];
    
    customerSeq = authState.customer!.customerSeq;
    return await fetchData(null);
  }

  // id가 있다면 특정 payment만 가져온다. 
  // 유저의 payments를 전부 가져온다.
  Future<List<Payment>> fetchData(int? id) async {
    
    print('=====customerSeq => $customerSeq');

    // Get Data from Backend
      final uri = Uri.parse('https://zeushahn.github.io/Test/movies.json');
      final response = await http.get(uri);
      if(response.statusCode != 200){
        throw Exception( "데이터 로딩 실패: ${response.statusCode}");
      }
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      final List results = jsonData["results"];
   
      return results.map((data)=>Payment(
      pay_id: 1,
      reserve_seq: 1, 
      store_seq: 1, 
      menu_seq: 1, 
      pay_quantitiy: 1, 
      pay_amount: 1)).toList();  


  }

  // 유저의 Payment를 추가 한다.
  Future<void> addData(Payment payment) async {
    final currentPayment = state.value ?? [];
    state = AsyncValue.data([...currentPayment, payment]);
    
    try {
      // Insert
      final response = await http.post(Uri.parse('...'));
      if(response.statusCode != 200){
        throw Exception( "데이터 로딩 실패: ${response.statusCode}");
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
      return p.pay_id == payment.pay_id ? payment :p ;
    }).toList();
    
    state = AsyncValue.data(updatedList);
    
    try {
      // Update 
      final response = await http.put(Uri.parse('...'));
      if(response.statusCode != 200){
        throw Exception( "데이터 로딩 실패: ${response.statusCode}");
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
      if(response.statusCode != 200){
        throw Exception( "데이터 로딩 실패: ${response.statusCode}");
      }

    } catch (e) {
      // 실패 시 원래 상태로 복구
      state = AsyncValue.data(currentPayment);
      rethrow;
    }
  }
}

//    final r = ref.watch(authNotifierProvider);
final paymentAsyncNotifierProvider = AsyncNotifierProvider<PaymentAsyncNotifier,List<Payment>>(
 PaymentAsyncNotifier.new 
  
  
);

