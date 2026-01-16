import 'package:flutter/material.dart';

import 'package:tosspayments_widget_sdk_flutter/model/paymentData.dart';
import 'package:tosspayments_widget_sdk_flutter/model/tosspayments_result.dart';
import 'package:tosspayments_widget_sdk_flutter/pages/tosspayments_sdk_flutter.dart';

/// [TossPayment] 클래스는 결제 처리를 담당하는 위젯입니다.
class TossPayment extends StatelessWidget {
  /// 기본 생성자입니다.
  final PaymentData data;
  const TossPayment({super.key, required this.data});

  /// 위젯을 빌드합니다.
  ///
  /// 'test_ck_D5GePWvyJnrK0W0k6q8gLzN97Eoq' 클라이언트 키를 사용하여 [TossPayments]를 생성합니다.
  ///
  /// 성공하면, 결과를 반환하고 이전 화면으로 돌아갑니다.
  /// 실패하면, 실패 정보를 반환하고 이전 화면으로 돌아갑니다.
  @override
  Widget build(BuildContext context) {
    return TossPayments(

      clientKey: 'test_ck_D5GePWvyJnrK0W0k6q8gLzN97Eoq',
      data: data,
      success: (Success success) {
        Navigator.of(context).pop(success);
      },
      fail: (Fail fail) {
        Navigator.of(context).pop(fail);
      },
    );
  }
}
