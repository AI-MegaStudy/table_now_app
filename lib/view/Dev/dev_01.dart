// dev_01.dart (작업자: 이광태)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/custom/custom.dart';
import 'package:table_now_app/view/payment/list_view.dart';
import 'package:table_now_app/view/payment/purchase/toss_home.dart';
import '../../config/ui_config.dart';
import '../../theme/app_colors.dart';

class Dev_01 extends ConsumerStatefulWidget {
  const Dev_01({super.key});

  @override
  ConsumerState<Dev_01> createState() => _Dev_01State();
}

class _Dev_01State extends ConsumerState<Dev_01> {
  // Property
  // late는 초기화를 나중으로 미룸

  @override
  void initState() {
    // 페이지가 새로 생성될 때 무조건 1번 사용됨
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final p = context.palette;
        return Scaffold(
          backgroundColor: p.background,
          appBar: AppBar(
            title: Text(
              '이광태 페이지',
              style: mainAppBarTitleStyle.copyWith(color: p.textPrimary),
            ),
            centerTitle: mainAppBarCenterTitle,
            backgroundColor: p.background,
            foregroundColor: p.textPrimary,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: mainDefaultPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: mainLargeSpacing,
                children: [
                  // 여기에 컨텐츠 추가
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Hello World!',
                          style: mainMediumTextStyle.copyWith(color: p.textPrimary),
                        ),
                        ElevatedButton(
                          // CustomNavigationUtil.to(context, const AuthScreen());
                          onPressed: ()=>CustomNavigationUtil.to(context,const PaymentListView() ), 
                          child: Text('Payment List By CustomerID')
                        ),
                        ElevatedButton(
                          // CustomNavigationUtil.to(context, const AuthScreen());
                          onPressed: ()=>CustomNavigationUtil.to(context,const TossHome() ), 
                          child: Text('TOSS PAY')
                        )


                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //--------Functions ------------

  //------------------------------
}
