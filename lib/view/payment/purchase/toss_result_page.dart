import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/config/ui_config.dart';
import 'package:table_now_app/custom/utils_core.dart';
import 'package:table_now_app/theme/app_colors.dart';
import 'package:table_now_app/utils/push_notification_service.dart';
import 'package:table_now_app/vm/payment_list_notifier.dart';
import 'package:tosspayments_widget_sdk_flutter/model/tosspayments_result.dart';

/// Reverve, Selected Menu list
/// 성공했으면 저장.

/// [ResultPage] class는 결제의 성공 혹은 실패 여부를 보여주는 위젯입니다.
class TossResultPage extends ConsumerWidget {
  /// 기본 생성자입니다.
  
  final dynamic result;
  const TossResultPage({super.key,required this.result});

  /// 주어진 title과 message를 이용하여 [Row]를 생성합니다.
  ///
  /// [title]과 [message]는 [Text] 위젯의 일부로 포함됩니다.
  ///
  /// [title]는 회색 텍스트 스타일로, [message]는 기본 텍스트 스타일로 표시됩니다.
  Widget makeRow(String title, String message, dynamic p) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: mainSmallTextStyle.copyWith(color: p.textSecondary),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(
              message,
              style: mainBodyTextStyle.copyWith(
                color: p.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        ],
      ),
    );
  }

  /// 결제 결과에 따라 적절한 [Container]를 반환합니다.
  ///
  /// [result]이 [Success] 타입이면 성공 메시지와 함께 세부 정보를 표시합니다.
  /// [result]이 [Fail] 타입이면 오류 메시지와 함께 세부 정보를 표시합니다.
  /// 그 외의 경우, 비어있는 [Container]를 반환합니다.
  Widget getContainer(dynamic result, dynamic p) {
    return Builder(
      builder: (context) {
        // Success 타입인 경우
        if (result is Success) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: p.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '결제 정보',
                  style: mainTitleStyle.copyWith(color: p.textPrimary),
                ),
                const SizedBox(height: 8),
                Divider(color: p.divider),
                const SizedBox(height: 12),
                makeRow('결제 키', result.paymentKey, p),
                makeRow('주문 ID', result.orderId, p),
                makeRow('결제 금액', '${result.amount}원', p),
                ...?result.additionalParams?.entries.map<Widget>((e) => 
                  makeRow(e.key, e.value, p),
                ),
              ],
            ),
          );
        }

        // Fail 타입인 경우
        if (result is Fail) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '오류 정보',
                  style: mainTitleStyle.copyWith(color: Colors.red.shade700),
                ),
                const SizedBox(height: 8),
                Divider(color: Colors.red.shade200),
                const SizedBox(height: 12),
                makeRow('오류 코드', result.errorCode, p),
                makeRow('오류 메시지', result.errorMessage, p),
                makeRow('주문 ID', result.orderId, p),
              ],
            ),
          );
        }

        // Success 또는 Fail 타입이 아닌 경우
        return const SizedBox(); // 빈 위젯 반환
      },
    );
  }

  /// 위젯을 빌드합니다.
  ///
  /// [Success]인 경우, '인증 성공!' 메시지를 표시하며,
  /// 그 외의 경우, '결제에 실패하였습니다' 메시지를 표시합니다.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    // dynamic result = Get.arguments;
    String message;
    final paymentValue = ref.read(paymentListAsyncNotifierProvider.notifier);
    // final paymentState = ref.watch(paymentListAsyncNotifierProvider.select((value) => value.,))
    
    final bool isSuccess = result is Success;

    if (isSuccess) {
      message = '결제가 완료되었습니다!';
      paymentValue.purchase().then((r) {
        paymentValue.purchaseUpdate({'payment_key':result.paymentKey,'payment_status':'DONE','reserve_seq':result.orderId});
        if(paymentValue.customerSeq != null){
          PushNotificationService.sendToCustomer(
            customerSeq: paymentValue.customerSeq!,
            title: '예약(결제)가 완료됬습니다.',
            body: '예약번호: ${result.orderId}',
            data: {'type': 'test', 'timestamp': DateTime.now().toIso8601String()},
          );
        }

      });
    } else {
      message = '결제에 실패하였습니다';
      paymentValue.purchaseUpdate({'payment_key':result.errorCode.toString(),'payment_status':'FAIL','reserve_seq':result.orderId});
        print('====================');
        print(paymentValue.customerSeq.toString());
        if(paymentValue.customerSeq != null){
          PushNotificationService.sendToCustomer(
            customerSeq: paymentValue.customerSeq!,
            title: '예약(결제)가 실패했습니다.',
            body: '예약번호: ${result.orderId}.',
            data: {'type': 'test', 'timestamp': DateTime.now().toIso8601String()},
          );
        }
    }

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(
          '결제 결과',
          style: mainAppBarTitleStyle.copyWith(color: p.textOnPrimary),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: p.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // 성공/실패 아이콘
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                  size: 60,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              
              // 결과 메시지
              Text(
                message,
                textAlign: TextAlign.center,
                style: mainMediumTitleStyle.copyWith(
                  color: p.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              // 결과 상세 정보
              getContainer(result, p),
              const SizedBox(height: 40),

              // 버튼 영역
              if (result is Fail)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: mainButtonHeight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          CustomNavigationUtil.back(context);
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text(
                          '다시 결제 시도',
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
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: mainButtonHeight,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          paymentValue.reset();
                          CustomNavigationUtil.back(context);
                          CustomNavigationUtil.back(context);
                        },
                        icon: Icon(Icons.delete_outline, color: p.textSecondary),
                        label: Text(
                          '기존 주문 취소',
                          style: mainMediumTitleStyle.copyWith(color: p.textSecondary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: p.divider),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: mainButtonHeight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      CustomNavigationUtil.back(context);
                    },
                    icon: Icon(Icons.home, color: p.textOnPrimary),
                    label: Text(
                      '홈으로 돌아가기',
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
