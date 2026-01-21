import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/custom/custom.dart';
import 'package:table_now_app/theme/app_colors.dart';

import 'package:table_now_app/view/payment/purchase/toss_payment.dart';
import 'package:table_now_app/view/payment/purchase/toss_result_page.dart';
import 'package:table_now_app/vm/payment_list_notifier.dart';
import 'package:tosspayments_widget_sdk_flutter/model/paymentData.dart';

class PaymentListGroupView extends ConsumerWidget {
  const PaymentListGroupView({super.key});
  final int reserve_seq = 1;
  final double cardBoxHeight = 80;
  final double detailBoxHeight = 170;

  /*
var _selectedDate = DateTime(2026, 1, 25);
final success = await ref
        .read(weatherNotifierProvider.notifier)
        .fetchWeatherFromApi(
          storeSeq: _selectedStore!.store_seq,
          targetDate: _selectedDate,
          overwrite: _overwrite,
        );

  */
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // reseve_seq로 초기 로딩.
    final paymentValue = ref.read(paymentListAsyncNotifierProvider.notifier);  
    final paymentState = ref.watch(paymentListAsyncNotifierProvider);
paymentValue.fetchData(reserve_seq);
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(title: Text('결제 하기')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: paymentState.when(
            data: (data) => data.length > 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 메뉴정보및 주문 정보 박스
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height -
                            detailBoxHeight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // subOrderInfoBox(data[0].store_description),
                            textSubTitle('주문 정보'),

                            Container(
                              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Column(
                                spacing: 3,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('예약 번호: $reserve_seq'),
                                  Text('예약 날짜: 예약된 날짜'),
                                  Text('총 인원: '),
                                  Text('테이블 번호: '),
                                  Text('상점: ${data[0].store_description}'),
                                ],
                              ),
                            ),

                            textSubTitle('주문 메뉴 정보'),

                            SingleChildScrollView(
                              child: Container(
                                color: p.background,
                                height: 400,
                                child: ListView.builder(
                                  itemCount: data.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      child: Row(
                                        spacing: 10,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,

                                        children: [
                                          // Image.network('https://cheng80.myqnapcloud.com/tablenow/${data[index].menu_image}', width: 50),
                                          Image.network(
                                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSHP5M5s5eCfRsmmEp0KVGz7E1mPYbbRz7dqg&s}',
                                            height: 50,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,

                                            children: [
                                              // data[index].menu_image != null ? Text(data[index].menu_image!) : Text(''),
                                              // Text('예약번호: ${data[index].reserve_seq}'),
                                              // Text("전체갯수: ${data[index].total_count}"),
                                              Text(
                                                '${data[index].menu_name}',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "${data[index].option_name != null ? data[index].option_name : ''}",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),

                                          SizedBox(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width /
                                                1.8,

                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "${data[index].total_count}개",
                                                ),
                                                Text(
                                                  "금액: ${CustomCommonUtil.formatPrice(data[index].total_pay)}",
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 맨 밑에 메뉴 박스
                      Container(
                        height: cardBoxHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.blue[100],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '결제금액: ${CustomCommonUtil.formatPrice(paymentValue.total_payment)}',
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 5,
                            ),
                            paymentCardType(
                              context,
                              'image', // https://en.komoju.com/wp-content/uploads/2023/09/Toss-logo-1.png
                              '결제 하기',
                              paymentValue,
                              p,
                            ),

                          ],
                        ),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
            error: (error, stackTrace) => Text('ERROR: $error'),
            loading: () => const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  // == widget
  Widget textSubTitle(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          //
        ),
      ),
    );
  }

  Widget subOrderInfoBox(String storeName) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textSubTitle('주문 정보'),
          Text('예약 번호: $reserve_seq'),
          Text('예약 날짜: 예약된 날짜'),
          Text('총 인원: '),
          Text('테이블 번호: '),
          Text('상점: ${storeName}'),
        ],
      ),
    );
  }

  Widget paymentCardType(
    BuildContext context,
    String imgUrl,
    String cardName,
    PaymentListAsyncNotifier paymentValue,
    p,
  ) {
    final prefix = 'toss-$reserve_seq';
    PaymentData data = PaymentData(
      paymentMethod: '카드',
      orderId: prefix, //'tosspaymentsFlutter_1768742871169',
      orderName: '예약번호: ${prefix}',
      amount: paymentValue.total_payment,
      // customerName: customerName,
      // customerEmail: customerEmail,
      successUrl: Constants.success,
      failUrl: Constants.fail,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
      child: ElevatedButton.icon(
        onPressed: () async {

          /// 카드 결제 전 Data를 추가한다.
          await paymentValue.purchase();

          CustomNavigationUtil.to(context, TossPayment(data: data)).then((
            result,
          ) {
            if (result == -1) {
              CustomSnackBar.show(
                context,
                message: "에러가 발생했습니다. 에러코드($result)",
              );
            } else if (result != null) {
              CustomNavigationUtil.to(context, TossResultPage(result: result));
            }
          });
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          backgroundColor: p.background,
        ),
        // icon: Icon(Icons.card_giftcard),
        label: Row(
          spacing: 5,
          children: [
            imgUrl == 'image'
                ? Icon(Icons.card_giftcard, size: 25)
                : Image.network(imgUrl, width: 25),
            Text(cardName),
          ],
        ),
      ),
    );
  }

}
