import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/custom/utils_core.dart';
import 'package:table_now_app/model/payment.dart';
import 'package:table_now_app/vm/payment_notifier.dart';

class PaymentListView extends ConsumerWidget {
  const PaymentListView({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final paymentState = ref.watch(paymentAsyncNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('payment list'),
        actions: [
          IconButton(
            onPressed: () => 
              ref.read(paymentAsyncNotifierProvider.notifier).purchase([
                Payment(reserve_seq: 5, store_seq: 5, menu_seq: 5, pay_quantity: 2, pay_amount: 500, created_at: DateTime.now()),
                Payment(reserve_seq: 5, store_seq: 5, menu_seq: 5, pay_quantity: 2, pay_amount: 500, created_at: DateTime.now())
              ]),
              icon: Icon(Icons.payment))
        ],
      ),
      body: Center(
        child: paymentState.when(
          data: (data) => data.length>0 
          ? ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: (){
                  // 
                },
                child: Card(
                  child: Row(
                    spacing: 5,
                  
                    children: [
                      Icon(Icons.payment,size:40),
                
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("PayID: ${data[index].pay_id}"),
                          Text("Price: ${CustomCommonUtil.formatPrice(data[index].pay_amount)}"),
                         
                        ],
                        
                      ),
                      Text("Date : ${data[index].created_at}"),
                    ],
                  )
                ),
              );
            },
          )
          : Text('no data')
          , 
          error: (error, stackTrace) => Text('ERROR: $error'), 
          loading: ()=> Text('....loading')
        ),
      )

    );
  }
}