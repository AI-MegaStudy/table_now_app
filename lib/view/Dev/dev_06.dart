// dev_06.dart (작업자: 김택권)
// Riverpod Provider 사용 예제 페이지

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/ui_config.dart';
import '../../theme/app_colors.dart';
import '../../vm/provider_examples.dart';

class Dev_06 extends ConsumerStatefulWidget {
  const Dev_06({super.key});

  @override
  ConsumerState<Dev_06> createState() => _Dev_06State();
}

class _Dev_06State extends ConsumerState<Dev_06> {
  @override
  void initState() {
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
              '김택권 페이지 - Provider 예제',
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
                  // 1. Provider 예제 - 단순한 값 제공
                  _buildProviderExample(context, p),

                  // 2. NotifierProvider 예제 - 카운터
                  _buildCounterExample(context, p),

                  // 3. NotifierProvider 예제 - 로그인 상태
                  _buildLoginExample(context, p),

                  // 4. AsyncNotifierProvider 예제 - 사용자 목록
                  _buildUserListExample(context, p),

                  // 5. FutureProvider 예제
                  _buildFutureProviderExample(context, p),

                  // 6. StreamProvider 예제
                  _buildStreamProviderExample(context, p),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //--------Functions ------------

  /// 1. Provider 예제 - 단순한 값 제공
  Widget _buildProviderExample(BuildContext context, AppColorScheme p) {
    // ref.watch로 값 읽기
    final appName = ref.watch(appNameProvider);
    final apiUrl = ref.watch(apiBaseUrlProvider);

    return Container(
      padding: mainDefaultPadding,
      decoration: BoxDecoration(
        color: p.cardBackground,
        borderRadius: mainDefaultBorderRadius,
        border: Border.all(color: p.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: mainSmallSpacing,
        children: [
          Text(
            '1. Provider (단순한 값 제공)',
            style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
          ),
          Text(
            '앱 이름: $appName',
            style: mainBodyTextStyle.copyWith(color: p.textPrimary),
          ),
          Text(
            'API URL: $apiUrl',
            style: mainSmallTextStyle.copyWith(color: p.textSecondary),
          ),
        ],
      ),
    );
  }

  /// 2. NotifierProvider 예제 - 카운터
  Widget _buildCounterExample(BuildContext context, AppColorScheme p) {
    // ref.watch로 상태 관찰
    final count = ref.watch(counterNotifierProvider);

    return Container(
      padding: mainDefaultPadding,
      decoration: BoxDecoration(
        color: p.cardBackground,
        borderRadius: mainDefaultBorderRadius,
        border: Border.all(color: p.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: mainSmallSpacing,
        children: [
          Text(
            '2. NotifierProvider (카운터)',
            style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
          ),
          Center(
            child: Text(
              '$count',
              style: mainLargeTitleStyle.copyWith(
                color: p.primary,
                fontSize: 48,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // ref.read로 상태 변경
                  ref.read(counterNotifierProvider.notifier).decrement();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.primary,
                  foregroundColor: p.textOnPrimary,
                ),
                child: const Text('-'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(counterNotifierProvider.notifier).reset();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.accent,
                  foregroundColor: p.textOnPrimary,
                ),
                child: const Text('Reset'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(counterNotifierProvider.notifier).increment();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.primary,
                  foregroundColor: p.textOnPrimary,
                ),
                child: const Text('+'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3. NotifierProvider 예제 - 로그인 상태
  Widget _buildLoginExample(BuildContext context, AppColorScheme p) {
    // ref.watch로 상태 관찰
    final isLoggedIn = ref.watch(loginNotifierProvider);

    return Container(
      padding: mainDefaultPadding,
      decoration: BoxDecoration(
        color: p.cardBackground,
        borderRadius: mainDefaultBorderRadius,
        border: Border.all(color: p.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: mainSmallSpacing,
        children: [
          Text(
            '3. NotifierProvider (로그인 상태)',
            style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
          ),
          Row(
            spacing: 8,
            children: [
              Icon(
                isLoggedIn ? Icons.check_circle : Icons.cancel,
                color: isLoggedIn ? Colors.green : Colors.red,
              ),
              Text(
                isLoggedIn ? '로그인됨' : '로그아웃됨',
                style: mainBodyTextStyle.copyWith(
                  color: isLoggedIn ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  ref.read(loginNotifierProvider.notifier).login();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('로그인'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(loginNotifierProvider.notifier).logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('로그아웃'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 4. AsyncNotifierProvider 예제 - 사용자 목록
  Widget _buildUserListExample(BuildContext context, AppColorScheme p) {
    // ref.watch로 비동기 상태 관찰
    final usersAsync = ref.watch(userNotifierProvider);

    return Container(
      padding: mainDefaultPadding,
      decoration: BoxDecoration(
        color: p.cardBackground,
        borderRadius: mainDefaultBorderRadius,
        border: Border.all(color: p.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: mainSmallSpacing,
        children: [
          Text(
            '4. AsyncNotifierProvider (사용자 목록)',
            style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
          ),
          usersAsync.when(
            data: (users) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  '사용자 수: ${users.length}',
                  style: mainBodyTextStyle.copyWith(color: p.textPrimary),
                ),
                ...users.map(
                  (user) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '• $user',
                      style: mainSmallTextStyle.copyWith(
                        color: p.textSecondary,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(userNotifierProvider.notifier)
                        .addUser('User${users.length + 1}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.primary,
                    foregroundColor: p.textOnPrimary,
                  ),
                  child: const Text('사용자 추가'),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text(
              '오류: $error',
              style: mainSmallTextStyle.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// 5. FutureProvider 예제
  Widget _buildFutureProviderExample(BuildContext context, AppColorScheme p) {
    // ref.watch로 Future 상태 관찰
    final futureData = ref.watch(futureDataProvider);

    return Container(
      padding: mainDefaultPadding,
      decoration: BoxDecoration(
        color: p.cardBackground,
        borderRadius: mainDefaultBorderRadius,
        border: Border.all(color: p.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: mainSmallSpacing,
        children: [
          Text(
            '5. FutureProvider (Future 값)',
            style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
          ),
          futureData.when(
            data: (data) => Text(
              '데이터: $data',
              style: mainBodyTextStyle.copyWith(color: p.textPrimary),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text(
              '오류: $error',
              style: mainSmallTextStyle.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// 6. StreamProvider 예제
  Widget _buildStreamProviderExample(BuildContext context, AppColorScheme p) {
    // ref.watch로 Stream 상태 관찰
    final streamData = ref.watch(streamDataProvider);

    return Container(
      padding: mainDefaultPadding,
      decoration: BoxDecoration(
        color: p.cardBackground,
        borderRadius: mainDefaultBorderRadius,
        border: Border.all(color: p.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: mainSmallSpacing,
        children: [
          Text(
            '6. StreamProvider (Stream 값)',
            style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
          ),
          streamData.when(
            data: (data) => Text(
              '현재 값: $data',
              style: mainLargeTitleStyle.copyWith(
                color: p.primary,
                fontSize: 32,
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text(
              '오류: $error',
              style: mainSmallTextStyle.copyWith(color: Colors.red),
            ),
          ),
          Text(
            '※ Stream은 1초마다 값이 업데이트됩니다',
            style: mainSmallTextStyle.copyWith(color: p.textSecondary),
          ),
        ],
      ),
    );
  }

  //------------------------------
}
