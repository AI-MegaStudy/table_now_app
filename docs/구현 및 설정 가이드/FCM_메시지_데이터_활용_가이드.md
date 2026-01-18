# FCM 메시지 데이터 활용 가이드

FCM 메시지의 `notification`과 `data` 필드의 차이와 활용 방법을 설명합니다.

---

## 📨 FCM 메시지 구조

FCM 메시지는 두 가지 필드를 가질 수 있습니다:

### 1. `notification` 필드 (사용자에게 보이는 부분)
```json
{
  "notification": {
    "title": "예약 완료",
    "body": "예약이 완료되었습니다."
  }
}
```

**특징:**
- ✅ **알림 배너에 표시됨** (사용자가 볼 수 있음)
- ✅ 백그라운드/종료 상태에서 자동으로 알림 표시
- ❌ 포그라운드 상태에서는 자동 표시 안 됨 (로컬 노티 필요)
- ❌ 앱에서 직접 처리 불가 (시스템이 처리)

### 2. `data` 필드 (앱에서 활용하는 부분)
```json
{
  "data": {
    "type": "reservation_complete",
    "reserve_seq": "123",
    "store_seq": "456",
    "screen": "reservation_detail"
  }
}
```

**특징:**
- ✅ **알림 배너에 표시 안 됨** (사용자가 볼 수 없음)
- ✅ 앱에서 자유롭게 활용 가능
- ✅ 알림 클릭 시 화면 이동 등에 사용
- ✅ 백그라운드/포그라운드/종료 상태 모두에서 접근 가능

### 3. `notification` + `data` 조합 (권장)
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

**장점:**
- 사용자에게 알림 표시 (`notification`)
- 앱에서 데이터 활용 가능 (`data`)
- 알림 클릭 시 특정 화면으로 이동 가능

---

## 🔍 현재 구현 상태

### 서버 (FastAPI)
```python
# fastapi/app/api/push_debug.py
message = messaging.Message(
    token=req.token,
    notification=messaging.Notification(
        title=req.title,
        body=req.body,
    ),
    data={k: str(v) for k, v in (req.data or {}).items()},  # ✅ data 포함 가능
)
```

### 클라이언트 (Flutter)
```dart
// lib/vm/fcm_notifier.dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Data: ${message.data}');  // ✅ data 접근 가능
  // ...
});
```

```dart
// lib/utils/local_notification_service.dart
payload: jsonEncode(message.data),  // ✅ JSON 문자열로 변환하여 저장
```

---

## 💡 데이터 활용 예시

### 예시 1: 알림 클릭 시 화면 이동

**서버에서 보내는 메시지:**
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

**클라이언트에서 처리:**
```dart
// 알림 클릭 핸들러
LocalNotificationService.setOnNotificationTap((response) {
  final payload = response.payload; // JSON 문자열
  final data = jsonDecode(payload);
  
  switch (data['screen']) {
    case 'reservation_detail':
      Navigator.pushNamed(
        context,
        '/reservation/${data['reserve_seq']}',
      );
      break;
    // ...
  }
});
```

### 예시 2: 알림 타입별 다른 처리

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  final data = message.data;
  final type = data['type'];
  
  switch (type) {
    case 'reservation_complete':
      // 예약 완료 처리
      break;
    case 'reservation_cancelled':
      // 예약 취소 처리
      break;
    case 'payment_complete':
      // 결제 완료 처리
      break;
  }
  
  // 알림 표시
  LocalNotificationService.showNotification(message);
});
```

---

## 🔧 개선 방향

### 현재 문제점
1. `message.data.toString()`은 단순 문자열 변환만 함
2. JSON 파싱이 안 되어 데이터 활용 불가
3. 알림 클릭 시 화면 이동 로직 없음

### 개선 사항
1. ✅ `data`를 JSON 문자열로 변환하여 payload에 저장
2. ✅ 알림 클릭 핸들러에서 JSON 파싱
3. ✅ 현재 화면 추적 기능 구현 (RouteObserver 사용)
4. ⏳ 화면 라우팅 로직 구현 (진행 중 - TODO 주석만 있음)

---

## 📝 요약

| 항목 | `notification` | `data` |
|------|----------------|--------|
| **사용자에게 보임** | ✅ 예 | ❌ 아니오 |
| **알림 배너 표시** | ✅ 예 | ❌ 아니오 |
| **앱에서 활용** | ❌ 아니오 | ✅ 예 |
| **화면 이동 등** | ❌ 불가 | ✅ 가능 |
| **포그라운드 처리** | 로컬 노티 필요 | 직접 처리 가능 |

**결론:**
- `notification`: 사용자에게 알림을 보여주기 위한 용도
- `data`: 앱에서 처리할 데이터 (화면 이동, 상태 업데이트 등)
- 둘 다 포함하면 사용자 경험과 기능 모두 구현 가능

---

## 변경 이력

- **2026-01-16**: 초기 문서 작성
  - FCM 메시지 구조 설명
  - notification과 data의 차이점 정리
  - 데이터 활용 예시 추가
- **2026-01-18**: 구현 상태 업데이트
  - `data`를 JSON 문자열로 변환하여 payload에 저장하도록 수정 완료
  - 알림 클릭 핸들러에서 JSON 파싱 구현 완료
  - 현재 화면 추적 기능 구현 완료 (RouteObserver 사용)
  - 화면 라우팅 로직은 아직 미구현 (TODO 주석만 있음)