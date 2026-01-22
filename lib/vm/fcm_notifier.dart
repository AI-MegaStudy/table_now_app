import 'dart:io' show Platform;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:table_now_app/config.dart';
import 'package:table_now_app/utils/customer_storage.dart';
import 'package:table_now_app/utils/fcm_storage.dart';
import 'package:table_now_app/utils/local_notification_service.dart';
import 'package:table_now_app/utils/current_screen_tracker.dart';

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
  bool _isRefreshingToken = false; // 토큰 새로고침 중복 방지 플래그

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
      // 프로필/릴리스 모드에서도 초기화 시작 확인 가능하도록 항상 출력
      print('🚀 FCM 초기화 시작...');
      print(
        '📱 Platform: ${Platform.isIOS
            ? 'iOS'
            : Platform.isAndroid
            ? 'Android'
            : 'Unknown'}',
      );

      // iOS 알림 권한 요청 (필수)
      if (Platform.isIOS) {
        // 현재 알림 권한 상태 확인
        final currentStatus = await _messaging.getNotificationSettings();
        print('📱 현재 알림 권한 상태: ${currentStatus.authorizationStatus}');
        
        // 권한이 없으면 요청
        if (currentStatus.authorizationStatus == AuthorizationStatus.notDetermined) {
          print('📱 알림 권한 요청 중...');
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

          // 프로필/릴리스 모드에서도 권한 상태 확인 가능하도록 항상 출력
          print('📱 iOS 알림 권한 요청 결과: ${permission.authorizationStatus}');
          
          if (permission.authorizationStatus == AuthorizationStatus.denied) {
            print('⚠️  알림 권한이 거부되었습니다.');
            print('💡 설정 > TableNow > 알림에서 권한을 활성화하세요.');
            state = state.copyWith(
              errorMessage: '알림 권한이 거부되었습니다. 설정에서 활성화하세요.',
              isInitialized: true, // 초기화는 완료했지만 토큰은 받지 못함
            );
            return; // 권한이 거부되면 APNs 토큰을 받을 수 없음
          }
        } else if (currentStatus.authorizationStatus == AuthorizationStatus.denied) {
          print('⚠️  알림 권한이 거부되어 있습니다.');
          print('💡 설정 > TableNow > 알림에서 권한을 활성화하세요.');
          state = state.copyWith(
            errorMessage: '알림 권한이 거부되어 있습니다. 설정에서 활성화하세요.',
            isInitialized: true, // 초기화는 완료했지만 토큰은 받지 못함
          );
          return; // 권한이 거부되면 APNs 토큰을 받을 수 없음
        } else {
          print('📱 알림 권한이 이미 허용되어 있습니다: ${currentStatus.authorizationStatus}');
        }

        // iOS: 로컬 알림 서비스 초기화 (포그라운드 알림 표시용)
        await LocalNotificationService.initialize();
        
        // iOS: APNs 토큰이 등록될 때까지 대기 (권한이 허용된 경우에만)
        await _waitForAPNSToken();
      } else if (Platform.isAndroid) {
        // Android: 로컬 알림 서비스 초기화 및 권한 요청 (FCM 토큰 발급 전에 먼저!)
        print('📱 Android: 알림 권한 요청 및 로컬 알림 서비스 초기화...');
        await LocalNotificationService.initialize();
      }

      // 초기 토큰 가져오기 (권한 허용 후)
      await _refreshToken();

      // 토큰 갱신 리스너 설정
      _setupTokenRefreshListener();

      // 포그라운드 메시지 핸들러 설정
      _setupForegroundMessageHandler();

      // 백그라운드/종료 상태 알림 클릭 핸들러 설정
      _setupBackgroundMessageHandlers();

      state = state.copyWith(isInitialized: true, removeErrorMessage: true);

      // 프로필/릴리스 모드에서도 초기화 상태 확인 가능하도록 항상 출력
      print('✅ FCM initialized successfully');
      print('🔥 FCM_TOKEN = ${state.token ?? "null"}');

      if (state.token == null) {
        print('⚠️  FCM 토큰을 받지 못했습니다.');
        print('📝 실기기에서 실행하거나, Google Play Services가 설치된 환경에서 실행하세요.');
      }
    } catch (e, stackTrace) {
      final errorMsg = 'FCM 초기화 중 오류가 발생했습니다: $e';
      state = state.copyWith(isInitialized: false, errorMessage: errorMsg);

      // 프로필/릴리스 모드에서도 에러 확인 가능하도록 항상 출력
      print('❌ FCM initialization error: $errorMsg');
      print('Stack trace: $stackTrace');
    }
  }

  /// iOS: APNs 토큰이 등록될 때까지 대기
  ///
  /// APNs 토큰이 등록되어야 FCM 토큰을 받을 수 있습니다.
  /// 최대 30초까지 대기하며, 1초마다 확인합니다.
  /// IPA로 설치한 앱은 초기화가 더 느릴 수 있으므로 대기 시간을 늘렸습니다.
  Future<void> _waitForAPNSToken() async {
    if (!Platform.isIOS) return;

    const maxAttempts = 30; // 30초 (1초 * 30)
    const delayDuration = Duration(seconds: 1);

    print('⏳ APNs 토큰 대기 시작... (최대 ${maxAttempts}초)');

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) {
          print('✅ APNs token received (${attempt + 1}초 후)');
          return;
        }
      } catch (e) {
        // APNs 토큰이 아직 없음, 계속 대기
      }

      // 5초마다 진행 상황 출력
      if ((attempt + 1) % 5 == 0) {
        print('⏳ APNs 토큰 대기 중... (${attempt + 1}/${maxAttempts}초)');
      }

      await Future.delayed(delayDuration);
    }

    // 프로필/릴리스 모드에서도 경고 확인 가능하도록 항상 출력
    print(
      '⚠️  APNs token not received after ${maxAttempts} seconds. FCM token may not be available.',
    );
    print('💡 IPA로 설치한 앱은 초기화가 더 느릴 수 있습니다. 앱을 재시작하거나 잠시 후 다시 시도하세요.');
  }

  /// 토큰 새로고침
  /// 
  /// "Too many server requests" 오류 발생 시 재시도 로직 포함
  Future<void> _refreshToken() async {
    // 중복 호출 방지
    if (_isRefreshingToken) {
      print('⏸️  FCM 토큰 새로고침이 이미 진행 중입니다.');
      return;
    }
    
    _isRefreshingToken = true;
    
    try {
      const maxRetries = 3;
      const baseDelay = Duration(seconds: 2);
      
      for (int attempt = 0; attempt < maxRetries; attempt++) {
        try {
          // 재시도 시 지연 시간 추가 (지수 백오프)
          if (attempt > 0) {
            final delay = baseDelay * (attempt + 1);
            print('⏳ FCM 토큰 요청 재시도 중... (${attempt + 1}/$maxRetries, ${delay.inSeconds}초 대기)');
            await Future.delayed(delay);
          }
          
          final token = await _messaging.getToken();

          // 토큰을 로컬에 저장
          if (token != null) {
            await FCMStorage.saveFCMToken(token);
          }

          state = state.copyWith(token: token, removeErrorMessage: true);

          // 프로필/릴리스 모드에서도 토큰 상태 확인 가능하도록 항상 출력
          if (token != null) {
            print('🔥 FCM_TOKEN updated: $token');
            print('💾 FCM 토큰 로컬 저장 완료');

            // 토큰이 변경되었는지 확인
            final lastSentToken = FCMStorage.getLastSentToken();
            if (lastSentToken != token) {
              print('🔄 토큰이 변경되었습니다. 서버에 전송이 필요합니다.');
            } else {
              print('✅ 토큰이 서버와 동기화되어 있습니다.');
            }
          } else {
            print('⚠️  FCM token is null.');
            print('💡 실기기에서 실행하거나, Google Play Services가 설치된 환경에서 실행하세요.');
          }
          
          // 성공 시 반환
          return;
        } catch (e) {
          final errorMessage = e.toString();
          
          // "Too many server requests" 오류인 경우 재시도
          if (errorMessage.contains('Too many server requests') && attempt < maxRetries - 1) {
            print('⚠️  FCM 서버 요청 제한 초과. 재시도 예정...');
            continue;
          }
          
          // 프로필/릴리스 모드에서도 에러 확인 가능하도록 항상 출력
          print('❌ Failed to get FCM token: $e');
          if (attempt == maxRetries - 1) {
            print('💡 최대 재시도 횟수에 도달했습니다. 잠시 후 다시 시도하세요.');
          } else {
            print('💡 실기기에서 실행하거나, Google Play Services가 설치된 환경에서 실행하세요.');
          }
          
          // 마지막 시도에서도 실패한 경우에만 에러 상태 설정
          if (attempt == maxRetries - 1) {
            state = state.copyWith(errorMessage: '토큰을 가져오는 중 오류가 발생했습니다. 잠시 후 다시 시도하세요.');
          }
        }
      }
    } finally {
      _isRefreshingToken = false;
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

      // 로그인 상태 확인 후 서버에 새 토큰 전송
      // CustomerStorage를 사용하여 로그인 상태 확인
      try {
        final customerSeq = CustomerStorage.getCustomerSeq();
        if (customerSeq != null) {
          if (kDebugMode) {
            print('🔄 토큰 갱신 감지: 서버에 새 토큰 전송 중...');
          }
          await sendTokenToServer(customerSeq);
        } else if (kDebugMode) {
          print('⚠️  로그인 상태가 아니어서 서버 전송을 건너뜁니다.');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️  토큰 갱신 후 서버 전송 실패: $e');
        }
      }
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
          '   Platform: ${Platform.isIOS ? "iOS" : Platform.isAndroid ? "Android" : "Unknown"}',
        );
      }

      // 포그라운드 알림 표시 (로컬 노티피케이션 사용)
      LocalNotificationService.showNotification(message);
    });
  }

  /// 백그라운드/종료 상태 알림 클릭 핸들러 설정
  ///
  /// 앱이 백그라운드나 종료 상태에서 알림을 클릭했을 때 처리합니다.
  void _setupBackgroundMessageHandlers() {
    // 백그라운드 상태에서 알림 클릭
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message, '백그라운드');
    });

    // 앱 종료 상태에서 알림 클릭으로 앱 실행
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationTap(message, '종료 상태');
      }
    });
  }

  /// 알림 클릭 처리 (공통 핸들러)
  ///
  /// 포그라운드, 백그라운드, 종료 상태 모두에서 사용됩니다.
  void _handleNotificationTap(RemoteMessage message, String state) {
    if (kDebugMode) {
      print('🔔 알림 클릭 ($state):');
      print('   Title: ${message.notification?.title}');
      print('   Body: ${message.notification?.body}');
      print('   Data: ${message.data}');
    }

    // 현재 화면 정보 가져오기 (백그라운드/종료 상태에서는 null일 수 있음)
    final currentScreen = CurrentScreenTracker.getCurrentScreen();

    if (kDebugMode) {
      if (currentScreen != null) {
        print('   현재 화면: $currentScreen');
      } else {
        print('   현재 화면: 알 수 없음 (앱이 백그라운드/종료 상태였을 수 있음)');
      }

      // 데이터 파싱
      if (message.data.isNotEmpty) {
        try {
          print('   데이터: ${message.data}');
        } catch (e) {
          print('   데이터 파싱 실패: $e');
        }
      }
    }

    // TODO: 여기에 화면 이동 로직 추가
    // 예: message.data['screen']에 따라 적절한 화면으로 이동
    // navigatorKey를 사용하여 화면 이동
  }

  /// 토큰 수동 새로고침
  Future<void> refreshToken() async {
    await _refreshToken();
  }

  /// FCM 초기화 재시도
  /// 
  /// 알림 권한이 거부된 경우 설정에서 활성화한 후 이 메서드를 호출하세요.
  Future<void> retryInitialization() async {
    print('🔄 FCM 초기화 재시도 중...');
    await initialize();
  }

  /// 현재 토큰 가져오기
  String? get currentToken => state.token;

  /// 초기화 여부 확인
  bool get isInitialized => state.isInitialized;

  /// 서버에 FCM 토큰 전송
  ///
  /// 기기 식별자 가져오기
  /// Android: androidId, iOS: identifierForVendor
  Future<String?> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id; // Settings.Secure.ANDROID_ID
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor; // IDFV
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️  기기 식별자 가져오기 실패: $e');
      }
      return null;
    }
  }

  /// [customerSeq] 고객 번호
  /// 반환값: 성공 여부 (bool)
  Future<bool> sendTokenToServer(int customerSeq) async {
    final token = state.token;
    if (token == null) {
      if (kDebugMode) {
        print('⚠️  FCM 토큰이 없어 서버에 전송할 수 없습니다.');
      }
      return false;
    }

    try {
      await FCMStorage.saveLastSyncAttempt(DateTime.now());

      // 기기 식별자 가져오기
      final deviceId = await _getDeviceId();
      if (deviceId == null && kDebugMode) {
        print('⚠️  기기 식별자를 가져올 수 없습니다. 기기 식별 없이 진행합니다.');
      }

      // getApiBaseUrl()은 동기 함수 (앱 시작 시 초기화됨)
      final apiBaseUrl = getApiBaseUrl();
      final url = Uri.parse('$apiBaseUrl/api/customer/$customerSeq/fcm-token');

      if (kDebugMode) {
        print('📤 서버에 FCM 토큰 전송 중...');
        print('   URL: $url');
        print('   Token: ${token.substring(0, 20)}...');
        if (deviceId != null) {
          print('   Device ID: $deviceId');
        }
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fcm_token': token,
          'device_type': Platform.isIOS ? 'ios' : 'android',
          if (deviceId != null) 'device_id': deviceId,
        }),
      );

      if (response.statusCode == 200) {
        await FCMStorage.saveLastSentToken(token);
        await FCMStorage.setServerSyncStatus(true);

        if (kDebugMode) {
          print('✅ FCM 토큰 서버 전송 성공');
        }
        return true;
      } else {
        await FCMStorage.setServerSyncStatus(false);

        if (kDebugMode) {
          print('❌ FCM 토큰 서버 전송 실패: ${response.statusCode}');
          print('   Response: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      await FCMStorage.setServerSyncStatus(false);

      if (kDebugMode) {
        print('❌ FCM 토큰 서버 전송 중 오류 발생: $e');
      }
      return false;
    }
  }
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
