import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:table_now_app/firebase_options.dart';
import 'package:table_now_app/view/home.dart';
import 'package:table_now_app/vm/theme_notifier.dart';

Future<void> main() async {
  // Flutter 바인딩 초기화 (플러그인 사용 전 필수)
  WidgetsFlutterBinding.ensureInitialized();

  // GetStorage 초기화 (get_storage는 GetX와 독립적으로 사용 가능)
  await GetStorage.init();

  // GT ADDED: Firebase initialize
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpod으로 테마 모드 관리
    final themeMode = ref.watch(themeNotifierProvider);
    final Color seedColor = Colors.deepPurple;

    return MaterialApp(
      title: 'Table Now',
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
