// dev_02.dart (작업자: 이예은)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/custom/util/navigation/custom_navigation_util.dart';
import 'package:table_now_app/model/store.dart';
import 'package:table_now_app/view/map/region_list_screen.dart';
import 'package:table_now_app/view/map/screen.dart';
import 'package:table_now_app/view/map/storebooking.dart';
import '../../config/ui_config.dart';
import '../../theme/app_colors.dart';

class Dev_02 extends ConsumerStatefulWidget {
  const Dev_02({super.key});

  @override
  ConsumerState<Dev_02> createState() => _Dev_02State();
}

class _Dev_02State extends ConsumerState<Dev_02> {
  /// 🔹 테스트용 더미 Store
  late final Store dummyStore;

  @override
  void initState() {
    super.initState();

    /// ✅ Store 모델 필드 100% 반영
    dummyStore = Store(
      store_seq: 1,
      store_address: '서울 강남구 테헤란로 123',
      store_lat: 37.498095,
      store_lng: 127.027610,
      store_phone: '02-1234-5678',
      store_open_time: '10:00',
      store_close_time: '22:00',
      store_description: '강남 카레 맛집 (더미 데이터)',
      store_image: null,
      store_placement: '강남',
      created_at: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(
          '이예은 페이지',
          style: mainAppBarTitleStyle.copyWith(
            color: p.textPrimary,
          ),
        ),
        centerTitle: mainAppBarCenterTitle,
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: mainDefaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// 임시 화면
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Screen(),
                    ),
                  );
                },
                child: Text(
                  'temp',
                  style: mainMediumTitleStyle.copyWith(
                    color: p.textOnPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// 예약 화면 (더미 Store 전달)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          StoreBookingInfoScreen(
                            store: dummyStore,
                          ),
                    ),
                  );
                },
                child: Text(
                  'yeuun',
                  style: mainMediumTitleStyle.copyWith(
                    color: p.textOnPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// 지도 화면
              SizedBox(
                width: mainButtonMaxWidth,
                height: mainButtonHeight,
                child: ElevatedButton(
                  onPressed: _navigateToMap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.primary,
                    foregroundColor: p.textOnPrimary,
                  ),
                  child: Text(
                    'map',
                    style: mainMediumTitleStyle.copyWith(
                      color: p.textOnPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------- Functions --------
  void _navigateToMap() async {
    await CustomNavigationUtil.to(
      context,
      RegionListScreen(),
    );
  }
}
