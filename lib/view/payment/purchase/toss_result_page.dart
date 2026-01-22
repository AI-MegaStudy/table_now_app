import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/custom/utils_core.dart';
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
  Row makeRow(String title, String message) {
    return Row(children: [
      Expanded(
          flex: 3,
          child: Text(title, style: const TextStyle(color: Colors.grey))),
      Expanded(
        flex: 8,
        child: Text(message),
      )
    ]);
  }

  /// 결제 결과에 따라 적절한 [Container]를 반환합니다.
  ///
  /// [result]이 [Success] 타입이면 성공 메시지와 함께 세부 정보를 표시합니다.
  /// [result]이 [Fail] 타입이면 오류 메시지와 함께 세부 정보를 표시합니다.
  /// 그 외의 경우, 비어있는 [Container]를 반환합니다.
  Container getContainer(dynamic result) {
    return Container(
      color: Colors.transparent,
      child: Builder(
        builder: (context) {
          // Success 타입인 경우
          if (result is Success) {
            return Column(
              children: <Widget>[
                makeRow('paymentKey', result.paymentKey),
                const SizedBox(height: 20),
                makeRow('orderId', result.orderId),
                const SizedBox(height: 20),
                makeRow('amount', result.amount.toString()),
                const SizedBox(height: 20),
                ...?result.additionalParams?.entries.map<Widget>((e) => Column(
                      children: [
                        makeRow(e.key, e.value),
                        const SizedBox(height: 10),
                      ],
                    )),
                ElevatedButton(
                  onPressed: () {
                    // copyToClipboard 함수 구현 필요
                    // copyToClipboard(result.toString());
                  },
                  child: const Center(
                    child: Text(
                      '복사하기',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // Fail 타입인 경우
          if (result is Fail) {
            return Column(
              children: <Widget>[
                makeRow('errorCode', result.errorCode),
                const SizedBox(height: 20),
                makeRow('errorMessage', result.errorMessage),
                const SizedBox(height: 20),
                makeRow('orderId', result.orderId),
         


              ],
            );
          }

          // Success 또는 Fail 타입이 아닌 경우
          return const SizedBox(); // 빈 위젯 반환
        },
      ),
    );
  }

  /// 위젯을 빌드합니다.
  ///
  /// [Success]인 경우, '인증 성공!' 메시지를 표시하며,
  /// 그 외의 경우, '결제에 실패하였습니다' 메시지를 표시합니다.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // dynamic result = Get.arguments;
    String message;
    final paymentValue = ref.read(paymentListAsyncNotifierProvider.notifier);
    // final paymentState = ref.watch(paymentListAsyncNotifierProvider.select((value) => value.,))
      
       



    if (result is Success) {
      message = '인증 성공! 결제승인API를 호출해 결제를 완료하세요!';
      paymentValue.purchase().then((r){
        paymentValue.purchaseUpdate({'payment_key':result.paymentKey,'payment_status':'DONE','reserve_seq':result.orderId});
      });
    } else {
      message = '결제에 실패하였습니다';
      paymentValue.purchaseUpdate({'payment_key':result.errorCode.toString(),'payment_status':'FAIL','reserve_seq':result.orderId});
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('결제 결과'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [


                Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 50),
                getContainer(result),
                const SizedBox(height: 40),

                
                result is Fail 
                ?Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        CustomNavigationUtil.back(context);
                       
                      },
                      style: ElevatedButton.styleFrom(
                        // elevation: 0,
                        // shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3)
                        )
                      ),
                      child: const Text(
                        '다시 결제 시도',
                        style: TextStyle(fontSize: 13, color: Colors.black),
                      ),
                      
                    ),
                    ElevatedButton(
                      onPressed: () {
                        paymentValue.reset();
                        CustomNavigationUtil.back(context);
                        CustomNavigationUtil.back(context);
                      },
                      style: ElevatedButton.styleFrom(
                        // elevation: 0,
                        // shadowColor: Colors.transparent,
                         shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3)
                        )
                      ),
                      child: const Text(
                        '기존 주문 지우기',
                        style: TextStyle(fontSize: 13, color: Colors.black),
                      ),
                      
                    ),

                  ],
                )
                :
                ElevatedButton.icon(
                  onPressed: () {
                    CustomNavigationUtil.back(context);
                   
                  },
                  icon: const Icon(Icons.home,size: 30,),
                  label: const Text(
                    '홈으로',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
