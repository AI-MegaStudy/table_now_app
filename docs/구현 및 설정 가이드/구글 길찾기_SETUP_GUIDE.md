# Flutter Google Maps 길찾기 앱 설정 가이드

이 문서는 Flutter Google Maps 길찾기 앱의 설정 방법을 안내합니다.

## 목차

1. [Google Maps API 키 발급](#google-maps-api-키-발급)
2. [API 키 설정](#api-키-설정)
3. [패키지 정보](#패키지-정보)
4. [권한 설정](#권한-설정)
5. [의존성 패키지](#의존성-패키지)

---

## Google Maps API 키 발급

### 1. Google Cloud Console 접속

1. [Google Cloud Console](https://console.cloud.google.com/)에 접속합니다.
2. Google 계정으로 로그인합니다.

### 2. 프로젝트 생성 또는 선택

1. 상단의 프로젝트 선택 메뉴를 클릭합니다.
2. 새 프로젝트를 생성하거나 기존 프로젝트를 선택합니다.

### 3. 필요한 API 활성화

다음 API들을 활성화해야 합니다:

- **Maps SDK for Android** - Android 앱에서 Google Maps 사용
- **Maps SDK for iOS** - iOS 앱에서 Google Maps 사용
- **Directions API** - 두 지점 간의 경로 정보 가져오기

**활성화 방법:**
1. 좌측 메뉴에서 "API 및 서비스" > "라이브러리"를 선택합니다.
2. 위의 API들을 검색하여 각각 활성화합니다.

### 4. API 키 생성

1. 좌측 메뉴에서 "API 및 서비스" > "사용자 인증 정보"를 선택합니다.
2. 상단의 "+ 사용자 인증 정보 만들기" > "API 키"를 클릭합니다.
3. 생성된 API 키를 복사합니다.

### 5. API 키 제한 설정 (보안 권장)

생성된 API 키를 클릭하여 제한 설정을 추가합니다:

#### Android 제한 설정
- **애플리케이션 제한사항**: "Android 앱" 선택
- **패키지 이름**: `com.team01.tablenowapp`
- **SHA-1 인증서 지문**: `88:66:58:87:8E:DA:9E:2B:EC:BF:06:F5:05:1A:6C:5E:F7:2D:86:D8`

#### iOS 제한 설정
- **애플리케이션 제한사항**: "iOS 앱" 선택
- **Bundle ID**: `com.team01.tablenowapp`

#### API 제한 설정
- **API 제한사항**: "특정 API 제한" 선택
- 다음 API만 선택:
  - Maps SDK for Android
  - Maps SDK for iOS
  - Directions API

---

## API 키 설정

생성한 API 키를 다음 세 곳에 설정해야 합니다:

### 1. Android 설정

**파일**: `android/app/src/main/AndroidManifest.xml`

```xml
<application>
    <!-- 기존 코드... -->
    
    <!-- Google Maps API 키 -->
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="여기에_실제_API_키_입력"/>
</application>
```

### 2. iOS 설정

**파일**: `ios/Runner/AppDelegate.swift`

```swift
import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps API 키 설정
    GMSServices.provideAPIKey("여기에_실제_API_키_입력")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 3. Dart 코드 설정 (Directions API용)

**파일**: `lib/vm/route_provider.dart`

```dart
class RouteNotifier extends AsyncNotifier<RouteModel?> {
  /// Google Directions API 키
  static const String _apiKey = '여기에_실제_API_키_입력';
  
  // ... 나머지 코드
}
```

---

## 패키지 정보

### Android 패키지 이름

```
com.team01.tablenowapp
```

**위치**: `android/app/build.gradle.kts` (line 28)

### iOS Bundle ID

```
com.team01.tablenowapp
```

**위치**: `ios/Runner.xcodeproj/project.pbxproj`

---

## SHA-1 인증서 지문

### Debug Keystore SHA-1

```
88:66:58:87:8E:DA:9E:2B:EC:BF:06:F5:05:1A:6C:5E:F7:2D:86:D8
```

### SHA-256 (참고)

```
A7:5B:95:58:D2:3A:DA:FC:35:79:0F:B6:47:65:46:C5:F0:06:DA:4B:A4:01:A5:6C:CE:10:24:A0:7A:6B:56:3E
```

### SHA-1 확인 방법

터미널에서 다음 명령어를 실행하여 확인할 수 있습니다:

```bash
# Debug Keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release Keystore (릴리스 빌드용)
keytool -list -v -keystore [키스토어_경로] -alias [알리아스_이름]
```

---

## 권한 설정

### Android 권한

**파일**: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 위치 권한 -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- 나머지 코드... -->
</manifest>
```

### iOS 권한

**파일**: `ios/Runner/Info.plist`

```xml
<!-- 위치 권한 설정 -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>이 앱은 길찾기 기능을 위해 현재 위치 정보가 필요합니다.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>이 앱은 길찾기 기능을 위해 현재 위치 정보가 필요합니다.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>이 앱은 길찾기 기능을 위해 현재 위치 정보가 필요합니다.</string>
```

---

## 의존성 패키지

**파일**: `pubspec.yaml`

주요 패키지:

```yaml
dependencies:
  flutter_riverpod: ^3.1.0          # 상태 관리
  google_maps_flutter: ^2.5.3       # Google Maps
  geolocator: ^14.0.2                # 위치 정보
  flutter_polyline_points: ^2.0.0    # Polyline 디코딩
  http: ^1.1.0                       # HTTP 요청
```

### 패키지 설치

```bash
flutter pub get
```

---

## 앱 실행 전 체크리스트

- [ ] Google Cloud Console에서 프로젝트 생성 완료
- [ ] 필요한 API 활성화 완료 (Maps SDK for Android, Maps SDK for iOS, Directions API)
- [ ] API 키 생성 완료
- [ ] API 키 제한 설정 완료 (Android 패키지명, SHA-1, iOS Bundle ID)
- [ ] AndroidManifest.xml에 API 키 설정 완료
- [ ] AppDelegate.swift에 API 키 설정 완료
- [ ] route_provider.dart에 API 키 설정 완료
- [ ] 위치 권한 설정 완료 (Android, iOS)
- [ ] 패키지 설치 완료 (`flutter pub get`)

---

## 문제 해결

### Authorization failure 에러 (지도가 표시되지 않는 경우)

**에러 메시지 예시:**
```
E/Google Android Maps SDK: Authorization failure
E/Google Android Maps SDK: Ensure that the "Maps SDK for Android" is enabled.
E/Google Android Maps SDK: Ensure that the following Android Key exists:
```

**해결 방법:**

1. **Maps SDK for Android 활성화 확인**
   - Google Cloud Console → API 및 서비스 → 라이브러리
   - "Maps SDK for Android" 검색
   - 활성화되어 있는지 확인 (활성화되지 않았다면 활성화)

2. **API 키 제한 설정 확인**
   - Google Cloud Console → API 및 서비스 → 사용자 인증 정보
   - 사용 중인 API 키 클릭
   - **애플리케이션 제한사항**: "Android 앱" 선택
   - **패키지 이름**: `com.team01.tablenowapp` 추가
   - **SHA-1 인증서 지문**: `88:66:58:87:8E:DA:9E:2B:EC:BF:06:F5:05:1A:6C:5E:F7:2D:86:D8` 추가
   - 저장 클릭

3. **API 제한 확인**
   - **API 제한사항**: "특정 API 제한" 선택
   - 다음 API만 선택:
     - Maps SDK for Android ✅
     - Maps SDK for iOS ✅
     - Directions API ✅
   - 저장 클릭

4. **설정 적용 대기**
   - Google Cloud Console의 설정 변경은 최대 5분 정도 소요될 수 있습니다
   - 설정 변경 후 앱을 완전히 재시작하세요

### 앱이 크래시되는 경우

1. **API 키가 설정되지 않음**
   - AndroidManifest.xml과 AppDelegate.swift에 API 키가 올바르게 설정되었는지 확인
   - API 키에 공백이나 따옴표가 포함되지 않았는지 확인

2. **위치 권한 오류**
   - AndroidManifest.xml에 위치 권한이 추가되었는지 확인
   - iOS Info.plist에 위치 권한 설명이 추가되었는지 확인
   - 앱을 완전히 재빌드 (`flutter clean && flutter pub get && flutter run`)

3. **경로를 불러올 수 없는 경우**
   - Directions API가 활성화되었는지 확인
   - API 키 제한 설정에서 Directions API가 허용되었는지 확인
   - route_provider.dart의 API 키가 올바른지 확인

### SHA-1 지문이 다른 경우

- Release 빌드를 사용하는 경우 Release Keystore의 SHA-1을 사용해야 합니다
- Google Cloud Console에 Debug와 Release SHA-1을 모두 추가할 수 있습니다

---

## 추가 리소스

- [Google Maps Platform 문서](https://developers.google.com/maps/documentation)
- [Flutter Google Maps 플러그인](https://pub.dev/packages/google_maps_flutter)
- [Google Directions API 문서](https://developers.google.com/maps/documentation/directions)

---

**마지막 업데이트**: 2025년 1월
