import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/custom/util/navigation/custom_navigation_util.dart';

import 'package:table_now_app/utils/common_utils.dart';
import 'package:table_now_app/vm/payment_list_notifier.dart';


import 'package:tosspayments_widget_sdk_flutter/model/paymentData.dart';
import 'package:tosspayments_widget_sdk_flutter/model/tosspayments_result.dart';
import 'package:tosspayments_widget_sdk_flutter/pages/tosspayments_sdk_flutter.dart';

/// [TossPayment] 클래스는 결제 처리를 담당하는 위젯입니다.
class TossPayment extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentValue = ref.read(paymentListAsyncNotifierProvider.notifier);
    if(paymentValue.k == '') CustomNavigationUtil.back(context,result: -1);
     
    return TossPayments(
      clientKey: MyCrypt.mycrypt.ase_decrypt(paymentValue.k,paymentValue.iv),
      data: data,
      success: (Success success) {
        // todo: 결제가 성공하였음. data를 insert해야 함. 
        // Insert into Payment with menuIds
        // Insert 예약
        CustomNavigationUtil.back(context,result: success);
      },
      fail: (Fail fail) {
        CustomNavigationUtil.back(context,result: fail);
      },
    );
  }
}
