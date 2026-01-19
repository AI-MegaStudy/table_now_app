# FCM 및 로컬 노티피케이션 남은 작업 정리

**작성일**: 2026-01-19  
**작성자**: 프로젝트 관리자  
**설명**: FCM과 로컬 노티피케이션 관련하여 앞으로 구현해야 할 작업들을 정리한 문서

---

## ✅ 완료된 작업

### 기본 인프라
- [x] FCM 토큰 관리 및 로컬 저장 (`FCMStorage`)
- [x] FCM 토큰 서버 전송 API 연동
- [x] 알림 권한 요청 및 관리 (iOS/Android)
  - [x] 알림 권한 상태 확인 및 재시도 로직 구현
  - [x] 권한 거부 시 에러 메시지 표시
  - [x] FCM 초기화 재시도 메서드 구현 (`retryInitialization()`)
- [x] 토큰 갱신 리스너 설정
- [x] 포그라운드 메시지 핸들러 설정
- [x] iOS Profile/Release 빌드 설정 문제 해결
  - [x] Profile 빌드 설정에 `CODE_SIGN_ENTITLEMENTS` 추가
  - [x] 프로필/릴리스 모드에서도 에러 로그 출력 가능하도록 수정
  - [x] APNs 토큰 대기 시간 증가 (10초 → 30초)
  - [x] 앱 생명주기 관찰자 추가 (포그라운드 복귀 시 APNs 토큰 재확인)
- [x] Dev_07 화면에 FCM 상태 표시 추가
  - [x] 초기화 상태 표시
  - [x] 에러 메시지 표시
  - [x] FCM 초기화 재시도 버튼 추가

### 포그라운드 알림 표시 (로컬 노티피케이션)
- [x] `flutter_local_notifications` 패키지 추가 (`pubspec.yaml`)
- [x] `LocalNotificationService` 클래스 생성 및 구현
  - [x] 초기화 메서드 (`initialize()`)
  - [x] Android Notification Channel 생성
  - [x] iOS 알림 권한 요청
  - [x] 알림 표시 메서드 (`showNotification()`)
  - [x] FCM `RemoteMessage`를 로컬 알림으로 변환
  - [x] 알림 ID 관리 (중복 방지)
  - [x] 알림 클릭 핸들러 설정 (`setOnNotificationTap()`)
- [x] `FCMNotifier`에 `LocalNotificationService` 통합
  - [x] `FCMNotifier.initialize()`에서 `LocalNotificationService` 초기화
  - [x] 포그라운드 핸들러에서 `LocalNotificationService.showNotification()` 호출
  - [x] FCM 메시지 `data` 필드를 JSON으로 변환하여 payload에 저장

### 알림 클릭 핸들러 구현
- [x] 포그라운드 알림 클릭 핸들러 구현 (`main.dart`)
  - [x] `LocalNotificationService.setOnNotificationTap()` 설정
  - [x] 알림 payload 파싱 및 로그 출력
  - [x] 현재 화면 정보 추적 및 출력
- [x] 백그라운드/종료 상태 알림 클릭 핸들러 구현 (`FCMNotifier`)
  - [x] `FirebaseMessaging.onMessageOpenedApp` 핸들러 구현
  - [x] `FirebaseMessaging.instance.getInitialMessage()` 처리
  - [x] 알림 데이터 파싱 및 로그 출력
  - [x] 현재 화면 정보 추적 및 출력
- [x] 현재 화면 추적 기능 구현
  - [x] `RouteObserver` 구현 (`ScreenTrackingRouteObserver`)
  - [x] `CurrentScreenTracker` 유틸리티 클래스 구현
  - [x] 전역 NavigatorKey 설정 (`main.dart`)

### 백엔드 FCM 서비스
- [x] `app/utils/fcm_service.py` 공통 서비스 모듈 생성
- [x] Firebase Admin SDK 전역 초기화 로직 (`_ensure_initialized()`)
- [x] 푸시 발송 함수 제공
  - [x] `send_notification()`: 단일 기기 알림 발송
  - [x] `send_notification_to_customer()`: 고객의 모든 기기 알림 발송
  - [x] `send_multicast_notification()`: 여러 기기 동시 알림 발송

---

## ❌ 남은 작업

### 1. 알림 클릭 시 화면 이동 처리 (라우팅 로직)

#### 1.1 포그라운드 알림 클릭 처리
**현재 상태**: 
- ✅ 알림 클릭 핸들러 구현 완료 (`main.dart`의 `LocalNotificationService.setOnNotificationTap()`)
- ✅ 알림 payload 파싱 및 현재 화면 추적 구현 완료
- ❌ 실제 라우팅 로직은 미구현 (로그 출력만 하고 화면 이동 코드 없음)

**구현 필요**:
- [x] `main.dart`에서 알림 클릭 핸들러 설정 ✅
- [x] 알림 payload에서 화면 정보 파싱 (`screen`, `reserve_seq` 등) ✅
- [ ] 화면 라우팅 로직 구현 (TODO 주석만 있음)
  - 예약 상세 화면 (`/reservation/{reserve_seq}`)
  - 홈 화면 (`/home`)
  - 메뉴 화면 등

**구현 위치**: `lib/main.dart` (이미 핸들러는 구현됨, 라우팅 로직만 추가 필요)

**예시 코드**:
```dart
// main.dart의 _MyAppState에서
@override
void initState() {
  super.initState();
  _setupNotificationTapHandler();
}

void _setupNotificationTapHandler() {
  LocalNotificationService.setOnNotificationTap((response) {
    if (response.payload == null || response.payload!.isEmpty) return;
    
    try {
      final data = jsonDecode(response.payload!);
      final screen = data['screen'] as String?;
      final reserveSeq = data['reserve_seq'] as String?;
      
      // Navigator를 사용하려면 BuildContext가 필요함
      // GlobalKey<NavigatorState> 또는 다른 방법 필요
      switch (screen) {
        case 'reservation_detail':
          if (reserveSeq != null) {
            // 화면 이동 로직
          }
          break;
        // ...
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️  알림 클릭 처리 오류: $e');
      }
    }
  });
}
```

#### 1.2 백그라운드/종료 상태 알림 클릭 처리
**현재 상태**: 
- ✅ 백그라운드/종료 상태 알림 클릭 핸들러 구현 완료 (`FCMNotifier._setupBackgroundMessageHandlers()`)
- ✅ 알림 데이터 파싱 및 현재 화면 추적 구현 완료
- ❌ 실제 라우팅 로직은 미구현 (로그 출력만 하고 화면 이동 코드 없음)

**구현 필요**:
- [x] `FirebaseMessaging.onMessageOpenedApp` 핸들러 구현 ✅
  - 백그라운드 상태에서 알림 클릭 시 처리
- [x] `FirebaseMessaging.instance.getInitialMessage()` 처리 ✅
  - 앱이 종료 상태에서 알림 클릭으로 앱 실행 시 처리
- [ ] 화면 라우팅 로직 구현 (TODO 주석만 있음)

**구현 위치**: `lib/vm/fcm_notifier.dart` (이미 핸들러는 구현됨, 라우팅 로직만 추가 필요)

**예시 코드**:
```dart
// FCMNotifier에 추가
void _setupBackgroundMessageHandlers() {
  // 백그라운드 상태에서 알림 클릭
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _handleNotificationTap(message);
  });
  
  // 앱 종료 상태에서 알림 클릭으로 앱 실행
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      _handleNotificationTap(message);
    }
  });
}

void _handleNotificationTap(RemoteMessage message) {
  final data = message.data;
  final screen = data['screen'] as String?;
  final reserveSeq = data['reserve_seq'] as String?;
  
  // 화면 이동 로직 (Navigator 사용)
  // GlobalKey<NavigatorState> 필요
}
```

---

### 2. 화면 라우팅 구조 정의

#### 2.1 알림 데이터 구조 정의
**현재 상태**: 가이드 문서에만 예시가 있음

**구현 필요**:
- [ ] FCM 메시지 `data` 필드 구조 문서화
- [ ] 화면 라우팅 정보 포함 방식 결정
- [ ] 각 알림 타입별 데이터 구조 정의

**예시 구조**:
```json
{
  "notification": {
    "title": "예약 완료",
    "body": "예약이 완료되었습니다."
  },
  "data": {
    "type": "reservation_complete",
    "reserve_seq": "123",
    "screen": "reservation_detail"
  }
}
```

**알림 타입별 구조**:
- 예약 완료: `type: "reservation_complete", screen: "reservation_detail"`
- 예약 취소: `type: "reservation_cancelled", screen: "reservation_list"`
- 결제 완료: `type: "payment_complete", screen: "payment_detail"`
- 예약 변경: `type: "reservation_modified", screen: "reservation_detail"`

#### 2.2 라우팅 매핑 구현
**구현 필요**:
- [ ] 알림 타입 → 화면 경로 매핑
- [ ] 파라미터 전달 방식 정의
- [ ] 딥링크 처리 (선택사항)

---

### 3. 백엔드 푸시 알림 전송 구현

#### 3.0 FCM Admin SDK 전역 초기화 (백엔드 전용) ✅
**현재 상태**: 구현 완료

**중요**: 
- ⚠️ **클라이언트(TableNow 앱)에서는 필요 없음**
  - 클라이언트는 Firebase SDK만 사용 (이미 구현됨)
  - FCM 메시지를 받는 쪽이므로 Admin SDK 불필요
- ✅ **백엔드(서버)에서만 필요함**
  - 푸시 알림을 보낼 때 필요
  - 전역 초기화 완료: `FCMService`에서 자동 처리

**구현 완료** ✅:
- [x] `app/utils/fcm_service.py` 공통 서비스 모듈 생성
- [x] 전역 초기화 로직 포함 (`_ensure_initialized()`)
  - 자동으로 Firebase Admin SDK 초기화
  - 중복 초기화 방지 (`_initialized` 플래그 사용)
- [x] 푸시 발송 함수 제공
  - `send_notification()`: 단일 기기 알림 발송
  - `send_notification_to_customer()`: 고객의 모든 기기 알림 발송
  - `send_multicast_notification()`: 여러 기기 동시 알림 발송 (최대 500개)
- [x] `push_debug.py` 리팩토링 완료
  - 중복 초기화 코드 제거
  - `FCMService` 사용으로 변경

**사용 방법** (다른 팀원들이 자신의 API 파일에서 사용):
```python
# 예: reserve.py에서 사용
from app.utils.fcm_service import FCMService

# 예약 완료 시 푸시 알림 발송
async def create_reservation(...):
    # ... 예약 생성 로직 ...
    
    # 푸시 알림 발송 (다른 팀원 파일 수정 불필요!)
    FCMService.send_notification_to_customer(
        customer_seq=customer_seq,
        title="예약 완료",
        body="예약이 완료되었습니다.",
        data={
            "type": "reservation_complete",
            "reserve_seq": str(reserve_seq),
            "screen": "reservation_detail"
        }
    )
```

**참고**: 
- 다른 팀원들이 자신의 파일(`reserve.py`, `payment.py` 등)을 수정하지 않고도 `import`만 하면 사용 가능합니다.
- 클라이언트는 이미 Firebase SDK를 사용하고 있으므로 추가 작업 불필요합니다.
- **상세 사용법**: [FCM 백엔드 푸시 알림 발송 가이드](./FCM_백엔드_푸시_알림_발송_가이드.md) 참고

#### 3.1 예약 완료 시 푸시 알림 전송
**현재 상태**: 미구현 (다른 팀원 작업 완료 후 가능)

**구현 필요**:
- [ ] 예약 완료 API (`POST /api/reserve`)에서 푸시 알림 전송 로직 추가
- [ ] 고객의 FCM 토큰 조회 (`device_token` 테이블)
- [ ] FCM Admin SDK를 사용한 푸시 알림 전송
- [ ] 알림 메시지 구성 (title, body, data)

**구현 위치**: `fastapi/app/api/reserve.py`

**예시 코드** (다른 팀원이 자신의 파일에 추가):
```python
from app.utils.fcm_service import FCMService

# 예약 완료 API 엔드포인트 내부에서
async def create_reservation(...):
    # ... 예약 생성 로직 ...
    
    # 푸시 알림 발송 (간단하게 한 줄로!)
    FCMService.send_notification_to_customer(
        customer_seq=customer_seq,
        title="예약 완료",
        body="예약이 완료되었습니다.",
        data={
            "type": "reservation_complete",
            "reserve_seq": str(reserve_seq),
            "screen": "reservation_detail"
        }
    )
    
    return {"result": "OK", ...}
```

**장점**:
- 다른 팀원 파일 수정 불필요 (import만 추가)
- 전역 초기화 자동 처리
- DB 토큰 조회 자동 처리
- 에러 처리 내장

#### 3.2 예약 취소/변경 시 푸시 알림 전송
**현재 상태**: 미구현 (다른 팀원 작업 완료 후 가능)

**구현 필요**:
- [ ] 예약 취소 API에서 푸시 알림 전송
- [ ] 예약 변경 API에서 푸시 알림 전송
- [ ] 각각의 알림 메시지 구성

#### 3.3 결제 완료 시 푸시 알림 전송
**현재 상태**: 미구현 (다른 팀원 작업 완료 후 가능)

**구현 필요**:
- [ ] 결제 완료 API에서 푸시 알림 전송
- [ ] 결제 정보 포함 알림 메시지 구성

---

### 4. 테스트 및 검증

#### 4.1 포그라운드 알림 테스트
**테스트 항목**:
- [x] 포그라운드 상태에서 알림 수신 확인 ✅
- [x] 알림 표시 확인 (제목, 내용) ✅
- [x] 알림 클릭 시 핸들러 동작 확인 ✅ (로그 출력 확인)
- [ ] 알림 클릭 시 화면 이동 확인 (라우팅 로직 미구현)
- [ ] iOS/Android 각각 테스트

#### 4.2 백그라운드 알림 테스트
**테스트 항목**:
- [x] 백그라운드 상태에서 알림 수신 확인 ✅
- [x] 알림 클릭 시 핸들러 동작 확인 ✅ (로그 출력 확인)
- [ ] 알림 클릭 시 앱 실행 및 화면 이동 확인 (라우팅 로직 미구현)
- [ ] iOS/Android 각각 테스트

#### 4.3 종료 상태 알림 테스트
**테스트 항목**:
- [x] 앱 종료 상태에서 알림 수신 확인 ✅
- [x] 알림 클릭 시 핸들러 동작 확인 ✅ (로그 출력 확인)
- [x] `getInitialMessage()` 동작 확인 ✅
- [ ] 알림 클릭 시 앱 실행 및 화면 이동 확인 (라우팅 로직 미구현)
- [ ] iOS/Android 각각 테스트

#### 4.4 데이터 페이로드 테스트
**테스트 항목**:
- [x] `data` 필드가 올바르게 전달되는지 확인 ✅
- [x] 알림 클릭 시 `data` 파싱 확인 ✅
- [x] 현재 화면 추적 확인 ✅ (RouteObserver 사용)
- [ ] 화면 이동 시 파라미터 전달 확인 (라우팅 로직 미구현)

#### 4.5 iOS Profile/Release 빌드 테스트
**테스트 항목**:
- [x] Profile 모드 빌드 및 IPA 설치 테스트 ✅
- [x] Profile 모드에서 FCM 토큰 발급 확인 ✅
- [x] Profile 모드에서 푸시 알림 수신 확인 ✅
- [x] 프로비저닝 프로파일 설정 확인 ✅
- [x] CODE_SIGN_ENTITLEMENTS 설정 확인 ✅

---

### 5. 문서화 업데이트

#### 5.1 구현 가이드 문서 업데이트
**업데이트 필요**:
- [ ] `FCM_포그라운드_알림_표시_구현_계획.md` 체크리스트 업데이트
- [ ] 알림 클릭 처리 가이드 추가
- [ ] 화면 라우팅 가이드 추가

#### 5.2 사용 예시 추가
**추가 필요**:
- [ ] 알림 클릭 처리 예시 코드
- [ ] 백엔드 푸시 알림 전송 예시 코드
- [ ] 각 알림 타입별 사용 예시

#### 5.3 트러블슈팅 가이드 추가
**추가 필요**:
- [x] iOS Profile/Release 빌드에서 FCM 토큰이 안 나오는 경우 ✅
  - [x] CODE_SIGN_ENTITLEMENTS 설정 확인
  - [x] 프로비저닝 프로파일 확인
  - [x] Push Notifications capability 확인
- [ ] 알림이 표시되지 않는 경우
- [ ] 알림 클릭 시 화면 이동이 안 되는 경우
- [ ] 백그라운드/종료 상태 알림 처리 문제
- [ ] iOS/Android 플랫폼별 이슈

---

## 📋 우선순위별 작업 계획

### Phase 1: 알림 클릭 처리 (높은 우선순위)
1. ✅ 포그라운드 알림 클릭 핸들러 구현 (완료)
2. ✅ 백그라운드/종료 상태 알림 클릭 핸들러 구현 (완료)
3. ✅ 현재 화면 추적 기능 구현 (완료)
4. [ ] 화면 라우팅 로직 구현 (진행 중)
5. [ ] 테스트 및 검증

**예상 소요 시간**: 1-2일 (핸들러 구현 완료, 라우팅 로직만 남음)

### Phase 2: 백엔드 푸시 알림 전송 (중간 우선순위)
**참고**: 다른 팀원의 예약/결제 API 작업 완료 후 진행 가능

1. FCM Admin SDK 전역 초기화 (선택사항, 권장)
2. 예약 완료 시 푸시 알림 전송 구현
3. 예약 취소/변경 시 푸시 알림 전송 구현
4. 결제 완료 시 푸시 알림 전송 구현
5. 테스트 및 검증

**예상 소요 시간**: 3-4일 (다른 팀원 작업 완료 후)

### Phase 3: 문서화 및 최적화 (낮은 우선순위)
1. 문서 업데이트
2. 코드 리팩토링
3. 에러 처리 개선
4. 성능 최적화

**예상 소요 시간**: 1-2일

---

## 🔧 기술적 고려사항

### 1. Navigator 접근 문제
**문제**: 알림 클릭 핸들러에서 `Navigator`를 사용하려면 `BuildContext`가 필요함

**해결 방안**:
- `GlobalKey<NavigatorState>` 사용
- 또는 `go_router` 같은 라우팅 라이브러리 사용
- 또는 `NavigatorKey`를 전역으로 관리

### 2. 앱 상태 관리
**문제**: 알림 클릭 시 앱이 어떤 상태인지 확인 필요

**해결 방안**:
- 앱 라이프사이클 상태 확인
- Riverpod 상태 확인 (로그인 여부 등)
- 적절한 화면으로 라우팅

### 3. 중복 알림 방지
**문제**: 같은 알림이 여러 번 표시될 수 있음

**해결 방안**:
- 알림 ID 관리 (이미 구현됨)
- 서버에서 중복 전송 방지 로직 추가

### 4. 백엔드 FCM Admin SDK 설정
**문제**: Firebase Admin SDK 설정 필요

**해결 방안**:
- Firebase 프로젝트에서 서비스 계정 키 다운로드
- FastAPI에서 Admin SDK 초기화
- 환경 변수로 관리

### 5. iOS Profile/Release 빌드 문제
**문제**: Debug 모드에서는 작동하지만 Profile/Release 모드(IPA)에서 FCM 토큰이 발급되지 않음

**원인**: Profile 빌드 설정에 `CODE_SIGN_ENTITLEMENTS`가 없어서 entitlements가 적용되지 않음

**해결 방안**:
- Xcode 프로젝트 설정에서 Profile 빌드 설정에 `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;` 추가
- 또는 Xcode에서 Runner 타겟 → Build Settings → Code Signing Entitlements 확인
- 프로비저닝 프로파일에 Push Notifications capability 포함 확인

**참고**: Debug와 Release에는 이미 설정되어 있지만 Profile에는 누락되어 있었음

---

## 📝 참고 자료

### 공식 문서
- [Firebase Cloud Messaging 문서](https://firebase.google.com/docs/cloud-messaging)
- [flutter_local_notifications 패키지](https://pub.dev/packages/flutter_local_notifications)
- [Firebase Admin SDK (Python)](https://firebase.google.com/docs/admin/setup)
- [Android Notification Channels](https://developer.android.com/develop/ui/views/notifications/channels)
- [iOS User Notifications](https://developer.apple.com/documentation/usernotifications)

### 프로젝트 내 가이드 문서
- [FCM 메시지 데이터 활용 가이드](./FCM_메시지_데이터_활용_가이드.md) - `data` 필드 활용 방법
- [FCM 백엔드 푸시 알림 발송 가이드](./FCM_백엔드_푸시_알림_발송_가이드.md) - 백엔드 개발자용 사용 가이드
- [FCM 로컬 저장소 및 서버 연동 가이드](./FCM_로컬_저장소_및_서버_연동_가이드.md) - FCM 토큰 관리
- [FastAPI FCM 단발 푸시 테스트 가이드](./FastAPI_FCM_단발_푸시_테스트_가이드.md) - 테스트 방법

---

## 변경 이력

- **2026-01-19**: 초기 문서 작성
  - 완료된 작업 및 남은 작업 정리
  - 우선순위별 작업 계획 수립
  - 기술적 고려사항 정리
- **2026-01-19**: 문서 통합
  - `FCM_포그라운드_알림_표시_구현_계획.md` 내용 통합
  - 완료된 작업 상세화 (포그라운드 알림 표시, 백엔드 FCM 서비스)
  - 참고 자료 섹션 개선
- **2026-01-19**: FCM Admin SDK 전역 초기화 완료
  - `push_debug.py` 리팩토링: `FCMService` 사용으로 변경
  - 중복 초기화 코드 제거
  - 전역 초기화는 `FCMService`에서 자동 처리되도록 완료
- **2026-01-19**: 알림 클릭 핸들러 구현 완료
  - 포그라운드 알림 클릭 핸들러 구현 (`main.dart`)
  - 백그라운드/종료 상태 알림 클릭 핸들러 구현 (`FCMNotifier`)
  - 현재 화면 추적 기능 구현 (RouteObserver, CurrentScreenTracker)
  - 알림 클릭 시 로그 출력 및 현재 화면 정보 확인 가능
  - 화면 라우팅 로직은 아직 미구현 (TODO 주석만 있음)
- **2026-01-18**: iOS Profile/Release 빌드 문제 해결
  - Profile 빌드 설정에 `CODE_SIGN_ENTITLEMENTS` 추가
  - 프로필/릴리스 모드에서도 에러 로그 출력 가능하도록 수정
  - APNs 토큰 대기 시간 증가 (10초 → 30초)
  - 앱 생명주기 관찰자 추가 (포그라운드 복귀 시 APNs 토큰 재확인)
  - 알림 권한 확인 및 재시도 로직 개선
  - Dev_07 화면에 FCM 상태 표시 및 재시도 버튼 추가
  - FCM 초기화 재시도 메서드 구현 (`retryInitialization()`)