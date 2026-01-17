import FirebaseMessaging
import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Firebase 초기화는 FlutterFire 플러그인이 자동으로 처리합니다
    // Flutter의 main.dart에서 Firebase.initializeApp()을 호출하므로
    // 여기서 중복 호출하면 크래시가 발생할 수 있습니다

    // FCM을 위한 UNUserNotificationCenter delegate 설정
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    // FirebaseAppDelegateProxyEnabled가 false이므로 수동으로 APNs 등록 요청
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Google Sign-In URL 핸들링
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    return super.application(app, open: url, options: options)
  }

  // APNs 토큰 등록 (FCM 토큰을 받기 위해 필요)
  // FirebaseAppDelegateProxyEnabled가 false이므로 수동으로 처리해야 함
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // Firebase Messaging에 APNs 토큰 전달 (수동 처리)
    Messaging.messaging().apnsToken = deviceToken

    print("✅ APNs token registered successfully")

    // 부모 클래스 메서드도 호출
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // APNs 토큰 등록 실패 처리
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}

// ============================================================
// 생성 이력
// ============================================================
// 작성일: 2026-01-15
// 작성자: 김택권
// 설명: iOS AppDelegate - Google Sign-In URL 핸들링을 위한 설정
//
// ============================================================
// 수정 이력
// ============================================================
// 2026-01-15 김택권: 초기 생성
//   - application:openURL:options: 메서드 추가
//   - Google Sign-In 리다이렉트 URL 처리 구현
