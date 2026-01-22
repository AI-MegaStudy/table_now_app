import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/custom/custom.dart';
import 'package:table_now_app/theme/app_colors.dart';
import 'package:table_now_app/utils/common_app_bar.dart';
import 'package:table_now_app/view/drawer/profile_drawer.dart';
import 'package:table_now_app/view/payment/purchase/toss_payment.dart';
import 'package:table_now_app/view/payment/purchase/toss_result_page.dart';
import 'package:table_now_app/vm/menu_notifier.dart';
import 'package:table_now_app/vm/payment_list_notifier.dart';

import 'package:tosspayments_widget_sdk_flutter/model/paymentData.dart';

class PaymentListGroupView extends ConsumerStatefulWidget {
  final int totalPrice;
  const PaymentListGroupView({super.key,required this.totalPrice});

  @override
  ConsumerState<PaymentListGroupView> createState() =>
      _PaymentListGroupViewState();
}

class _PaymentListGroupViewState extends ConsumerState<PaymentListGroupView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final double cardBoxHeight = 70;
  final double detailBoxHeight = 200;
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


          if (ppp.isInPurchaseProcess == 0)
            await ppp.insertReserve(purchaseReserve!);
          // 생성된 reserve_seq를 Object에저장.
          purchaseReserve!.reserve_seq = ppp.reserve_seq;
          purchaseReserve!.payment_status = 'PROCESS';

          // 데이터를
          ref
              .read(paymentListAsyncNotifierProvider.notifier)
              .setData(purchaseReserve!, items!, widget.totalPrice);
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
        appBar: AppBar(title: Text('결제 확인')),
        body: Center(child: Text('Reserve is empty')),
      );
    }
    final paymentValue = ref.read(paymentListAsyncNotifierProvider.notifier);
    final paymentState = ref.watch(paymentListAsyncNotifierProvider);

    final menus = items!['menus'].values.toList();
    final menus_seq = items!['menus'].keys.toList();
    print(
      '================ CurrentStatus: ${paymentValue.isInPurchaseProcess}',
    );
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
      key: _scaffoldKey,
      backgroundColor: p.background,
      drawer: const ProfileDrawer(),
      appBar: CommonAppBar(
        title: Text(
          '결제하기',
          style: mainAppBarTitleStyle.copyWith(color: p.textOnPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: p.textOnPrimary),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: paymentState.when(
          data: (data) => data.length == 0
              ? Center(child: CircularProgressIndicator(color: p.primary))
              : SafeArea(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 메뉴정보및 주문 정보 박스
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                  
                            children: [
                              // subOrderInfoBox(data[0].store_description),
                              textSubTitle('주문 정보'),
                  
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: p.cardBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: p.divider),
                                ),
                                child: Column(
                                  spacing: 8,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow(Icons.confirmation_number_outlined, '예약 번호', '${purchaseReserve!.reserve_seq}', p),
                                    _buildInfoRow(Icons.calendar_today_outlined, '예약 날짜', '${purchaseReserve!.reserve_date}', p),
                                    _buildInfoRow(Icons.people_outline, '총 인원', '${purchaseReserve!.reserve_capacity}명', p),
                                    _buildInfoRow(Icons.table_restaurant_outlined, '테이블', '${purchaseReserve!.reserve_tables}', p),
                                    _buildInfoRow(Icons.store_outlined, '매장', '${purchaseReserve!.store_description}', p),
                                  ],
                                ),
                              ),
                  
                              textSubTitle('주문 메뉴 정보'),
                  
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: menus.length,
                                itemBuilder: (context, index) {
                                  final menu = menus[index];
                                  print(menu);
                                  final menu_seq = menus_seq[index];
                  
                                  // menu[index]['options'].values.map((d)=>Text("${d['price']}")).toList() as List<Widget>
                                  final options = menu['options'].values
                                      .toList();
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: p.cardBackground,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: p.divider),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                  
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Row(
                                            spacing: 12,
                                            children: [
                                              // Text("ID: ${menu_seq}"),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(
                                                  "https://cheng80.myqnapcloud.com/tablenow/${ref.read(menuNotifierProvider).value![index].menu_image}",
                                                  height: 60,
                                                  width: 60,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    width: 60,
                                                    height: 60,
                                                    color: p.divider,
                                                    child: Icon(Icons.restaurant, color: p.textSecondary),
                                                  ),
                                                ),
                                              ),
                                              
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${menu['name']}",
                                                      style: mainSmallTitleStyle.copyWith(color: p.textPrimary),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "${menu['count']}개",
                                                      style: mainSmallTextStyle.copyWith(color: p.textSecondary),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                "${CustomCommonUtil.formatPrice(menu['price'])}",
                                                style: mainBodyTextStyle.copyWith(
                                                  color: p.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        menu['options'] != null && options.isNotEmpty
                                            ? Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                                                decoration: BoxDecoration(
                                                  color: p.background,
                                                  borderRadius: const BorderRadius.only(
                                                    bottomLeft: Radius.circular(12),
                                                    bottomRight: Radius.circular(12),
                                                  ),
                                                ),
                                                child: Column(
                                                  children: List.generate(
                                                    options.length,
                                                    (i) => _optionMenus(options[i], p),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ],
                                    ),
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
                                ],
                              ),
                            ),
                          ),
                  
                      // 맨 밑에 결제 박스
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: p.cardBackground,
                          border: Border.all(color: p.divider),
                          boxShadow: [
                            BoxShadow(
                              color: p.textSecondary.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '총 결제금액',
                                  style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
                                ),
                                Text(
                                  CustomCommonUtil.formatPrice(paymentValue.total_payment),
                                  style: mainMediumTitleStyle.copyWith(
                                    color: p.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            paymentCardType(
                              context,
                              'image',
                              '토스페이로 결제하기',
                              paymentValue,
                              p,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ),

          error: (error, stackTrace) => Center(
            child: Text(
              '오류: $error',
              style: mainBodyTextStyle.copyWith(color: Colors.red),
            ),
          ),
          loading: () => Center(child: CircularProgressIndicator(color: p.primary)),
        ),
      ),
    );
  }

  // 정보 행 위젯
  Widget _buildInfoRow(IconData icon, String title, String content, dynamic p) {
    return Row(
      children: [
        Icon(icon, color: p.primary, size: 18),
        const SizedBox(width: 10),
        Text(
          title,
          style: mainSmallTextStyle.copyWith(color: p.textSecondary),
        ),
        const Spacer(),
        Text(
          content,
          style: mainBodyTextStyle.copyWith(
            color: p.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // == widget
  Widget _optionMenus(Map<String, dynamic> option, dynamic p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.add_circle_outline, color: p.textSecondary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${option['name']}',
              style: mainSmallTextStyle.copyWith(color: p.textSecondary),
            ),
          ),
          Text(
            "${option['count']}개",
            style: mainSmallTextStyle.copyWith(color: p.textSecondary),
          ),
          const SizedBox(width: 12),
          Text(
            CustomCommonUtil.formatPrice(option['price']),
            style: mainSmallTextStyle.copyWith(
              color: p.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget textSubTitle(String label) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 12),
      child: Text(
        label,
        style: mainTitleStyle.copyWith(
          color: p.textPrimary,
          fontWeight: FontWeight.bold,
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
    dynamic p,
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
    return SizedBox(
      width: double.infinity,
      height: mainButtonHeight,
      child: ElevatedButton.icon(
        onPressed: () async {
          /// 카드 결제 전 Data를 추가한다.
          // await paymentValue.purchase();
          // 결제 진행중.
          paymentValue.purchaseUpdate({
            'payment_key': 'payment_key',
            'payment_status': 'PROCESS',
            'reserve_seq': 0,
          });

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
        icon: Icon(
          Icons.payment,
          size: 20,
          color: p.textOnPrimary,
        ),
        label: Text(
          cardName,
          style: mainMediumTitleStyle.copyWith(color: p.textOnPrimary),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.textOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
