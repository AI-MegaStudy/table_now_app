# iOS 프로파일 빌드 가이드

**작성일**: 2026-01-21  
**작성자**: 김택권  
**설명**: Flutter 앱의 iOS 프로파일(Profile) 빌드 방법 및 설정 가이드

---

## 목차

1. [개요](#개요)
2. [사전 준비사항](#사전-준비사항)
3. [빌드 방법](#빌드-방법)
4. [Xcode 설정 확인](#xcode-설정-확인)
5. [프로비저닝 프로파일 설정](#프로비저닝-프로파일-설정)
6. [실기기 테스트](#실기기-테스트)
7. [문제 해결](#문제-해결)
8. [참고 자료](#참고-자료)

---

## 개요

### 프로파일 빌드란?

- **Profile 빌드**: 성능 측정 및 최적화를 위한 빌드 모드
- **특징**:
  - Release 모드와 유사한 최적화 적용
  - 디버깅 정보 일부 포함 (성능 분석 가능)
  - 실기기 테스트에 적합
  - App Store 배포 전 최종 테스트용

### 빌드 모드 비교

| 모드 | 최적화 | 디버깅 | 용도 |
|------|--------|--------|------|
| Debug | 없음 | 가능 | 개발 중 테스트 |
| Profile | 있음 | 제한적 | 성능 측정, 실기기 테스트 |
| Release | 최대 | 불가 | App Store 배포 |

---

## 사전 준비사항

### 1. 개발 환경

- **macOS**: 최신 버전 권장
- **Xcode**: 최신 버전 (현재 iOS 15.0 이상 지원)
- **Flutter**: `flutter doctor` 명령어로 환경 확인
- **CocoaPods**: `pod --version` 확인

### 2. Apple Developer 계정

- Apple Developer Program 가입 (연간 $99)
- 개발자 계정으로 로그인 가능해야 함

### 3. 프로젝트 설정 확인

```bash
# Flutter 환경 확인
flutter doctor

# iOS 디렉토리로 이동
cd ios

# CocoaPods 의존성 설치
pod install

# 프로젝트 루트로 복귀
cd ..
```

---

## 빌드 방법

### 방법 1: Flutter CLI 사용 (권장)

#### 시뮬레이터용 빌드

```bash
# 프로파일 모드로 빌드
flutter build ios --profile

# 특정 시뮬레이터 지정
flutter build ios --profile --simulator
```

#### 실기기용 빌드

```bash
# 프로파일 모드로 빌드 (실기기)
flutter build ios --profile --release

# 특정 기기 지정
flutter build ios --profile --release --device-id=<DEVICE_ID>
```

#### 빌드 옵션

```bash
# 버전 및 빌드 번호 지정
flutter build ios --profile \
  --build-name=1.0.0 \
  --build-number=1

# 특정 타겟 지정
flutter build ios --profile --target=lib/main.dart
```

### 방법 2: Xcode 사용

1. **Xcode 프로젝트 열기**
   ```bash
   open ios/Runner.xcworkspace
   ```
   ⚠️ **주의**: `.xcworkspace` 파일을 열어야 합니다 (`.xcodeproj` 아님)

2. **빌드 설정 선택**
   - 상단 툴바에서 **Scheme**: `Runner` 선택
   - **Configuration**: `Profile` 선택

3. **빌드 실행**
   - 메뉴: **Product** → **Build** (⌘B)
   - 또는 **Product** → **Run** (⌘R) - 자동 실행

4. **아카이브 생성** (배포용)
   - 메뉴: **Product** → **Archive**
   - Archive 완료 후 **Distribute App** 선택

### 방법 3: 명령어로 직접 실행

```bash
# 프로파일 모드로 실행
flutter run --profile

# 특정 기기 지정
flutter run --profile -d <DEVICE_ID>

# 기기 목록 확인
flutter devices
```

---

## Xcode 설정 확인

### 1. Bundle Identifier 확인

**위치**: `ios/Runner.xcodeproj` → Runner 타겟 → General

- **현재 설정**: `com.team01.tablenowapp`
- Apple Developer Portal의 App ID와 일치해야 함

### 2. Signing & Capabilities 확인

**위치**: `ios/Runner.xcodeproj` → Runner 타겟 → Signing & Capabilities

#### 필수 설정

- ✅ **Automatically manage signing**: 체크
- ✅ **Team**: 개발자 팀 선택 (예: `M382EW7FD8`)
- ✅ **Provisioning Profile**: 자동 선택됨

#### Capabilities 확인

- ✅ **Push Notifications**: FCM 푸시 알림용
- ✅ **Background Modes**: `Remote notifications` 체크
- ✅ **Sign in with Apple** (필요시)
- ✅ **Maps** (Google Maps 사용 시)

### 3. Build Settings 확인

**위치**: `ios/Runner.xcodeproj` → Runner 타겟 → Build Settings

#### Profile 빌드 설정 확인

- **Code Signing Entitlements**: `Runner/Runner.entitlements`
- **Development Team**: `M382EW7FD8` (또는 본인 팀 ID)
- **iOS Deployment Target**: `13.0` 이상

#### 확인 방법

```bash
# project.pbxproj 파일에서 확인
grep -A 5 "name = Profile" ios/Runner.xcodeproj/project.pbxproj
```

---

## 프로비저닝 프로파일 설정

### 1. Apple Developer Portal 설정

#### App ID 생성/확인

1. [Apple Developer Portal](https://developer.apple.com/account/) 접속
2. **Certificates, Identifiers & Profiles** 선택
3. **Identifiers** → **App IDs** 확인
4. `com.team01.tablenowapp` 확인 또는 생성

#### Capabilities 설정

App ID에서 다음 Capabilities 활성화:
- ✅ **Push Notifications**
- ✅ **Background Modes**
- ✅ **Sign in with Apple** (필요시)

### 2. 프로비저닝 프로파일 생성

#### Development Profile (개발용)

1. **Profiles** → **+** 버튼 클릭
2. **Development** 선택
3. App ID 선택: `com.team01.tablenowapp`
4. 인증서 선택: 개발용 인증서
5. 기기 선택: 테스트할 기기 등록
6. 프로파일 이름 지정 후 생성

#### Distribution Profile (배포용)

1. **Profiles** → **+** 버튼 클릭
2. **App Store** 또는 **Ad Hoc** 선택
3. App ID 선택
4. 인증서 선택: 배포용 인증서
5. 기기 선택 (Ad Hoc의 경우)
6. 프로파일 이름 지정 후 생성

### 3. Xcode에서 프로파일 다운로드

1. Xcode 실행
2. **Preferences** (⌘,) → **Accounts**
3. Apple ID 선택 → **Download Manual Profiles**
4. 또는 Xcode가 자동으로 다운로드 (Automatically manage signing 사용 시)

---

## 실기기 테스트

### 1. 기기 등록

#### Apple Developer Portal에서 등록

1. **Devices** → **+** 버튼 클릭
2. 기기 이름 및 UDID 입력
3. UDID 확인 방법:
   - Mac: Finder → 기기 연결 → 정보에서 확인
   - 또는 Xcode: Window → Devices and Simulators

#### Xcode에서 자동 등록

- 기기를 연결하면 Xcode가 자동으로 등록 시도
- 신뢰하지 않는 개발자 경고 시 기기에서 "신뢰" 선택

### 2. 기기 연결 및 실행

```bash
# 연결된 기기 확인
flutter devices

# 프로파일 모드로 실행
flutter run --profile

# 특정 기기 지정
flutter run --profile -d <DEVICE_ID>
```

### 3. 빌드 파일 위치

빌드 완료 후 파일 위치:
```
build/ios/iphoneos/Runner.app
```

---

## 문제 해결

### 1. Code Signing 오류

#### 증상
```
Code signing is required for product type 'Application' in SDK 'iOS'
```

#### 해결 방법

1. **Xcode에서 확인**
   - Runner 타겟 → Signing & Capabilities
   - Team 선택 확인
   - Automatically manage signing 체크

2. **프로비저닝 프로파일 확인**
   ```bash
   # 프로파일 목록 확인
   security find-identity -v -p codesigning
   ```

3. **캐시 정리**
   ```bash
   # Flutter 클린
   flutter clean
   
   # Pod 재설치
   cd ios
   rm -rf Pods Podfile.lock
   pod install
   cd ..
   ```

### 2. Provisioning Profile 오류

#### 증상
```
No profiles for 'com.team01.tablenowapp' were found
```

#### 해결 방법

1. **Apple Developer Portal에서 프로파일 확인**
   - App ID가 올바른지 확인
   - 프로파일이 생성되어 있는지 확인

2. **Xcode에서 프로파일 새로고침**
   - Preferences → Accounts → Download Manual Profiles

3. **수동으로 프로파일 설치**
   - Developer Portal에서 프로파일 다운로드
   - 더블클릭하여 설치

### 3. Entitlements 오류

#### 증상
```
Code signing is required for product type 'Application' in SDK 'iOS'
```

#### 해결 방법

1. **project.pbxproj 확인**
   ```bash
   # Profile 빌드 설정에 CODE_SIGN_ENTITLEMENTS 확인
   grep -A 10 "name = Profile" ios/Runner.xcodeproj/project.pbxproj
   ```

2. **Xcode에서 확인**
   - Runner 타겟 → Build Settings
   - Code Signing Entitlements: `Runner/Runner.entitlements`

### 4. CocoaPods 오류

#### 증상
```
[!] CocoaPods could not find compatible versions
```

#### 해결 방법

```bash
# Pod 캐시 정리
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install --repo-update
cd ..
```

### 5. 빌드 실패 (Framework not found)

#### 증상
```
Framework 'FirebaseCore' not found
```

#### 해결 방법

```bash
# Flutter 클린 및 재빌드
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter build ios --profile
```

### 6. 시뮬레이터 vs 실기기 차이

#### 시뮬레이터에서만 작동하는 기능
- 일부 네이티브 기능 (푸시 알림 등)
- 위치 서비스 (제한적)

#### 실기기에서만 테스트해야 하는 기능
- FCM 푸시 알림
- 위치 서비스 (실제 GPS)
- 카메라/갤러리 접근
- 생체 인증

---

## 빌드 최적화 팁

### 1. 빌드 시간 단축

```bash
# 병렬 빌드 활성화
flutter build ios --profile --split-debug-info=<DIR>

# 빌드 캐시 활용
flutter build ios --profile --no-tree-shake-icons
```

### 2. 앱 크기 최적화

```bash
# 불필요한 리소스 제거
flutter build ios --profile --split-debug-info=<DIR> --obfuscate
```

### 3. 성능 분석

- Xcode Instruments 사용
- **Product** → **Profile** (⌘I)
- Time Profiler, Allocations 등 도구 활용

---

## 현재 프로젝트 설정 정보

### Bundle Identifier
```
com.team01.tablenowapp
```

### Development Team
```
M382EW7FD8
```

### iOS Deployment Target
```
13.0
```

### 주요 Capabilities
- ✅ Push Notifications (FCM)
- ✅ Background Modes (Remote notifications)
- ✅ Sign in with Apple (Google Sign-In)
- ✅ Maps (Google Maps)

### Info.plist 주요 설정
- 위치 권한: `NSLocationWhenInUseUsageDescription`
- 알림 권한: `NSUserNotificationsUsageDescription`
- Google Sign-In URL Scheme 설정됨
- App Transport Security 설정 (개발용)

---

## 참고 자료

### 공식 문서
- [Flutter iOS 배포 가이드](https://docs.flutter.dev/deployment/ios)
- [Apple Developer Portal](https://developer.apple.com/account/)
- [Xcode 빌드 설정 가이드](https://developer.apple.com/documentation/xcode)

### 프로젝트 관련 문서
- `docs/구현 및 설정 가이드/FCM_iOS_Android_설정_가이드.md`
- `docs/구현 및 설정 가이드/Firebase_구글_소셜_로그인_설정_가이드.md`

### 유용한 명령어

```bash
# Flutter 환경 확인
flutter doctor -v

# 연결된 기기 확인
flutter devices

# iOS 빌드 정보 확인
flutter build ios --profile --verbose

# Xcode 프로젝트 열기
open ios/Runner.xcworkspace

# Pod 의존성 확인
cd ios && pod install && cd ..
```

---

## 변경 이력

- **2026-01-21**: 초기 문서 작성
  - 프로파일 빌드 방법 정리
  - Xcode 설정 확인 가이드 추가
  - 문제 해결 섹션 추가
  - 현재 프로젝트 설정 정보 정리

---

## 요약

### 빠른 시작

```bash
# 1. 환경 확인
flutter doctor

# 2. 의존성 설치
cd ios && pod install && cd ..

# 3. 프로파일 빌드
flutter build ios --profile

# 4. 실행
flutter run --profile
```

### 필수 확인 사항

1. ✅ Apple Developer 계정 로그인
2. ✅ Bundle Identifier 확인
3. ✅ Signing & Capabilities 설정
4. ✅ 프로비저닝 프로파일 생성
5. ✅ 실기기 등록 (실기기 테스트 시)
