import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/custom/utils_core.dart';
import 'package:table_now_app/model/payment.dart';
import 'package:table_now_app/vm/payment_list_notifier.dart';
import 'package:table_now_app/vm/payment_notifier.dart';

class PaymentListGroupView extends ConsumerWidget {
  const PaymentListGroupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.read(PaymentListAsyncNotifierProvider.notifier).fetchData(1);
    // With Reserve_seq
    final paymentState = ref.watch(paymentListAsyncNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('payment list group by reserve seq'),
        actions: [
          ElevatedButton(
            onPressed: () {
              //
              ref.read(paymentListAsyncNotifierProvider.notifier).fetchData(1);
            },
            child: Text('1111'),
          ),
          ElevatedButton(
            onPressed: () {
              //
              ref.read(paymentListAsyncNotifierProvider.notifier).fetchData(2);
            },
            child: Text('2222'),
          ),
        ],
      ),
      body: Center(
        child: paymentState.when(
          data: (data) => data.length > 0
              ? ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        //
                      },
                      child: Card(
                        child: Row(
                          spacing: 5,

                          children: [
                            Icon(Icons.payment, size: 40),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('예약번호: ${data[index].reserve_seq}'),
                                Text("전체갯수: ${data[index].total_count}"),
                                Text("Total Quantity: ${data[index].total_count}"),

                                Text("Total Price: ${CustomCommonUtil.formatPrice(data[index].total_pay)}"),
                                Text("Option Menu: ${data[index].option_name != null ? data[index].option_name : ''}"),
                                Text('메뉴: ${data[index].menu_name}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Text('no data'),
          error: (error, stackTrace) => Text('ERROR: $error'),
          loading: () => Text('....loading'),
        ),
      ),
    );
  }
}
