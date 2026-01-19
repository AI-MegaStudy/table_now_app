import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_now_app/view/payment/purchase/toss_result_page.dart';
import 'package:table_now_app/view/payment/purchase/toss_payment.dart';

import 'package:tosspayments_widget_sdk_flutter/model/paymentData.dart';

/// [Home] 위젯은 사용자에게 결제 수단 및 주문 관련 정보를 입력받아
/// 결제를 시작하는 화면을 제공합니다.
class TossHome extends StatefulWidget {
  const TossHome({super.key});

  @override
  State<TossHome> createState() => _TossHomeState();
}

class _TossHomeState extends State<TossHome> {
  final _form = GlobalKey<FormState>();
  late String payMethod = '카드'; // 결제수단
  late String orderId; // 주문번호
  late String orderName; // 주문명
  late String amount; // 결제금액
  late String customerName; // 주문자명
  late String customerEmail; // 구매자 이메일

  List<String> payMethods = ['카드', '가상계좌', '계좌이체', '휴대폰', '상품권'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('toss payments 결제정보'), centerTitle: true, systemOverlayStyle: SystemUiOverlayStyle.dark),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 15),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                initialValue: '카드',
                decoration: const InputDecoration(
                  labelText: '결제수단',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: TextStyle(fontSize: 15, color: Color(0xffcfcfcf)),
                ),
                onChanged: (String? newValue) => payMethod = newValue ?? '카드',
                items: payMethods.map<DropdownMenuItem<String>>((String i) {
                  return DropdownMenuItem<String>(
                    value: i,
                    child: Text({'카드': '카드', '가상계좌': '가상계좌', '계좌이체': '계좌이체', '휴대폰': '휴대폰', '상품권': '상품권'}[i] ?? '카드'),
                  );
                }).toList(),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '주문번호(orderId)'),
                initialValue: 'tosspaymentsFlutter_${DateTime.now().millisecondsSinceEpoch}',
                onSaved: (String? value) {
                  orderId = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '주문명(orderName)'),
                initialValue: 'Toss T-shirt',
                onSaved: (String? value) {
                  orderName = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '결제금액(amount)'),
                initialValue: '50000',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onSaved: (String? value) {
                  amount = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '구매자명(customerName)'),
                initialValue: '김토스',
                onSaved: (String? value) {
                  customerName = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '이메일(customerEmail)'),
                initialValue: 'email@tosspayments.com',
                keyboardType: TextInputType.emailAddress,
                onSaved: (String? value) {
                  customerEmail = value!;
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    _form.currentState!.save();
                    PaymentData data = PaymentData(
                      paymentMethod: payMethod,
                      orderId: orderId,
                      orderName: orderName,
                      amount: int.parse(amount),
                      customerName: customerName,
                      customerEmail: customerEmail,
                      successUrl: Constants.success,
                      failUrl: Constants.fail,
                    );
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => TossPayment(data: data))).then((result) {
                      if (result != null) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => TossResultPage(result: result)));
                      }
                    });
                  },
                  child: const Text(
                    '결제하기',
                    style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
