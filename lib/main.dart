import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_now_app/config.dart';
import 'package:table_now_app/firebase_options.dart';
import 'package:table_now_app/view/home.dart';
import 'package:table_now_app/vm/fcm_notifier.dart';
import 'package:table_now_app/vm/theme_notifier.dart';
import 'package:table_now_app/vm/auth_notifier.dart';
import 'package:table_now_app/utils/local_notification_service.dart';
import 'package:table_now_app/utils/current_screen_tracker.dart';
import 'package:table_now_app/utils/route_observer_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:convert';

// 전역 NavigatorKey (알림 클릭 시 현재 화면 확인용)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // Flutter 바인딩 초기화 (플러그인 사용 전 필수)
  WidgetsFlutterBinding.ensureInitialized();

  // GetStorage 초기화 (get_storage는 GetX와 독립적으로 사용 가능)
  await GetStorage.init();

  // 자동 로그인 체크 (GetStorage 초기화 후)
  final storage = GetStorage();
  final autoLoginEnabled = storage.read<bool>(storageKeyAutoLogin) ?? false;

  // 자동 로그인이 비활성화되어 있으면 로그인 정보 삭제
  if (!autoLoginEnabled) {
    try {
      await storage.remove(storageKeyCustomer);
      if (kDebugMode) {
        print('🗑️ 로그인 정보 삭제 완료 (자동 로그인 비활성화)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ 로그인 정보 삭제 실패: $e');
      }
    }
  }

  // 앱 시작 시 임시 주문 데이터 정리
  try {
    await storage.remove(storageKeyOrder);
    if (kDebugMode) {
      print('🗑️ order 데이터 삭제 완료');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ order 데이터 삭제 실패: $e');
    }
  }

  // Get setting data One time when it is loaded
  // Save it to storage         
  storage.write(storageTossKey, 'BZ6CaEybDVHeBOywltykQQCPbmr5vmzW4PDFJBww1LMP72JT4GJa+CjdwEAHMhsd');

  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      print('Firebase initialized successfully');
    }
  } catch (e, stackTrace) {
    // 프로필/릴리스 모드에서도 에러 확인 가능하도록 항상 출력
    print('❌ Firebase initialization error: $e');
    print('Stack trace: $stackTrace');
    // 실기기 빌드에서 GoogleService-Info.plist를 찾지 못하는 경우를 대비
    // 앱은 계속 실행되지만 Firebase 기능은 사용할 수 없음
  }

  // API 기본 URL 확인
  if (kDebugMode) {
    print('API Base URL: ${getApiBaseUrl()}');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // 앱 생명주기 관찰자 등록 (포그라운드/백그라운드 감지용)
    WidgetsBinding.instance.addObserver(this);

    // FCM 초기화 (Firebase 초기화 후 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFCM();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 앱이 포그라운드로 돌아올 때 FCM 토큰 재확인
    if (state == AppLifecycleState.resumed) {
      final fcmState = ref.read(fcmNotifierProvider);
      if (fcmState.token == null && fcmState.isInitialized) {
        Future.delayed(const Duration(seconds: 2), () {
          ref.read(fcmNotifierProvider.notifier).refreshToken();
        });
      }
    }
  }

  Future<void> _initializeFCM() async {
    try {
      await ref.read(fcmNotifierProvider.notifier).initialize();

      // 알림 클릭 핸들러 설정 (현재 화면 정보 포함)
      LocalNotificationService.setOnNotificationTap((
        NotificationResponse response,
      ) {
        // 현재 화면 정보 가져오기 (전역 추적 사용)
        final currentScreen = CurrentScreenTracker.getCurrentScreen();

        if (kDebugMode) {
          if (currentScreen != null) {
            print('알림 클릭: 현재 화면=$currentScreen');
          }
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final data = jsonDecode(response.payload!);
              print('Payload: $data');
            } catch (e) {
              // 파싱 실패는 무시
            }
          }
        }

        // TODO: 여기에 화면 이동 로직 추가
        // 예: data['screen']에 따라 적절한 화면으로 이동
      });

      // FCM 초기화 후, 로그인 상태 확인하여 토큰 서버 전송
      // 자동 로그인 시에도 토큰이 서버에 등록되도록 함
      final authState = ref.read(authNotifierProvider);

      if (authState.isLoggedIn && authState.customer != null) {
        final fcmNotifier = ref.read(fcmNotifierProvider.notifier);
        final token = fcmNotifier.currentToken;

        if (token != null) {
          if (kDebugMode) {
            print(
              '자동 로그인: FCM 토큰 서버 전송 (Customer: ${authState.customer!.customerSeq})',
            );
          }

          // 약간의 지연 후 전송 (FCM 초기화가 완전히 완료되도록)
          Future.delayed(const Duration(seconds: 1), () async {
            try {
              await fcmNotifier.sendTokenToServer(
                authState.customer!.customerSeq,
              );
            } catch (e) {
              if (kDebugMode) {
                print('⚠️  자동 로그인 시 FCM 토큰 서버 전송 실패: $e');
              }
            }
          });
        }
      }
    } catch (e, stackTrace) {
      // 프로필/릴리스 모드에서도 에러 확인 가능하도록 항상 출력
      print('❌ FCM initialization error: $e');
      print('Stack trace: $stackTrace');
      // FCM 초기화 실패해도 앱은 계속 실행
    }
  }

  @override
  Widget build(BuildContext context) {
    // Riverpod으로 테마 모드 관리
    final themeMode = ref.watch(themeNotifierProvider);
    final Color seedColor = Colors.deepPurple;

    return MaterialApp(
      navigatorKey: navigatorKey, // 전역 NavigatorKey 설정 (알림 클릭 시 현재 화면 확인용)
      navigatorObservers: [ScreenTrackingRouteObserver()], // 라우트 변경 감지
      title: 'TableNow',
      // 로케일 설정 (Google Maps 언어 설정용)
      locale: const Locale('ko', 'KR'), // 한국어 강제 설정
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어
        Locale('en', 'US'), // 영어 (fallback)
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: seedColor,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: seedColor,
      ),
      home: const Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}
