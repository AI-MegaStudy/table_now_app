import FirebaseMessaging
import Flutter
import UIKit
import UserNotifications
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps API 키 설정 (Firebase가 자동 생성한 iOS 키 사용)
    GMSServices.provideAPIKey("AIzaSyDGH3b2j4ZZ5PA0_Bz-lxLRYSRrysCqBFw")
    
    GeneratedPluginRegistrant.register(with: self)

    // Firebase 초기화는 FlutterFire 플러그인이 자동으로 처리합니다
    // Flutter의 main.dart에서 Firebase.initializeApp()을 호출하므로
    // 여기서 중복 호출하면 크래시가 발생할 수 있습니다

    // FCM을 위한 UNUserNotificationCenter delegate 설정
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      print("✅ UNUserNotificationCenter delegate 설정 완료")
    }

    // FirebaseAppDelegateProxyEnabled가 false이므로 수동으로 APNs 등록 요청
    print("📱 APNs 등록 요청 시작...")
    application.registerForRemoteNotifications()
    print("📱 APNs 등록 요청 완료 (결과는 didRegisterForRemoteNotificationsWithDeviceToken에서 확인)")

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
    // APNs 토큰을 문자열로 변환하여 출력 (디버깅용)
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("✅ APNs token received: \(token)")
    print("📱 APNs token length: \(deviceToken.count) bytes")
    
    // Firebase Messaging에 APNs 토큰 전달 (수동 처리)
    Messaging.messaging().apnsToken = deviceToken
    print("✅ APNs token set to Firebase Messaging")

    // 부모 클래스 메서드도 호출
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // APNs 토큰 등록 실패 처리
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("❌ Failed to register for remote notifications")
    print("   Error: \(error.localizedDescription)")
    print("   Error domain: \((error as NSError).domain)")
    print("   Error code: \((error as NSError).code)")
    
    // 일반적인 에러 원인 안내
    let nsError = error as NSError
    if nsError.code == 3010 {
      print("💡 시뮬레이터에서는 APNs 토큰을 받을 수 없습니다. 실기기에서 테스트하세요.")
    } else if nsError.domain == "NSCocoaErrorDomain" {
      print("💡 코드 사이닝 또는 프로비저닝 프로파일 문제일 수 있습니다.")
      print("💡 Xcode에서 Signing & Capabilities 설정을 확인하세요.")
    }
    
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
