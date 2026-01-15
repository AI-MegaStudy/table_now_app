# Firebase 구글 소셜 로그인 설정 가이드

본 문서는 Firebase Console에서 구글 소셜 로그인을 설정하는 방법을 단계별로 안내합니다.

**작성일**: 2026-01-15  
**작성자**: 김택권

---

## 목차

1. [Firebase 프로젝트 생성/선택](#1-firebase-프로젝트-생성선택)
2. [Authentication 활성화](#2-authentication-활성화)
3. [Google Sign-In 제공업체 활성화](#3-google-sign-in-제공업체-활성화)
4. [Android 앱 설정](#4-android-앱-설정)
5. [iOS 앱 설정](#5-ios-앱-설정)
6. [OAuth 동의 화면 설정](#6-oauth-동의-화면-설정)
7. [설정 파일 다운로드 및 적용](#7-설정-파일-다운로드-및-적용)
8. [SHA-1 인증서 지문 등록 (Android)](#8-sha-1-인증서-지문-등록-android)
9. [iOS 빌드 오류 해결 (Module 'firebase_core' not found)](#9-ios-빌드-오류-해결-module-firebase_core-not-found)

---

## 1. Firebase 프로젝트 생성/선택

### 1.1 Firebase Console 접속

1. [Firebase Console](https://console.firebase.google.com/) 접속
2. Google 계정으로 로그인

### 1.2 프로젝트 선택

- **현재 프로젝트**: `tablenow-dcfc4` 프로젝트 선택
- 프로젝트 목록에서 **"tablenow-dcfc4"** 선택

---

## 2. Authentication 활성화

### 2.1 Authentication 메뉴 진입

1. Firebase Console 좌측 메뉴에서 **"Authentication"** 클릭
2. "시작하기" 버튼 클릭 (처음 사용하는 경우)

### 2.2 "로그인 방법" 탭으로 이동

현재 화면에서 상단에 여러 탭이 보입니다:

- **"사용자"** (현재 선택된 탭)
- **"로그인 방법"** ← **이 탭을 클릭하세요!**
- "템플릿"
- "사용량"
- "설정"
- "Extensions"

**중요**: 상단 탭에서 **"로그인 방법"** (또는 "Sign-in method") 탭을 클릭합니다.

---

## 3. Google Sign-In 제공업체 활성화

### 3.1 "로그인 방법" 탭에서 Google 찾기

"로그인 방법" 탭을 클릭하면 여러 제공업체 목록이 표시됩니다:

- 이메일/비밀번호
- 전화번호
- **Google** ← 이것을 찾아서 클릭하세요!
- Facebook
- Twitter
- GitHub
- 등등...

### 3.2 Google 제공업체 활성화

1. 제공업체 목록에서 **"Google"** 항목을 클릭합니다
2. 열리는 설정 창에서 **"사용 설정"** 토글을 **ON**으로 변경합니다

### 3.2 프로젝트 지원 이메일 설정

- **프로젝트 지원 이메일**: 프로젝트 관리자 이메일 선택 또는 입력
- 예: `your-email@gmail.com`

### 3.3 저장

- **"저장"** 버튼 클릭

### 3.4 OAuth 동의 화면 설정 안내

- Google Cloud Console에서 OAuth 동의 화면을 설정해야 한다는 안내가 표시될 수 있음
- 이는 다음 단계에서 처리합니다.

---

## 4. Android 앱 설정

### 4.1 Android 앱 등록

1. Firebase Console 좌측 메뉴에서 **"프로젝트 설정"** (톱니바퀴 아이콘) 클릭
2. 하단의 **"내 앱"** 섹션에서 **"Android 앱 추가"** 클릭

### 4.2 앱 정보 확인

- **Android 패키지 이름**:
  ```
  com.team01.tablenowapp
  ```
  ✅ 이미 등록되어 있음 (`android/app/build.gradle.kts`의 `applicationId` 확인)
- **앱 닉네임**: Table Now

### 4.3 현재 상태 확인

- ✅ `google-services.json` 파일이 이미 `android/app/` 디렉토리에 존재함
- ✅ `android/app/build.gradle.kts`에 Google Services 플러그인이 이미 적용됨:
  ```kotlin
  id("com.google.gms.google-services")
  ```

### 4.4 google-services.json 재다운로드 (필요한 경우)

만약 파일이 없거나 업데이트가 필요한 경우:

1. Firebase Console → **"프로젝트 설정"** → **"내 앱"** → Android 앱 선택
2. **"google-services.json 다운로드"** 버튼 클릭
3. 다운로드한 파일을 다음 위치에 저장:
   ```
   android/app/google-services.json
   ```

---

## 5. iOS 앱 설정

### 5.1 iOS 앱 등록

1. Firebase Console의 **"프로젝트 설정"** → **"내 앱"** 섹션
2. **"iOS 앱 추가"** 클릭

### 5.2 앱 정보 확인

- **iOS 번들 ID**:
  ```
  com.team01.tablenowapp
  ```
  ✅ 이미 등록되어 있음 (`firebase_options.dart`의 `iosBundleId` 확인)
- **앱 닉네임**: Table Now

### 5.3 현재 상태 확인

- ✅ `GoogleService-Info.plist` 파일이 이미 `ios/Runner/` 디렉토리에 존재함

### 5.4 GoogleService-Info.plist 재다운로드 (필요한 경우)

만약 파일이 없거나 업데이트가 필요한 경우:

1. Firebase Console → **"프로젝트 설정"** → **"내 앱"** → iOS 앱 선택
2. **"GoogleService-Info.plist 다운로드"** 버튼 클릭
3. 다운로드한 파일을 다음 위치에 저장:
   ```
   ios/Runner/GoogleService-Info.plist
   ```

---

## 6. OAuth 동의 화면 설정

### 6.1 Google Cloud Console 접속 (권장 방법)

**가장 확실한 방법: Firebase Console에서 직접 링크로 이동**

1. Firebase Console에서 **"Authentication"** 메뉴 클릭
2. 상단 탭에서 **"로그인 방법"** (Sign-in method) 클릭
3. 제공업체 목록에서 **"Google"** 클릭
4. Google 설정 창이 열리면, 아래 중 하나를 찾아 클릭합니다:

   - **"OAuth 동의 화면 구성"** 링크
   - **"Google Cloud Console에서 구성"** 링크
   - 경고 메시지 내의 링크

   이 링크를 클릭하면 자동으로 올바른 프로젝트(`tablenow-dcfc4`)로 이동합니다.

**대안: Google Cloud Console 직접 접속 (프로젝트가 목록에 보이지 않는 경우)**

Firebase Console에서 링크가 보이지 않거나, Google Cloud Console에서 프로젝트가 목록에 직접 보이지 않는 경우:

1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. 상단 프로젝트 선택 드롭다운 클릭
3. **검색창에 "tablenow" 입력하여 검색**

   - 프로젝트가 목록에 직접 보이지 않더라도 검색하면 나타납니다
   - 검색 결과에서 **"tablenow-dcfc4"** 또는 **"TableNow"** 프로젝트를 선택합니다

4. **OAuth 동의 화면으로 이동하는 방법 (두 가지 경로):**

   **방법 A: APIs & Services 메뉴 사용**

   - 좌측 메뉴에서 **"APIs & Services"** 클릭
   - 하위 메뉴에서 **"OAuth 동의 화면"** 클릭

   **방법 B: 직접 URL 접근 (더 빠름)**

   - 브라우저 주소창에 다음 URL 입력:
     ```
     https://console.cloud.google.com/apis/credentials/consent?project=tablenow-dcfc4
     ```
   - 또는 검색창에 "OAuth consent screen" 검색 후 선택

**참고**: Firebase 프로젝트가 Google Cloud Console의 기본 목록에 표시되지 않을 수 있지만, 검색 기능을 사용하면 찾을 수 있습니다.

**참고**: Firebase 프로젝트는 Google Cloud 프로젝트와 연결되어 있습니다. 같은 Google 계정으로 로그인했다면 프로젝트가 표시되어야 합니다.

### 6.2 프로젝트 선택 확인

- Firebase Console에서 링크로 이동한 경우: 프로젝트가 자동으로 선택되어 있습니다
- 직접 접속한 경우:
  1. 상단 프로젝트 선택 드롭다운 클릭
  2. **검색창에 "tablenow" 입력하여 검색** (목록에 직접 보이지 않아도 검색하면 나타납니다)
  3. 검색 결과에서 **"tablenow-dcfc4"** 프로젝트 선택
  4. 프로젝트가 선택되면 좌측 상단에 프로젝트 이름이 표시됩니다

### 6.3 OAuth 동의 화면 구성

**OAuth 동의 화면으로 이동:**

현재 "OAuth 개요" 페이지에 있다면, 다음 중 하나의 방법으로 이동:

1. **좌측 메뉴에서 찾기:**

   - 좌측 메뉴를 스크롤하여 **"APIs & Services"** 찾기
   - 또는 상단 검색창에 **"OAuth consent screen"** 또는 **"OAuth 동의 화면"** 검색

2. **직접 URL 접근 (가장 빠름):**
   - 브라우저 주소창에 다음 URL 입력:
     ```
     https://console.cloud.google.com/apis/credentials/consent?project=tablenow-dcfc4
     ```

**OAuth 동의 화면 구성:**

**이미 구성되어 있는 경우:**

- OAuth 동의 화면이 이미 구성되어 있다면, 설정을 확인하고 필요시 수정합니다

**처음 구성하는 경우:**

1. OAuth 동의 화면 페이지에서 **"외부"** 선택 (일반 사용자용)
2. **"만들기"** 또는 **"구성"** 버튼 클릭

### 6.4 앱 정보 입력

- **앱 이름**: Table Now (또는 원하는 이름)
- **사용자 지원 이메일**: 프로젝트 관리자 이메일
- **앱 로고** (선택사항): 앱 아이콘 업로드
- **앱 도메인** (선택사항): 나중에 추가 가능
- **개발자 연락처 정보**: 이메일 주소

### 6.5 범위(Scopes) 설정

- **"범위 추가 또는 삭제"** 클릭
- 기본 범위는 자동으로 포함됨:
  - `openid`
  - `email`
  - `profile`
- **"저장 후 계속"** 클릭

### 6.6 테스트 사용자 추가 (선택사항)

- 개발 중에는 테스트 사용자 이메일 추가 가능
- **"사용자 추가"** → 테스트할 이메일 입력

### 6.7 요약 확인

- 설정 내용 확인 후 **"대시보드로 돌아가기"** 클릭

---

## 7. 설정 파일 다운로드 및 적용

### 7.1 Android: google-services.json

✅ **이미 설정 완료됨**

현재 프로젝트 상태:

- ✅ `google-services.json` 파일이 `android/app/` 디렉토리에 존재
- ✅ `android/app/build.gradle.kts`에 Google Services 플러그인 적용됨:
  ```kotlin
  plugins {
      id("com.google.gms.google-services")
      // ...
  }
  ```

**참고**: 이 프로젝트는 Kotlin DSL (`build.gradle.kts`)을 사용하므로 Groovy 형식(`build.gradle`)이 아닌 Kotlin 형식으로 작성되어 있습니다.

### 7.2 iOS: GoogleService-Info.plist

1. 다운로드한 `GoogleService-Info.plist` 파일을 다음 위치에 저장:

   ```
   ios/Runner/GoogleService-Info.plist
   ```

2. Xcode에서 프로젝트 열기:

   ```bash
   open ios/Runner.xcworkspace
   ```

3. Xcode에서 `GoogleService-Info.plist`를 프로젝트에 추가:
   - 파일을 드래그 앤 드롭
   - "Copy items if needed" 체크
   - Runner 타겟에 추가 확인

---

## 8. SHA-1 인증서 지문 등록

### 8.1 Android: SHA-1 인증서 지문 등록 (필수)

**중요**: Android 앱에서 Google 로그인을 사용하려면 **반드시** SHA-1 인증서 지문을 등록해야 합니다.

#### 8.1.1 디버그 키스토어 SHA-1 확인

터미널에서 다음 명령어 실행:

**macOS/Linux:**

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Windows:**

```bash
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### 8.1.2 SHA-1 값 복사

출력 결과에서 **"SHA1:"** 뒤의 값을 복사합니다.
예: `A1:B2:C3:D4:E5:F6:...`

#### 8.1.3 Firebase Console에 등록

1. Firebase Console → **"프로젝트 설정"** (톱니바퀴 아이콘) 클릭
2. **"내 앱"** 섹션에서 **Android 앱** 선택
3. **"SHA 인증서 지문 추가"** 클릭
4. SHA-1 값 붙여넣기 → **"저장"**

#### 8.1.4 릴리즈 키스토어 SHA-1 (배포 시)

배포용 앱을 만들 때는 릴리즈 키스토어의 SHA-1도 등록해야 합니다:

```bash
keytool -list -v -keystore [릴리즈-키스토어-경로] -alias [앨리어스-이름]
```

### 8.2 iOS: SHA-1 인증서 지문 불필요

**중요**: iOS 앱에서는 **SHA-1 인증서 지문이 필요하지 않습니다.**

iOS에서 Google 로그인을 사용하기 위해서는 다음만 있으면 됩니다:

- ✅ **번들 ID 등록**: 이미 완료됨 (`com.team01.tablenowapp`)
- ✅ **GoogleService-Info.plist 파일**: 이미 배치됨 (`ios/Runner/GoogleService-Info.plist`)
- ✅ **OAuth 동의 화면 구성**: Google Cloud Console에서 설정 필요

iOS는 Android와 달리 앱 서명 방식이 다르기 때문에 SHA-1 인증서 지문 등록이 필요하지 않습니다.

---

## 9. iOS 빌드 오류 해결 (Module 'firebase_core' not found)

### 9.1 문제 현상

iOS 빌드 시 다음과 같은 오류가 발생할 수 있습니다:

```
Failed to build iOS app
Parse Issue (Xcode): Module 'firebase_core' not found
```

이 오류는 Xcode가 Firebase Core 모듈을 찾지 못할 때 발생합니다.

### 9.2 원인

1. Flutter의 Podfile이 Firebase 모듈을 제대로 인식하지 못함
2. `flutter_ios_podfile_setup`과 `flutter_install_all_ios_pods`가 실행되지 않음
3. `use_modular_headers!` 누락으로 모듈 헤더를 찾지 못함
4. CI/CD 환경에서 처음 빌드할 때 자주 발생

### 9.3 해결 방법: Podfile 수정

**참고 링크**: [GitHub - Failed-to-build-iOS-app-Parse-Issue-Xcode-Module-firebase_core-not-found](https://github.com/sirkev/Failed-to-build-iOS-app-Parse-Issue-Xcode-Module-firebase_core-not-found)

#### 9.3.1 Podfile 위치 확인

`ios/Podfile` 파일을 열어서 다음 구조로 수정합니다.

#### 9.3.2 올바른 Podfile 구조

```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '15.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

# Firebase Core 모듈을 찾기 위한 Podfile 설정
def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end
  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

#### 9.3.3 핵심 수정 사항

1. **`flutter_root` 함수 추가**
   - Flutter SDK 경로를 동적으로 찾아서 반환
   - `Generated.xcconfig` 파일에서 `FLUTTER_ROOT` 읽기

2. **`require` 문 추가**
   - Flutter의 `podhelper` 스크립트를 로드
   - Firebase를 포함한 모든 Flutter 플러그인을 올바르게 설치

3. **`flutter_ios_podfile_setup` 호출**
   - Flutter iOS 빌드 설정 초기화

4. **`use_modular_headers!` 추가**
   - Firebase Core를 모듈로 인식하도록 설정
   - **이 설정이 없으면 Firebase 모듈을 찾지 못합니다**

5. **`post_install` 블록 추가**
   - Flutter 빌드 설정을 모든 Pod 타겟에 적용

#### 9.3.4 수정 후 실행 단계

Podfile 수정 후 다음 명령어를 순서대로 실행하세요:

```bash
# 1. Flutter 클린
flutter clean

# 2. 의존성 다시 가져오기
flutter pub get

# 3. iOS 폴더로 이동
cd ios

# 4. Pod 설치
pod install

# 5. 프로젝트 루트로 돌아가기
cd ..
```

이후 iOS 빌드를 다시 시도하세요:

```bash
flutter build ios
# 또는
flutter run
```

#### 9.3.5 CI/CD 환경에서의 주의사항

이 설정은 CI/CD 환경(예: GitHub Actions, self-hosted macOS runner)에서도 동작합니다.

**테스트 환경**: macOS Monterey 12.6, Flutter 3.19.4, Firebase 10.x

---

## 10. 설정 확인 체크리스트

### Android

- [x] `google-services.json` 파일이 `android/app/` 디렉토리에 있음 ✅
- [x] `android/app/build.gradle.kts`에 `id("com.google.gms.google-services")` 추가됨 ✅
- [ ] SHA-1 인증서 지문이 Firebase Console에 등록됨 ⚠️ **필수 확인 필요** (Google 로그인 사용을 위해 반드시 필요)

### iOS

- [x] `GoogleService-Info.plist` 파일이 `ios/Runner/` 디렉토리에 있음 ✅
- [x] 번들 ID가 Firebase Console에 등록된 것과 일치함 (`com.team01.tablenowapp`) ✅
- [x] SHA-1 인증서 지문 등록 불필요 ✅ (iOS는 SHA-1이 필요하지 않음)

### Firebase Console (현재 진행 필요)

- [ ] Authentication이 활성화됨 ⚠️ **진행 필요**
- [ ] Google Sign-In 제공업체가 활성화됨 ⚠️ **진행 필요**
- [ ] OAuth 동의 화면이 구성됨 ⚠️ **진행 필요**
- [x] Android 앱이 등록됨 (`com.team01.tablenowapp`) ✅
- [x] iOS 앱이 등록됨 (`com.team01.tablenowapp`) ✅

---

## 11. 현재 프로젝트 상태 요약

### ✅ 완료된 작업

- Firebase 프로젝트 생성 및 연결 (`tablenow-dcfc4`)
- Android 앱 등록 (`com.team01.tablenowapp`)
- iOS 앱 등록 (`com.team01.tablenowapp`)
- `google-services.json` 파일 배치 완료
- `GoogleService-Info.plist` 파일 배치 완료
- `build.gradle.kts`에 Google Services 플러그인 적용 완료
- `firebase_options.dart` 파일 생성 완료

### ⚠️ 진행 필요 작업

1. **Firebase Console에서 Authentication 활성화**
   - Authentication → Sign-in method → Google 활성화
2. **OAuth 동의 화면 구성**
   - Google Cloud Console에서 OAuth 동의 화면 설정
3. **SHA-1 인증서 지문 등록 (Android)**
   - 디버그 키스토어 SHA-1 값 확인 및 등록

## 12. 다음 단계

Firebase Console 설정이 완료되면 Flutter 앱에서 구글 로그인 구현을 진행합니다:

1. **Flutter 코드 구현**

   - `google_sign_in` 패키지 사용 (이미 설치됨)
   - `firebase_auth` 패키지 사용 (이미 설치됨)
   - 로그인 플로우 구현 (`lib/view/auth/login_tab.dart`)

2. **백엔드 API 연동**
   - `/api/customer/social-login` 엔드포인트 호출 (이미 구현됨)
   - `/api/customer/link-social` 엔드포인트 호출 (이미 구현됨)
   - 계정 통합 로직 구현

---

## 참고 자료

- [Firebase Authentication 문서](https://firebase.google.com/docs/auth)
- [Google Sign-In Flutter 패키지](https://pub.dev/packages/google_sign_in)
- [Firebase Auth Flutter 패키지](https://pub.dev/packages/firebase_auth)
- [Firebase Console](https://console.firebase.google.com/)
- [Google Cloud Console](https://console.cloud.google.com/)
- [iOS 빌드 오류 해결 가이드 (Module 'firebase_core' not found)](https://github.com/sirkev/Failed-to-build-iOS-app-Parse-Issue-Xcode-Module-firebase_core-not-found)

---

## 변경 이력

- **2026-01-15**: 초기 문서 작성 (작성자: 김택권)
  - Firebase Console 설정 가이드 작성
  - Android/iOS 앱 등록 방법 안내
  - OAuth 동의 화면 설정 방법 안내
  - SHA-1 인증서 지문 등록 방법 안내
  - 현재 프로젝트 상태 반영 (`tablenow-dcfc4`, `com.team01.tablenowapp`)
- **2026-01-15**: iOS 빌드 오류 해결 섹션 추가 (작성자: 김택권)
  - "Module 'firebase_core' not found" 오류 해결 방법 추가
  - Podfile 수정 가이드 추가
  - GitHub 참고 링크 추가
  - CI/CD 환경 주의사항 추가