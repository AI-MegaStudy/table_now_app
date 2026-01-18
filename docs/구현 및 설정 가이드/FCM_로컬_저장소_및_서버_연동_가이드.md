# FCM 로컬 저장소 및 서버 연동 가이드

FCM 토큰을 로컬에 저장하고 서버와 동기화하는 방법을 설명합니다.

---

## 0. 작업 진행 상황

### 완료된 작업
- [x] FCM 로컬 저장소 구현 (`FCMStorage` 클래스)
- [x] FCM 토큰 자동 저장 (토큰 발급 시, 갱신 시)
- [x] 알림 권한 상태 저장
- [x] 서버 동기화 상태 관리
- [x] DB 테이블 생성 (`device_token` 테이블)
- [x] 서버 API 엔드포인트 구현 (`POST /api/customer/{customer_seq}/fcm-token`)
- [x] 클라이언트 `sendTokenToServer` 메서드 구현
- [x] 로그인 시 자동 토큰 전송 구현
- [x] 토큰 갱신 시 자동 전송 구현

### 진행 중/예정 작업
- [ ] 포그라운드 알림 표시 기능 구현 (로컬 노티피케이션 사용)
- [ ] 예약 완료 시 푸시 알림 전송 구현
- [ ] 예약 취소/변경 시 푸시 알림 전송 구현

---

## 1. 로컬 저장 항목

| 키 | 타입 | 설명 |
|---|---|---|
| `fcm_token` | String | 현재 발급받은 FCM 토큰 |
| `fcm_last_sent_token` | String | 서버에 마지막으로 전송한 토큰 |
| `fcm_server_synced` | bool | 서버 동기화 성공 여부 |
| `fcm_last_sync_attempt` | String | 마지막 서버 전송 시도 시간 (ISO 8601) |
| `fcm_notification_permission` | bool | 알림 권한 허용 여부 |

---

## 2. FCMStorage 클래스 사용법

### 기본 사용

```dart
import 'package:table_now_app/utils/fcm_storage.dart';

// 토큰 저장
await FCMStorage.saveFCMToken(token);

// 토큰 가져오기
String? token = FCMStorage.getFCMToken();

// 서버 동기화 상태 확인
bool isSynced = FCMStorage.isTokenSynced();

// 모든 데이터 삭제 (로그아웃 시)
await FCMStorage.clearAll();
```

### 주요 메서드

#### 토큰 관리
```dart
await FCMStorage.saveFCMToken(token);      // 토큰 저장
String? token = FCMStorage.getFCMToken();   // 토큰 가져오기
await FCMStorage.clearToken();              // 토큰 삭제
```

#### 서버 동기화 관리
```dart
await FCMStorage.saveLastSentToken(token);  // 마지막 전송 토큰 저장
await FCMStorage.setServerSyncStatus(true);  // 동기화 상태 저장
bool isSynced = FCMStorage.isServerSynced(); // 동기화 상태 확인
bool isSynced = FCMStorage.isTokenSynced();  // 토큰 동기화 확인
```

#### 전송 시도 시간 관리
```dart
await FCMStorage.saveLastSyncAttempt(DateTime.now());  // 시도 시간 저장
DateTime? lastAttempt = FCMStorage.getLastSyncAttempt(); // 시도 시간 가져오기
```

#### 알림 권한 관리
```dart
await FCMStorage.saveNotificationPermissionStatus(true);  // 권한 상태 저장
bool? hasPermission = FCMStorage.getNotificationPermissionStatus(); // 권한 확인
```

---

## 3. 자동 저장

현재 `FCMNotifier`에서 자동으로 처리됩니다:

- **토큰 발급 시**: 자동으로 로컬에 저장
- **토큰 갱신 시**: 새 토큰 저장 및 동기화 상태 초기화
- **알림 권한 요청 시**: 권한 상태 자동 저장

---

## 4. 서버 연동 구현

### 작업 체크리스트

- [x] 4.1 서버 API 엔드포인트 구현
- [x] 4.2 클라이언트 `sendTokenToServer` 메서드 구현
- [x] 4.3 로그인 시 자동 전송 구현
- [x] 4.4 토큰 갱신 시 자동 전송 구현

### 4.1 서버 API 엔드포인트

**엔드포인트 스펙:**
```
POST /api/customer/{customer_seq}/fcm-token
Content-Type: application/json

{
  "fcm_token": "토큰_문자열",
  "device_type": "ios" | "android"
}
```

**구현 위치:** `fastapi/app/api/customer.py`

### 4.2 클라이언트 구현

`lib/vm/fcm_notifier.dart`에 추가:

```dart
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_now_app/config.dart';

/// 서버에 FCM 토큰 전송
Future<bool> sendTokenToServer(int customerSeq) async {
  final token = state.token;
  if (token == null) return false;

  try {
    await FCMStorage.saveLastSyncAttempt(DateTime.now());

    // getApiBaseUrl()은 동기 함수 (앱 시작 시 초기화됨)
    final apiBaseUrl = getApiBaseUrl();
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/customer/$customerSeq/fcm-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fcm_token': token,
        'device_type': Platform.isIOS ? 'ios' : 'android',
      }),
    );

    if (response.statusCode == 200) {
      await FCMStorage.saveLastSentToken(token);
      await FCMStorage.setServerSyncStatus(true);
      return true;
    } else {
      await FCMStorage.setServerSyncStatus(false);
      return false;
    }
  } catch (e) {
    await FCMStorage.setServerSyncStatus(false);
    return false;
  }
}
```

### 4.3 로그인 시 자동 전송

```dart
// 로그인 성공 후
final customerSeq = CustomerStorage.getCustomerSeq();
if (customerSeq != null) {
  await ref.read(fcmNotifierProvider.notifier).sendTokenToServer(customerSeq);
}
```

### 4.4 토큰 갱신 시 자동 전송

`_setupTokenRefreshListener()`에서:

```dart
_messaging.onTokenRefresh.listen((newToken) async {
  await FCMStorage.saveFCMToken(newToken);
  await FCMStorage.clearSyncStatus();
  
  final customerSeq = CustomerStorage.getCustomerSeq();
  if (customerSeq != null) {
    await sendTokenToServer(customerSeq);
  }
});
```

---

## 5. 전체 플로우

### 앱 시작 시
```
1. FCM 초기화 → 토큰 발급 → 로컬 저장
2. 로그인 상태 확인
3. 로그인되어 있으면 서버에 토큰 전송
```

### 로그인 시
```
1. 로그인 성공
2. FCM 토큰 가져오기
3. 서버에 토큰 전송
4. 전송 성공 시 마지막 전송 토큰 저장
```

### 토큰 갱신 시
```
1. 토큰 갱신 감지
2. 새 토큰 로컬 저장
3. 서버 동기화 상태 초기화
4. 로그인 상태면 서버에 새 토큰 전송
```

### 로그아웃 시
```
1. 로그아웃
2. FCM 서버 동기화 상태만 초기화 (FCMStorage.clearSyncStatus)
   - 토큰과 알림 권한은 기기별이므로 유지
   - 다음 로그인 시 재사용 가능
```

---

## 6. 재시도 로직

```dart
/// 재시도가 필요한지 확인
bool shouldRetrySync() {
  final lastAttempt = FCMStorage.getLastSyncAttempt();
  if (lastAttempt == null) return true;
  
  final now = DateTime.now();
  final difference = now.difference(lastAttempt);
  
  // 마지막 시도 후 5분이 지났고, 동기화되지 않았으면 재시도
  return difference.inMinutes >= 5 && !FCMStorage.isServerSynced();
}
```

---

## 7. DB 구조 (서버)

### 작업 체크리스트

- [x] DB 테이블 생성 (`device_token` 테이블)
- [x] SQL 마이그레이션 스크립트 작성
- [x] 테이블 생성 확인

### 옵션 1: Customer 테이블에 컬럼 추가

```sql
ALTER TABLE customer ADD COLUMN fcm_token VARCHAR(255);
ALTER TABLE customer ADD COLUMN device_type VARCHAR(10);
```

### 옵션 2: 별도 테이블 생성 (권장)

**구현 위치:** `fastapi/mysql/` 디렉토리에 마이그레이션 스크립트 생성

```sql
CREATE TABLE device_token (
    device_token_seq INT AUTO_INCREMENT PRIMARY KEY,
    customer_seq INT NOT NULL,
    fcm_token VARCHAR(255) NOT NULL,
    device_type VARCHAR(10) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_seq) REFERENCES customer(customer_seq) ON DELETE CASCADE,
    UNIQUE KEY uk_customer_token (customer_seq, fcm_token),
    INDEX idx_fcm_token (fcm_token)
);
```

---

## 8. 사용 예시

### 로그인 후 토큰 전송

```dart
Future<void> onLoginSuccess(Customer customer) async {
  await CustomerStorage.saveCustomer(customer);
  
  final fcmNotifier = ref.read(fcmNotifierProvider.notifier);
  final token = fcmNotifier.currentToken;
  
  if (token != null) {
    await fcmNotifier.sendTokenToServer(customer.customerSeq);
  }
}
```

### 앱 시작 시 동기화 확인

```dart
Future<void> checkTokenSync() async {
  final customerSeq = CustomerStorage.getCustomerSeq();
  if (customerSeq == null) return;
  
  if (!FCMStorage.isTokenSynced()) {
    final token = FCMStorage.getFCMToken();
    if (token != null) {
      await ref.read(fcmNotifierProvider.notifier).sendTokenToServer(customerSeq);
    }
  }
}
```

### 로그아웃 시 정리

```dart
Future<void> onLogout() async {
  await CustomerStorage.clearCustomer();
  // 서버 동기화 상태만 초기화 (토큰과 알림 권한은 기기별이므로 유지)
  await FCMStorage.clearSyncStatus();
}
```

---

## 9. 주의사항

- **토큰 보안**: FCM 토큰은 기기별 고유하지만 민감한 정보는 아님
- **동기화 상태**: 서버 전송 실패 시 `fcm_server_synced`를 `false`로 설정
- **여러 기기 지원**: 한 사용자가 여러 기기 사용 가능하므로 `device_token` 테이블 권장
- **토큰 갱신**: 토큰이 갱신되면 서버에 업데이트 필요
