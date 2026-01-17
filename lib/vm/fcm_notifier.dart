import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_now_app/utils/fcm_storage.dart';

/// FCM 토큰 상태 모델
class FCMState {
  final String? token;
  final bool isInitialized;
  final String? errorMessage;

  FCMState({this.token, this.isInitialized = false, this.errorMessage});

  FCMState copyWith({
    String? token,
    bool? isInitialized,
    String? errorMessage,
    bool removeToken = false,
    bool removeErrorMessage = false,
  }) {
    return FCMState(
      token: removeToken ? null : (token ?? this.token),
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: removeErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

/// FCM Notifier
///
/// Firebase Cloud Messaging 토큰 관리 및 알림 권한 처리를 담당합니다.
class FCMNotifier extends Notifier<FCMState> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  FCMState build() {
    // 초기화는 initialize() 메서드에서 수행
    return FCMState();
  }

  /// FCM 초기화 및 토큰 가져오기
  ///
  /// 알림 권한 요청, 토큰 가져오기, 토큰 갱신 리스너 설정을 수행합니다.
  Future<void> initialize() async {
    try {
      if (kDebugMode) {
        print('🚀 FCM 초기화 시작...');
        print(
          '📱 Platform: ${Platform.isIOS
              ? 'iOS'
              : Platform.isAndroid
              ? 'Android'
              : 'Unknown'}',
        );
      }

      // iOS 알림 권한 요청 (필수)
      if (Platform.isIOS) {
        final permission = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        // 알림 권한 상태 로컬 저장
        final isGranted =
            permission.authorizationStatus == AuthorizationStatus.authorized ||
            permission.authorizationStatus == AuthorizationStatus.provisional;
        await FCMStorage.saveNotificationPermissionStatus(isGranted);

        if (kDebugMode) {
          print('📱 알림 권한 상태: ${permission.authorizationStatus}');
        }

        // iOS: APNs 토큰이 등록될 때까지 대기
        await _waitForAPNSToken();
      } else if (Platform.isAndroid) {
        // Android 13 (API 33) 이상에서 알림 권한 요청
        // firebase_messaging 패키지가 자동으로 처리하지만, 명시적으로 요청하는 것이 안전합니다
        try {
          final permission = await _messaging.requestPermission(
            alert: true,
            badge: true,
            sound: true,
          );

          // 알림 권한 상태 로컬 저장
          final isGranted =
              permission.authorizationStatus ==
                  AuthorizationStatus.authorized ||
              permission.authorizationStatus == AuthorizationStatus.provisional;
          await FCMStorage.saveNotificationPermissionStatus(isGranted);

          if (kDebugMode) {
            print('📱 Android 알림 권한 상태: ${permission.authorizationStatus}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️  Android 알림 권한 요청 실패: $e');
            print('💡 Android 13 미만에서는 런타임 권한 요청이 필요 없습니다.');
          }
        }
      }

      // 초기 토큰 가져오기
      await _refreshToken();

      // 토큰 갱신 리스너 설정
      _setupTokenRefreshListener();

      // 포그라운드 메시지 핸들러 설정
      _setupForegroundMessageHandler();

      state = state.copyWith(isInitialized: true, removeErrorMessage: true);

      if (kDebugMode) {
        print('✅ FCM initialized successfully');
        print('🔥 FCM_TOKEN = ${state.token ?? "null"}');

        if (state.token == null) {
          print('⚠️  FCM 토큰을 받지 못했습니다.');
          print('📝 실기기에서 실행하거나, Google Play Services가 설치된 환경에서 실행하세요.');
        }
      }
    } catch (e) {
      final errorMsg = 'FCM 초기화 중 오류가 발생했습니다: $e';
      state = state.copyWith(isInitialized: false, errorMessage: errorMsg);

      if (kDebugMode) {
        print('❌ FCM initialization error: $errorMsg');
      }
    }
  }

  /// iOS: APNs 토큰이 등록될 때까지 대기
  ///
  /// APNs 토큰이 등록되어야 FCM 토큰을 받을 수 있습니다.
  /// 최대 10초까지 대기하며, 0.5초마다 확인합니다.
  Future<void> _waitForAPNSToken() async {
    if (!Platform.isIOS) return;

    const maxAttempts = 20; // 10초 (0.5초 * 20)
    const delayDuration = Duration(milliseconds: 500);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) {
          if (kDebugMode) {
            print('✅ APNs token received');
          }
          return;
        }
      } catch (e) {
        // APNs 토큰이 아직 없음, 계속 대기
      }

      if (kDebugMode && attempt == 0) {
        print('⏳ Waiting for APNs token...');
      }

      await Future.delayed(delayDuration);
    }

    if (kDebugMode) {
      print(
        '⚠️  APNs token not received after 10 seconds. FCM token may not be available.',
      );
    }
  }

  /// 토큰 새로고침
  Future<void> _refreshToken() async {
    try {
      final token = await _messaging.getToken();

      // 토큰을 로컬에 저장
      if (token != null) {
        await FCMStorage.saveFCMToken(token);
      }

      state = state.copyWith(token: token, removeErrorMessage: true);

      if (kDebugMode && token != null) {
        print('🔥 FCM_TOKEN updated: $token');
        print('💾 FCM 토큰 로컬 저장 완료');

        // 토큰이 변경되었는지 확인
        final lastSentToken = FCMStorage.getLastSentToken();
        if (lastSentToken != token) {
          print('🔄 토큰이 변경되었습니다. 서버에 전송이 필요합니다.');
        } else {
          print('✅ 토큰이 서버와 동기화되어 있습니다.');
        }
      } else if (kDebugMode && token == null) {
        print('⚠️  FCM token is null.');
        print('💡 실기기에서 실행하거나, Google Play Services가 설치된 환경에서 실행하세요.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get FCM token: $e');
        print('💡 실기기에서 실행하거나, Google Play Services가 설치된 환경에서 실행하세요.');
      }
      state = state.copyWith(errorMessage: '토큰을 가져오는 중 오류가 발생했습니다.');
    }
  }

  /// 토큰 갱신 리스너 설정
  ///
  /// 토큰이 갱신될 때마다 자동으로 상태를 업데이트합니다.
  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((newToken) async {
      // 새 토큰을 로컬에 저장
      await FCMStorage.saveFCMToken(newToken);

      // 서버 동기화 상태 초기화 (새 토큰이므로 서버에 전송 필요)
      await FCMStorage.clearSyncStatus();

      state = state.copyWith(token: newToken);

      if (kDebugMode) {
        print('🔄 FCM_TOKEN refreshed: $newToken');
        print('💾 새 토큰 로컬 저장 완료');
        print('⚠️  서버에 새 토큰 전송이 필요합니다.');
      }

      // TODO: 서버에 새 토큰 업데이트 API 호출
      // await _updateTokenOnServer(newToken);
    });
  }

  /// 포그라운드 메시지 핸들러 설정
  ///
  /// 앱이 포그라운드에 있을 때 받은 메시지를 처리합니다.
  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('📨 Foreground message received:');
        print('   Title: ${message.notification?.title}');
        print('   Body: ${message.notification?.body}');
        print('   Data: ${message.data}');
        print(
          '   Platform: ${Platform.isIOS
              ? 'iOS'
              : Platform.isAndroid
              ? 'Android'
              : 'Unknown'}',
        );
      }

      // TODO: 포그라운드 알림 표시 로직 구현
      // 예: LocalNotificationService.showNotification(message);
    });
  }

  /// 토큰 수동 새로고침
  Future<void> refreshToken() async {
    await _refreshToken();
  }

  /// 현재 토큰 가져오기
  String? get currentToken => state.token;

  /// 초기화 여부 확인
  bool get isInitialized => state.isInitialized;
}

/// FCMNotifier Provider
///
/// Riverpod 3.x 방식: 생성자 참조 사용
final fcmNotifierProvider = NotifierProvider<FCMNotifier, FCMState>(
  FCMNotifier.new,
);

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-17
// 작성자: 김택권
// 설명: FCM Notifier - Firebase Cloud Messaging 토큰 관리 및 알림 처리
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-17 김택권: 초기 생성
//   - FCMState 클래스 생성 (FCM 상태 모델)
//   - FCMNotifier 클래스 생성 (Riverpod Notifier)
//   - initialize 메서드 구현 (FCM 초기화 및 토큰 가져오기)
//   - 토큰 갱신 리스너 설정
//   - 포그라운드 메시지 핸들러 설정
//   - 에러 처리 및 로딩 상태 관리
