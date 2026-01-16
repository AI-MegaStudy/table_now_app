import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/vm/payment_notifier.dart';

class PaymentListView extends ConsumerWidget {
  const PaymentListView({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final paymentState = ref.watch(paymentAsyncNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('payment test')
      ),
      body: paymentState.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return Card(
              child: Row(
                children: [
                  Text("${data[index].pay_id}")
                ],
              )
            );
          },
        ), 
        error: (error, stackTrace) => Text('ERROR: $stackTrace'), 
        loading: ()=> Text('....loading')
      )

    );
  }
}