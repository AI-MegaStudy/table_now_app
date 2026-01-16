import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/custom/custom.dart';
import 'package:table_now_app/vm/payment_notifier.dart';

class PaymentListView extends ConsumerWidget {
  const PaymentListView({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final paymentState = ref.watch(paymentAsyncNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('payment list')
      ),
      body: Center(
        child: paymentState.when(
          data: (data) => data.length>0 
          ?ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return Card(
                child: Row(
                  spacing: 5,
                  children: [
                    Text("PayID: ${data[index].pay_id}"),
                    Text("Price: ${data[index].pay_amount}"),
                  ],
                )
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