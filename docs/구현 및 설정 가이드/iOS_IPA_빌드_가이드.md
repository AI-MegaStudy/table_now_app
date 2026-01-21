# iOS IPA 빌드 가이드

**작성일**: 2026-01-21  
**설명**: iOS 앱을 IPA 파일로 빌드하는 방법 (배포용)

---

## IPA 파일이 필요한 경우 vs 불필요한 경우

### ✅ IPA 파일이 **불필요한** 경우

**목적**: 실기기에서 직접 테스트

```bash
# 이 방법으로 충분합니다
flutter run --profile -d CHENG_iPhone
# 또는
flutter build ios --profile
```

**특징**:
- Xcode를 통해 직접 기기에 설치
- 빠른 테스트 및 디버깅
- IPA 파일 생성 불필요

### ⚠️ IPA 파일이 **필요한** 경우

**목적**: 배포 및 공유

1. **TestFlight 배포** (베타 테스트)
2. **App Store 배포** (정식 출시)
3. **Ad Hoc 배포** (제한된 기기에 배포)
4. **Enterprise 배포** (내부 배포)
5. **다른 사람에게 앱 공유** (설치 파일 전달)

---

## IPA 빌드 방법

### 방법 1: Xcode를 사용한 IPA 생성 (권장)

#### 1단계: Archive 생성

```bash
# Xcode 프로젝트 열기
open ios/Runner.xcworkspace
```

**Xcode에서**:
1. 상단 툴바에서 **Any iOS Device (arm64)** 선택
2. 메뉴: **Product** → **Archive**
3. Archive 완료 대기 (몇 분 소요)

#### 2단계: IPA 파일 생성

Archive 완료 후:
1. **Distribute App** 버튼 클릭
2. 배포 방법 선택:
   - **App Store Connect**: TestFlight/App Store 배포
   - **Ad Hoc**: 제한된 기기에 배포
   - **Enterprise**: Enterprise 배포
   - **Development**: 개발용 (일반적으로 사용 안 함)
3. **Next** → 프로비저닝 프로파일 선택
4. **Export** → 저장 위치 선택
5. IPA 파일 생성 완료

**IPA 파일 위치**:
```
~/Desktop/TableNowApp.ipa
```

### 방법 2: Flutter CLI로 Archive 생성 후 Xcode에서 IPA 생성

```bash
# 1. Release 모드로 빌드 (IPA 생성을 위해서는 Release 모드 권장)
flutter build ios --release

# 2. Xcode 열기
open ios/Runner.xcworkspace

# 3. Xcode에서 Archive → Distribute App
```

### 방법 3: 명령어로 직접 IPA 생성 (고급)

```bash
# Archive 생성
flutter build ipa --release

# 또는 프로파일 모드로
flutter build ipa --profile
```

**IPA 파일 위치**:
```
build/ios/ipa/table_now_app.ipa
```

**옵션**:
```bash
# 버전 및 빌드 번호 지정
flutter build ipa --release \
  --build-name=1.0.0 \
  --build-number=1

# 특정 타겟 지정
flutter build ipa --release --target=lib/main.dart
```

---

## 배포 유형별 설정

### 1. App Store Connect (TestFlight/App Store)

**용도**: 
- TestFlight 베타 테스트
- App Store 정식 출시

**필수 사항**:
- ✅ App Store Connect에 앱 등록 필요
- ✅ Distribution 인증서 필요
- ✅ App Store Distribution 프로비저닝 프로파일 필요

**절차**:
1. [App Store Connect](https://appstoreconnect.apple.com/) 접속
2. 앱 생성 (Bundle ID: `com.team01.tablenowapp`)
3. Xcode에서 Archive → **App Store Connect** 선택
4. 업로드 완료 후 TestFlight에서 테스트 또는 App Store에 제출

### 2. Ad Hoc 배포

**용도**: 
- 제한된 기기(최대 100대)에 배포
- 베타 테스터에게 직접 배포

**필수 사항**:
- ✅ Ad Hoc 프로비저닝 프로파일 필요
- ✅ 배포할 기기 UDID 등록 필요

**절차**:
1. Apple Developer Portal에서 Ad Hoc 프로파일 생성
2. 배포할 기기 UDID 등록
3. Xcode에서 Archive → **Ad Hoc** 선택
4. IPA 파일 생성 후 배포

### 3. Enterprise 배포

**용도**: 
- 회사 내부 배포
- Enterprise 계정 필요 (연간 $299)

**필수 사항**:
- ✅ Enterprise 계정 필요
- ✅ Enterprise Distribution 인증서 필요

---

## 현재 프로젝트 설정

### Bundle Identifier
```
com.team01.tablenowapp
```

### Development Team
```
M382EW7FD8
```

### 배포 전 확인 사항

1. **버전 번호 확인**
   ```dart
   // pubspec.yaml
   version: 1.0.0+1
   ```
   - 첫 번째 숫자: 버전 (1.0.0)
   - 두 번째 숫자: 빌드 번호 (1)

2. **프로비저닝 프로파일 확인**
   - Xcode → Signing & Capabilities
   - Distribution 프로파일이 선택되어 있는지 확인

3. **인증서 확인**
   - Apple Developer Portal에서 Distribution 인증서 확인

---

## 빠른 시작: TestFlight 배포

### 1. App Store Connect 설정

1. [App Store Connect](https://appstoreconnect.apple.com/) 접속
2. **내 앱** → **+** 버튼
3. 앱 정보 입력:
   - 이름: Table Now
   - 기본 언어: 한국어
   - Bundle ID: `com.team01.tablenowapp`
   - SKU: `table-now-app`

### 2. IPA 파일 생성 및 업로드

```bash
# 1. Release 모드로 빌드
flutter build ios --release

# 2. Xcode 열기
open ios/Runner.xcworkspace

# 3. Xcode에서:
#    - Product → Archive
#    - Distribute App → App Store Connect
#    - 업로드 완료
```

### 3. TestFlight에서 테스트

1. App Store Connect → TestFlight 탭
2. 빌드가 처리될 때까지 대기 (10-30분)
3. 내부 테스터 추가
4. 테스터에게 초대 메일 발송

---

## 문제 해결

### 1. Archive 실패

**증상**: `Archive failed`

**해결**:
```bash
# 클린 빌드
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release
```

### 2. Code Signing 오류

**증상**: `Code signing is required`

**해결**:
- Xcode → Signing & Capabilities
- Team 선택 확인
- Distribution 프로파일 확인

### 3. 프로비저닝 프로파일 오류

**증상**: `No profiles for 'com.team01.tablenowapp' were found`

**해결**:
1. Apple Developer Portal에서 Distribution 프로파일 생성
2. Xcode → Preferences → Accounts → Download Manual Profiles

### 4. IPA 파일 크기 문제

**증상**: IPA 파일이 너무 큼

**해결**:
```bash
# 불필요한 리소스 제거
flutter build ipa --release --split-debug-info=<DIR> --obfuscate
```

---

## 요약

### 실기기 테스트만 필요한 경우
```bash
# IPA 불필요
flutter run --profile -d CHENG_iPhone
```

### IPA 파일이 필요한 경우
```bash
# 방법 1: Xcode 사용 (권장)
open ios/Runner.xcworkspace
# Product → Archive → Distribute App

# 방법 2: Flutter CLI
flutter build ipa --release
```

### 배포 목적별 선택
- **TestFlight/App Store**: App Store Connect 배포
- **제한된 기기**: Ad Hoc 배포
- **회사 내부**: Enterprise 배포

---

## 참고 자료

- [Flutter iOS 배포 가이드](https://docs.flutter.dev/deployment/ios)
- [App Store Connect 도움말](https://help.apple.com/app-store-connect/)
- [TestFlight 가이드](https://developer.apple.com/testflight/)
