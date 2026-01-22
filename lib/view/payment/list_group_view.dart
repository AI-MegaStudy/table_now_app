import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_now_app/custom/custom.dart';
import 'package:table_now_app/theme/app_colors.dart';

import 'package:table_now_app/view/payment/purchase/toss_payment.dart';
import 'package:table_now_app/view/payment/purchase/toss_result_page.dart';
import 'package:table_now_app/vm/payment_list_notifier.dart';

import 'package:tosspayments_widget_sdk_flutter/model/paymentData.dart';

final Map<String, dynamic> receiveData = {
  "reserve": {
    "store_seq": 1,
    "customer_seq": 1,
    "reserve_capacity": "4",
    "reserve_tables": "1,2,3",
    "weather_datetime": "2026-01-19 00:00:00",
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

class PaymentListGroupView extends ConsumerStatefulWidget {
  const PaymentListGroupView({super.key});

  @override
  ConsumerState<PaymentListGroupView> createState() =>
      _PaymentListGroupViewState();
}

class _PaymentListGroupViewState extends ConsumerState<PaymentListGroupView> {
  final double cardBoxHeight = 80;
  final double detailBoxHeight = 170;
  final storage = GetStorage();
  late PurchaseReserve? purchaseReserve = null;
  late Map<String, dynamic>? items;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialize();
  }

  // 초기화 작업
  // storage에 reserve/reserve2, order테이터가 저장되있음.
  // 3개의 storage에 값이 없으면 진입 안되게 처리
  // storage데이터로 결제 정보 보여주기
  //  - 따로 DB에서 메뉴/option 정보를 가져올 필요는 없음.
  //  - 필요 정보를 storage에 저장 해야 함.
  void _initialize() async {
    // Notifier
    print('================_initialize================');
    final ppp = ref.read(paymentListAsyncNotifierProvider.notifier);
  
    // 기존에 미결제 정보가 있는 지 확인. 미결제 정보가 있다면,

    // reserve 정보를 storage 부터 가져옴.
    final data = storage.read<Map<String, dynamic>>('reserve');
    final data2 = storage.read<Map<String, dynamic>>('reserve2');

    // menu 정보를 storage부터 가져옴.
    items = storage.read<Map<String, dynamic>>('order');

    try {
      if (data != null) {
        // Reserve정보를 Object에 담기
        purchaseReserve = PurchaseReserve.fromJson(data);

        if (purchaseReserve != null) {
          purchaseReserve!.reserve_tables = data2 != null
              ? data2['reserve_tables']
              : '';
          // Reserve 생성
          print('================_initialize: CurrentStatus ${ppp.isInPurchaseProcess}');
        
          if(ppp.isInPurchaseProcess == 0) await ppp.insertReserve(purchaseReserve!);
          // 생성된 reserve_seq를 Object에저장.
          purchaseReserve!.reserve_seq = ppp.reserve_seq;
          purchaseReserve!.payment_status = 'PROCESS';

          // 데이터를
          ref
              .read(paymentListAsyncNotifierProvider.notifier)
              .setData(purchaseReserve!, items!, 20000);
        }
      }
    } catch (error) {
      print('====== $error');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (purchaseReserve == null) {
      CustomNavigationUtil.back(context);
      return Scaffold(
        backgroundColor: p.background,
        appBar: AppBar(title: Text('결제 하기')),
        body: Center(child: Text('Reserve is empty')),
      );
    }
    final paymentValue = ref.read(paymentListAsyncNotifierProvider.notifier);
    final paymentState = ref.watch(paymentListAsyncNotifierProvider);
    // paymentValue.setReserve(purchaseReserve!);
    // if(items != null) paymentValue.setItems(items!);
    final menus = items!['menus'].values.toList();
    final menus_seq = items!['menus'].keys.toList();
    print('================ CurrentStatus: ${paymentValue.isInPurchaseProcess}');
    // Show message
    
    /*
static void showSuccessDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'OK',
    bool barrierDismissible = false,
  }) 
    */
    
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(title: Text('결제 하기')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child:  
             

          
          paymentState.when(
            data: (data) => data.length == 0
                ? const CircularProgressIndicator()
                : Column(
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
                                  Text(
                                    '예약 번호: ${purchaseReserve!.reserve_seq}',
                                  ),
                                  Text(
                                    '예약 날짜: ${purchaseReserve!.reserve_date}',
                                  ),
                                  Text(
                                    '총 인원: ${purchaseReserve!.reserve_capacity}',
                                  ),
                                  Text(
                                    '테이블 번호: ${purchaseReserve!.reserve_tables}',
                                  ),
                                  Text('상점: 상점 이름'),
                                ],
                              ),
                            ),

                            textSubTitle('주문 메뉴 정보'),

                            SingleChildScrollView(
                              child: Container(
                                color: p.background,
                                height: 400,
                                child: ListView.builder(
                                  itemCount: menus.length,
                                  itemBuilder: (context, index) {
                                    final menu = menus[index];
                                    final menu_seq = menus_seq[index];

                                    // menu[index]['options'].values.map((d)=>Text("${d['price']}")).toList() as List<Widget>
                                    final options = menu['options'].values
                                        .toList();
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Card(
                                          child: Row(
                                            spacing: 10,
                                            children: [
                                              Text("ID: ${menu_seq}"),
                                              Text("Price: ${menu['price']}"),
                                              Text("Count: ${menu['count']}"),

                                              // menu['options'] != null
                                              // ? Column( children: [
                                              //   Text("${menu['options'].values}"),
                                              // ]
                                              // )
                                              // : Text(''),
                                            ],
                                          ),
                                        ),
                                        menu['options'] != null
                                            ? Card(
                                                child: Column(
                                                  children: List.generate(
                                                    options.length,
                                                    (i) => _optionMenus(
                                                      options[i],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Text(''),
                                      ],
                                    );

                                    // Card(
                                    //   child: Row(
                                    //     spacing: 10,
                                    //     crossAxisAlignment:
                                    //         CrossAxisAlignment.center,

                                    //     children: [
                                    //       // Image.network('https://cheng80.myqnapcloud.com/tablenow/${data[index].menu_image}', width: 50),
                                    //       Image.network(
                                    //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSHP5M5s5eCfRsmmEp0KVGz7E1mPYbbRz7dqg&s}',
                                    //         height: 50,
                                    //       ),
                                    //       Column(
                                    //         crossAxisAlignment:
                                    //             CrossAxisAlignment.start,

                                    //         children: [
                                    //           // data[index].menu_image != null ? Text(data[index].menu_image!) : Text(''),
                                    //           // Text('예약번호: ${data[index].reserve_seq}'),
                                    //           // Text("전체갯수: ${data[index].total_count}"),
                                    //           Text(
                                    //             '${data[index].menu_name}',
                                    //             style: TextStyle(
                                    //               fontSize: 15,
                                    //               fontWeight: FontWeight.bold,
                                    //             ),
                                    //           ),
                                    //           Text(
                                    //             "${data[index].option_name != null ? data[index].option_name : ''}",
                                    //             style: TextStyle(
                                    //               fontSize: 11,
                                    //               color: Colors.grey[700],
                                    //             ),
                                    //           ),
                                    //         ],
                                    //       ),

                                    //       SizedBox(
                                    //         width:
                                    //             MediaQuery.of(
                                    //               context,
                                    //             ).size.width /
                                    //             1.8,

                                    //         child: Column(
                                    //           crossAxisAlignment:
                                    //               CrossAxisAlignment.end,
                                    //           mainAxisAlignment:
                                    //               MainAxisAlignment.end,
                                    //           children: [
                                    //             Text(
                                    //               "${data[index].total_count}개",
                                    //             ),
                                    //             Text(
                                    //               "금액: ${CustomCommonUtil.formatPrice(data[index].total_pay)}",
                                    //             ),
                                    //           ],
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // );
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
                              // '결제금액: ${CustomCommonUtil.formatPrice(totalPrice)}',
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
                  ),

            error: (error, stackTrace) => Text('ERROR: $error'),
            loading: () => const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  // == widget
  Widget _optionMenus(Map<String, dynamic> option) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 10,
      children: [
        Text("수량: ${option['count']}"),
        Text("가격: ${option['price']}"),
      ],
    );
  }

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

  // Widget subOrderInfoBox(String storeName) {
  //   return Container(
  //     padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         textSubTitle('주문 정보'),
  //         Text('예약 번호: ${paymentValue.reserve_seq}'),
  //         Text('예약 날짜: 예약된 날짜'),
  //         Text('총 인원: '),
  //         Text('테이블 번호: '),
  //         Text('상점: ${storeName}'),
  //       ],
  //     ),
  //   );
  // }

  Widget paymentCardType(
    BuildContext context,
    String imgUrl,
    String cardName,
    PaymentListAsyncNotifier paymentValue,
    p,
  ) {
    final prefix = 'toss-${purchaseReserve!.reserve_seq}';
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
          // await paymentValue.purchase();
          // 결제 진행중. 
          paymentValue.purchaseUpdate({'payment_key':'payment_key','payment_status':'PROCESS','reserve_seq':0});


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
