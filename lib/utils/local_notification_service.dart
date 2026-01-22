import 'dart:convert';
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 로컬 노티피케이션 서비스
///
/// 포그라운드 상태에서 FCM 메시지를 받았을 때 알림을 표시합니다.
class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// 알림 클릭 시 실행될 콜백
  static Function(NotificationResponse)? onNotificationTap;

  /// 초기화
  ///
  /// Android와 iOS 각각의 설정을 초기화합니다.
  static Future<void> initialize() async {
    try {
      if (kDebugMode) {
        print('🔔 LocalNotificationService 초기화 시작...');
      }

      // Android 초기화 설정
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS 초기화 설정
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // 초기화 설정 통합
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // 초기화 및 알림 클릭 핸들러 설정
      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (kDebugMode) {
            print('🔔 알림 클릭: ${response.payload}');
          }
          onNotificationTap?.call(response);
        },
      );

      if (initialized != true) {
        if (kDebugMode) {
          print('⚠️  LocalNotificationService 초기화 실패');
        }
        return;
      }

      // Android Notification Channel 생성 및 권한 요청
      if (Platform.isAndroid) {
        await _createNotificationChannel();
        await _requestAndroidNotificationPermission();
      }

      if (kDebugMode) {
        print('✅ LocalNotificationService 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ LocalNotificationService 초기화 오류: $e');
      }
    }
  }

  /// Android Notification Channel 생성
  ///
  /// Android 8.0 (API 26) 이상에서 알림을 표시하려면 채널이 필요합니다.
  static Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel', // 채널 ID (AndroidManifest.xml과 일치)
      'High Importance Notifications', // 채널 이름
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    if (kDebugMode) {
      print('✅ Android Notification Channel 생성 완료');
    }
  }

  /// Android 13+ 알림 권한 요청
  ///
  /// Android 13 (API 33) 이상에서는 POST_NOTIFICATIONS 권한을 런타임에 요청해야 합니다.
  static Future<void> _requestAndroidNotificationPermission() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        if (kDebugMode) {
          print('📱 Android 알림 권한 요청 중...');
        }
        
        // Android 13+ 시스템 권한 다이얼로그 표시
        final bool? granted = await androidImplementation.requestNotificationsPermission();
        
        if (kDebugMode) {
          if (granted == true) {
            print('✅ Android 알림 권한이 허용되었습니다.');
          } else {
            print('⚠️  Android 알림 권한이 거부되었습니다.');
            print('💡 설정 > 앱 > TableNow > 알림에서 권한을 활성화하세요.');
          }
        }
      } else {
        if (kDebugMode) {
          print('📱 Android 13 미만 - 런타임 권한 요청 불필요');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️  Android 알림 권한 요청 실패: $e');
      }
    }
  }

  /// 알림 표시
  ///
  /// FCM RemoteMessage를 받아서 로컬 알림으로 표시합니다.
  static Future<void> showNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      if (notification == null) {
        if (kDebugMode) {
          print('⚠️  알림 데이터가 없습니다.');
        }
        return;
      }

      // 알림 ID 생성 (밀리초 단위로 고유 ID 보장)
      // 안드로이드에서 동일한 알림 ID는 카운트만 증가하므로, 매번 고유한 ID 생성 필요
      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(2147483647);

      // Android 알림 세부 설정
      const androidDetails = AndroidNotificationDetails(
        'high_importance_channel', // 채널 ID
        'High Importance Notifications', // 채널 이름
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        playSound: true,
        enableVibration: true,
      );

      // iOS 알림 세부 설정
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // 알림 세부 설정 통합
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // data를 JSON 문자열로 변환 (알림 클릭 시 활용)
      String? payload;
      if (message.data.isNotEmpty) {
        try {
          payload = jsonEncode(message.data);
        } catch (e) {
          if (kDebugMode) {
            print('⚠️  data를 JSON으로 변환 실패: $e');
          }
          // 변환 실패 시 빈 문자열 사용
          payload = '';
        }
      }

      // 알림 표시
      await _notifications.show(
        notificationId,
        notification.title,
        notification.body,
        notificationDetails,
        payload: payload, // 알림 클릭 시 전달할 데이터 (JSON 문자열)
      );

      if (kDebugMode) {
        print('✅ 알림 표시 완료: ${notification.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 알림 표시 오류: $e');
      }
    }
  }

  /// 알림 클릭 핸들러 설정
  ///
  /// 알림을 클릭했을 때 실행될 콜백을 설정합니다.
  static void setOnNotificationTap(Function(NotificationResponse) callback) {
    onNotificationTap = callback;
  }
}
