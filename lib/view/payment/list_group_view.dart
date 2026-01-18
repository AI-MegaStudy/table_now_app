import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/custom/utils_core.dart';
import 'package:table_now_app/view/payment/purchase/toss_home.dart';
import 'package:table_now_app/view/payment/purchase/toss_payment.dart';
import 'package:table_now_app/vm/payment_list_notifier.dart';
import 'package:table_now_app/vm/payment_notifier.dart';
import 'package:tosspayments_widget_sdk_flutter/model/paymentData.dart';

class PaymentListGroupView extends ConsumerWidget {
  const PaymentListGroupView({super.key});
  final int reserve_seq = 1;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // reseve_seq로 초기 로딩.
    final paymentValue = ref.read(paymentListAsyncNotifierProvider.notifier);
    paymentValue.fetchData(reserve_seq);
    final paymentState = ref.watch(paymentListAsyncNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: Text('결제 하기')),
      body: Center(
        child: paymentState.when(
          data: (data) => data.length > 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    Text('Toatal Payment: ${CustomCommonUtil.formatPrice(paymentValue.total_payment)}', style: TextStyle(fontSize: 20)),

                    Container(
                      height: 250,
                      child: Column(
                        children: [
                          paymentCardType(context, 'image', '토스 페이', paymentValue.total_payment),
                          paymentCardType(context, 'image', '신용 첵크카드', paymentValue.total_payment),
                          paymentCardType(context, 'image', '카카오 페이', paymentValue.total_payment),
                          paymentCardType(context, 'image', '네이버 페이', paymentValue.total_payment),
                          // SizedBox(
                          //   width: 350,
                          //   child: ElevatedButton.icon(
                          //     onPressed: () {
                          //       //
                          //     },

                          //     style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                          //     // icon: Icon(Icons.card_giftcard),
                          //     label: Row(spacing: 5, children: [Icon(Icons.card_giftcard), Text('토스 페이')]),
                          //   ),
                          // ),
                          // SizedBox(
                          //   width: 350,
                          //   child: ElevatedButton.icon(
                          //     onPressed: () {
                          //       //
                          //     },
                          //     style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                          //     // icon: Icon(Icons.card_giftcard),
                          //     label: Row(spacing: 5, children: [Icon(Icons.card_giftcard), Text('신용 첵크카드')]),
                          //   ),
                          // ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                // Image.network('https://cheng80.myqnapcloud.com/tablenow/${data[index].menu_image}', width: 50),
                                Image.network(
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSHP5M5s5eCfRsmmEp0KVGz7E1mPYbbRz7dqg&s}',
                                  height: 50,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    // data[index].menu_image != null ? Text(data[index].menu_image!) : Text(''),
                                    // Text('예약번호: ${data[index].reserve_seq}'),
                                    // Text("전체갯수: ${data[index].total_count}"),
                                    Text('${data[index].menu_name}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                    Text(
                                      "${data[index].option_name != null ? data[index].option_name : ''}",
                                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                                Text("${data[index].total_count}개"),
                                Text("${CustomCommonUtil.formatPrice(data[index].total_pay)}"),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : Text('no data'),
          error: (error, stackTrace) => Text('ERROR: $error'),
          loading: () => const CircularProgressIndicator(),
        ),
      ),
    );
  }

  // == widget
  Widget paymentCardType(BuildContext context, String imgUrl, String cardName, int totalPayment) {
    PaymentData data = PaymentData(
      paymentMethod: '카드',
      orderId: 'tosspaymentsFlutter_1768742871169',
      orderName: '예약번호11',
      amount: totalPayment,
      // customerName: customerName,
      // customerEmail: customerEmail,
      successUrl: Constants.success,
      failUrl: Constants.fail,
    );
    return SizedBox(
      width: 350,
      child: ElevatedButton.icon(
        onPressed: () {
          CustomNavigationUtil.to(context, TossPayment(data: data));
        },
        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
        // icon: Icon(Icons.card_giftcard),
        label: Row(spacing: 5, children: [Icon(Icons.card_giftcard), Text(cardName)]),
      ),
    );
  }
}
