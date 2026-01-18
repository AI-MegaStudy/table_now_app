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
import 'package:table_now_app/utils/local_notification_service.dart';
import 'package:table_now_app/utils/current_screen_tracker.dart';
import 'package:table_now_app/utils/route_observer_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  if (!autoLoginEnabled) {
    // 자동 로그인이 비활성화되어 있으면 로그인 정보 삭제
    storage.remove(storageKeyCustomer);
    if (kDebugMode) {
      print('🔓 자동 로그인 비활성화: 로그인 정보 삭제');
    }
  } else {
    if (kDebugMode) {
      print('🔐 자동 로그인 활성화: 로그인 정보 유지');
    }
  }

  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e, stackTrace) {
    // 프로필/릴리스 모드에서도 에러 확인 가능하도록 항상 출력
    print('❌ Firebase initialization error: $e');
    print('Stack trace: $stackTrace');
    // 실기기 빌드에서 GoogleService-Info.plist를 찾지 못하는 경우를 대비
    // 앱은 계속 실행되지만 Firebase 기능은 사용할 수 없음
  }

  // API 기본 URL 확인
  if (kDebugMode) {
    print('✅ API Base URL: ${getApiBaseUrl()}');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // FCM 초기화 (Firebase 초기화 후 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFCM();
    });
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
          print('🔔 알림 클릭:');
          print('   Payload: ${response.payload}');

          // 현재 화면 정보 출력
          if (currentScreen != null) {
            print('   현재 화면: $currentScreen');
          } else {
            print('   현재 화면: 알 수 없음');
          }

          // payload 파싱
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final data = jsonDecode(response.payload!);
              print('   데이터: $data');
            } catch (e) {
              print('   데이터 파싱 실패: $e');
            }
          }
        }

        // TODO: 여기에 화면 이동 로직 추가
        // 예: data['screen']에 따라 적절한 화면으로 이동
      });
    } catch (e, stackTrace) {
      // 프로필/릴리스 모드에서도 에러 확인 가능하도록 항상 출력
      print('❌ FCM initialization error: $e');
      print('Stack trace: $stackTrace');
      // FCM 초기화 실패해도 앱은 계속 실행
    }
  }

  /// 가장 깊은 Scaffold 찾기 (Navigator의 현재 활성 라우트에서 확인)
  Scaffold? _findDeepestScaffold(BuildContext context) {
    // Navigator의 현재 활성 라우트 확인
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      // Navigator의 현재 라우트 확인
      final currentRoute = ModalRoute.of(context);
      if (currentRoute != null && currentRoute.isActive) {
        // 현재 라우트의 Scaffold 찾기
        Scaffold? candidateScaffold;
        Scaffold? fallbackScaffold;

        // 위젯 트리를 위로 올라가면서 모든 Scaffold 찾기
        BuildContext currentCtx = context;

        // 최대 반복 횟수 제한 (무한 루프 방지)
        int maxIterations = 10;
        int iteration = 0;

        while (iteration < maxIterations) {
          iteration++;
          final scaffold = currentCtx.findAncestorWidgetOfExactType<Scaffold>();
          if (scaffold != null) {
            // Scaffold의 key 확인 (화면 식별용)
            final scaffoldKey = scaffold.key;
            if (scaffoldKey is ValueKey) {
              final keyValue = scaffoldKey.value;
              if (keyValue is String && keyValue.startsWith('Dev_')) {
                // Dev 화면인 경우 (가장 우선순위)
                candidateScaffold = scaffold;
                break;
              }
            }

            // Scaffold의 body가 실제 화면 위젯인지 확인
            final body = scaffold.body;
            if (body != null) {
              final bodyType = body.runtimeType.toString();
              // 탭 구조나 홈 화면이 아닌 실제 화면인 경우
              if (!bodyType.contains('IndexedStack') &&
                  !bodyType.contains('PageView') &&
                  !bodyType.contains('TabBarView')) {
                // 가장 깊은 Scaffold로 설정
                fallbackScaffold ??= scaffold;
              }
            }
          }

          // 부모 context로 이동 시도
          try {
            // RenderObjectWidget을 통해 부모로 이동할 수 없으므로 중단
            break;
          } catch (e) {
            break;
          }
        }

        // key가 있는 Scaffold를 우선적으로 반환
        if (candidateScaffold != null) {
          return candidateScaffold;
        }

        // key가 없으면 fallback Scaffold 반환
        if (fallbackScaffold != null) {
          return fallbackScaffold;
        }

        // 위 방법이 실패하면 현재 context에서 가장 가까운 Scaffold 반환
        return context.findAncestorWidgetOfExactType<Scaffold>();
      }
    }

    // 위 방법이 실패하면 현재 context에서 가장 가까운 Scaffold 반환
    return context.findAncestorWidgetOfExactType<Scaffold>();
  }

  /// 위젯 타입 이름 추출 헬퍼 함수
  String _extractWidgetTypeName(Widget widget) {
    final typeString = widget.runtimeType.toString();

    // 위젯 타입 정제
    if (typeString.contains('_')) {
      // "_Dev_07State" 같은 경우 "Dev_07" 추출
      final parts = typeString.split('_');
      if (parts.length >= 2) {
        // "Dev"와 "07"을 합쳐서 "Dev_07"로 만들기
        return parts.sublist(0, 2).join('_');
      } else {
        return typeString
            .replaceAll('_', '')
            .replaceAll('State', '')
            .replaceAll('Element', '');
      }
    } else if (!typeString.contains('Element') &&
        !typeString.contains('State') &&
        !typeString.contains('Widget')) {
      return typeString;
    } else {
      // "StatefulElement", "StatelessElement" 같은 내부 타입 제거
      return typeString
          .replaceAll('Element', '')
          .replaceAll('State', '')
          .replaceAll('Widget', '');
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
