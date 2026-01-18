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
    if (kDebugMode) {
      print('✅ Firebase initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Firebase initialization error: $e');
    }
    // 실기기 빌드에서 GoogleService-Info.plist를 찾지 못하는 경우를 대비
    // 앱은 계속 실행되지만 Firebase 기능은 사용할 수 없음
  }

  // API 기본 URL 초기화 (실기기 여부 체크 포함)
  try {
    await initializeApiBaseUrl();
    if (kDebugMode) {
      print('✅ API Base URL initialized: ${getApiBaseUrl()}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️  API Base URL initialization error: $e');
      print('💡 기본값을 사용합니다: ${getApiBaseUrl()}');
    }
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
    } catch (e) {
      if (kDebugMode) {
        print('❌ FCM initialization error: $e');
      }
      // FCM 초기화 실패해도 앱은 계속 실행
    }
  }

  @override
  Widget build(BuildContext context) {
    // Riverpod으로 테마 모드 관리
    final themeMode = ref.watch(themeNotifierProvider);
    final Color seedColor = Colors.deepPurple;

    return MaterialApp(
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
