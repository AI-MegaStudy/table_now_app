# FastAPI FCM 단발 푸시 테스트 가이드

이 문서는 **DB·예약 로직을 전혀 건드리지 않고**, FastAPI 서버에서 **Firebase Admin SDK를 이용해 iOS/Android 실기기로 실제 푸시가 도착하는지**를 검증하기 위한 **최소 테스트 전용 문서**다.

> 목적: "푸시가 실제로 되는지"만 빠르게 검증

---

## 0. 작업 진행 상황

✅ **푸시 테스트 완료** - iOS/Android 실기기에서 푸시 수신 확인 완료

---

## 0. 이 테스트의 범위

### 포함되는 것

- Firebase Admin SDK 인증
- FastAPI → FCM → APNs/GCM → iOS/Android 실기기
- 단일 FCM 토큰 대상으로 1회 발송

### 포함되지 않는 것

- DB 저장
- 예약/결제 로직
- 사용자 관리
- 재시도/큐/로그

---

## 1. 사전 조건

- [x] Flutter 앱에서 **FCM_TOKEN 출력 완료** (실기기에서 확인)
- [x] Firebase 콘솔에서 **APNs Auth Key(.p8) 업로드 완료** (iOS용)
- [x] FastAPI 서버가 로컬에서 실행 가능
- [x] iOS/Android 실기기에서 알림 권한 허용됨

---

## 2. Firebase 서비스 계정 키 생성

### 경로

Firebase 콘솔 → 프로젝트 설정 → **서비스 계정** → Firebase Admin SDK

### 작업

- [x] 1. **「새 비공개 키 생성」** 클릭
- [x] 2. JSON 파일 다운로드
- [x] 3. 파일명 변경:
   ```
   serviceAccountKey.json
   ```
- [x] 4. 파일 위치: `fastapi/serviceAccountKey.json`

### ⚠️ 주의

- Flutter 프로젝트에 포함 ❌
- Git 커밋 ❌ (`.gitignore`에 추가)
- 서버에서만 사용
- 보안에 주의 (절대 공개 저장소에 업로드하지 않음)

---

## 3. FastAPI 프로젝트 구조

현재 프로젝트 구조:

```
fastapi/
 ├─ app/
 │   ├─ __init__.py
 │   ├─ main.py
 │   ├─ api/
 │   │   ├─ __init__.py
 │   │   ├─ customer.py
 │   │   ├─ weather.py
 │   │   └─ ... (기타 API)
 │   └─ utils/
 │       ├─ email_service.py
 │       └─ weather_service.py
 ├─ serviceAccountKey.json  # 여기에 저장
 ├─ requirements.txt
 └─ .env
```

---

## 4. Firebase Admin SDK 설치

- [x] `fastapi/requirements.txt`에 추가:
```txt
firebase-admin>=6.0.0
```

- [x] 설치:
```bash
cd fastapi
pip install firebase-admin
```

또는:

```bash
pip install -r requirements.txt
```

---

## 5. 단발 푸시 테스트 API 구현

### 체크리스트

- [x] 5.1 `fastapi/app/api/push_debug.py` 생성

```python
"""
FCM 단발 푸시 테스트 API
DB·예약 로직 없이 푸시 발송만 테스트하기 위한 디버그 엔드포인트
작성일: 2026-01-17
작성자: 김택권
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import firebase_admin
from firebase_admin import credentials, messaging
import os

router = APIRouter()

# Firebase Admin SDK 초기화 (서버 실행 시 1회)
if not firebase_admin._apps:
    # serviceAccountKey.json 경로 설정
    cred_path = os.path.join(
        os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
        "serviceAccountKey.json"
    )
    
    if not os.path.exists(cred_path):
        print(f"⚠️  Warning: serviceAccountKey.json not found at {cred_path}")
        print("⚠️  FCM push will not work until serviceAccountKey.json is added")
    else:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        print("✅ Firebase Admin SDK initialized successfully")


class PushRequest(BaseModel):
    """푸시 발송 요청 모델"""
    token: str
    title: str = "테스트 푸시"
    body: str = "FCM 단발 테스트"
    data: dict | None = None


@router.post("/debug/push")
async def debug_push(req: PushRequest):
    """
    FCM 단발 푸시 테스트 엔드포인트
    
    Args:
        req: 푸시 발송 요청 (token, title, body, data)
    
    Returns:
        성공 시 message_id 반환
    """
    try:
        # Firebase Admin SDK가 초기화되지 않은 경우
        if not firebase_admin._apps:
            raise HTTPException(
                status_code=500,
                detail="Firebase Admin SDK not initialized. Check serviceAccountKey.json"
            )
        
        # FCM 메시지 생성
        message = messaging.Message(
            token=req.token,
            notification=messaging.Notification(
                title=req.title,
                body=req.body,
            ),
            data={k: str(v) for k, v in (req.data or {}).items()},
        )
        
        # 푸시 발송
        message_id = messaging.send(message)
        
        return {
            "ok": True,
            "message_id": message_id,
            "token": req.token[:20] + "..." if len(req.token) > 20 else req.token,
        }
        
    except messaging.UnregisteredError:
        raise HTTPException(
            status_code=400,
            detail="FCM token is invalid or expired. Please get a new token from the app."
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to send push notification: {str(e)}"
        )


# ============================================================
# 생성 이력
# ============================================================
# 작성일: 2026-01-17
# 작성자: 김택권
# 설명: FCM 단발 푸시 테스트 API - DB·예약 로직 없이 푸시 발송만 테스트
#
# ============================================================
# 수정 이력
# ============================================================
# 2026-01-17 김택권: 초기 생성
#   - Firebase Admin SDK 초기화 로직
#   - /debug/push 엔드포인트 구현
#   - 에러 처리 및 응답 형식 정의
```

- [x] 5.2 `fastapi/app/main.py`에 라우터 등록

`fastapi/app/main.py`의 라우터 등록 섹션에 추가:

```python
# API 라우터 import 및 등록
from app.api import customer, weather, menu, option, store, reserve, store_table, push_debug

# ... 기존 라우터 등록 ...

# Push Debug API 라우터 등록 (테스트용)
app.include_router(push_debug.router, prefix="/api", tags=["push_debug"])
```

---

## 6. 서버 실행

```bash
cd fastapi
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

또는:

```bash
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

---

## 7. curl로 실제 푸시 발송 테스트

Flutter 콘솔에 출력된 FCM_TOKEN을 사용합니다.

### 기본 테스트

```bash
curl -X POST "http://127.0.0.1:8000/api/debug/push" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "FCM_TOKEN_여기에",
    "title": "예약 테스트",
    "body": "푸시 수신 확인용"
  }'
```

### 데이터 포함 테스트

```bash
curl -X POST "http://127.0.0.1:8000/api/debug/push" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "FCM_TOKEN_여기에",
    "title": "예약 테스트",
    "body": "푸시 수신 확인용",
    "data": {
      "type": "test",
      "reservation_id": "123",
      "store_name": "테스트 식당"
    }
  }'
```

### 로컬 네트워크에서 테스트 (Mac IP 사용)

```bash
curl -X POST "http://192.168.1.104:8000/api/debug/push" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "FCM_TOKEN_여기에",
    "title": "예약 테스트",
    "body": "푸시 수신 확인용"
  }'
```

---

## 8. 성공 기준

### 체크리스트

- [x] 서버 응답 확인:
```json
{
  "ok": true,
  "message_id": "projects/tablenow-dcfc4/messages/0:1234567890",
  "token": "eYJ0...긴문자열..."
}
```

- [x] iOS 실기기 테스트:
  - [x] 앱이 **백그라운드 또는 종료 상태**일 때
  - [x] 알림 배너가 실제로 표시됨
  - [x] 알림을 탭하면 앱이 열림

- [x] Android 실기기/에뮬레이터 테스트:
  - [x] 앱이 **백그라운드 또는 종료 상태**일 때
  - [x] 알림이 실제로 표시됨
  - [x] 알림을 탭하면 앱이 열림

✅ **최소 푸시 테스트 성공** - 다음 단계 진행 가능

---

## 9. 실패 시 점검 순서

### 서버 측 확인

1. **서버에서 message_id가 반환되는가?**
   - ✅ 반환됨 → FCM 서버까지는 정상 전달됨
   - ❌ 에러 발생 → Firebase Admin SDK 설정 확인

2. **serviceAccountKey.json 파일이 올바른 위치에 있는가?**
   - `fastapi/serviceAccountKey.json` 경로 확인
   - 파일 권한 확인
   - 서버 시작 시 `✅ Firebase Admin SDK initialized successfully` 메시지 확인

### 클라이언트 측 확인

3. **FCM_TOKEN이 최신 값인가?**
   - 앱 재설치 후 토큰 재확인
   - Flutter 콘솔에서 새 토큰 출력 확인
   - 토큰이 `null`이 아닌지 확인

4. **iOS 알림 권한이 허용되어 있는가?**
   - 설정 → 앱 이름 → 알림 → 허용 확인
   - 앱 실행 시 권한 요청 팝업 확인

5. **Firebase 콘솔에서 APNs 키 상태 정상인가?**
   - Firebase Console → 프로젝트 설정 → Cloud Messaging → APNs 인증 키 확인
   - 키가 업로드되어 있고 활성화되어 있는지 확인

6. **앱이 포그라운드 상태는 아닌가?**
   - 포그라운드에서는 알림이 표시되지 않을 수 있음
   - 백그라운드 또는 종료 상태에서 테스트
   - 홈 버튼을 눌러 앱을 백그라운드로 보낸 후 테스트

### 네트워크 확인

7. **서버와 클라이언트가 같은 네트워크에 있는가?**
   - 로컬 네트워크 테스트 시 IP 주소 확인
   - `127.0.0.1`은 같은 기기에서만 접근 가능
   - 다른 기기에서 테스트 시 Mac의 로컬 IP 사용 (`192.168.x.x`)

8. **방화벽이 포트 8000을 차단하지 않는가?**
   - Mac 방화벽 설정 확인
   - 서버가 `--host 0.0.0.0`으로 실행되었는지 확인

---

## 10. 에러 메시지 해석

### `Firebase Admin SDK not initialized`

- `serviceAccountKey.json` 파일이 없거나 경로가 잘못됨
- 해결: 파일 위치 확인 및 경로 수정

### `FCM token is invalid or expired`

- 토큰이 만료되었거나 잘못된 토큰
- 해결: 앱에서 새 토큰 받아서 재시도

### `Failed to send push notification`

- Firebase 서버 연결 문제 또는 권한 문제
- 해결: Firebase 콘솔에서 서비스 계정 키 재생성

---

## 11. 이 테스트 이후 다음 단계

- FCM 토큰 DB 저장 구조 설계
- 예약 완료 트랜잭션과 푸시 발송 연결
- 실패 로그 및 재시도 정책 설계
- 배치 푸시 발송 (여러 사용자에게 동시 발송)
- 푸시 알림 타입별 처리 로직 (예약 완료, 예약 취소 등)

---

## 12. 보안 주의사항

### ⚠️ 중요

- `serviceAccountKey.json`은 **절대 Git에 커밋하지 않음**
- `.gitignore`에 추가:
  ```
  fastapi/serviceAccountKey.json
  ```
- 프로덕션 환경에서는 환경변수나 시크릿 관리 시스템 사용
- 디버그 엔드포인트(`/api/debug/push`)는 프로덕션에서 비활성화 권장

---

## 13. 프로젝트 구조에 맞는 파일 생성 가이드

### 파일 생성 순서

1. `fastapi/serviceAccountKey.json` 다운로드 및 배치
2. `fastapi/app/api/push_debug.py` 생성
3. `fastapi/app/main.py`에 라우터 등록
4. `fastapi/requirements.txt`에 `firebase-admin` 추가
5. `pip install firebase-admin` 실행
6. 서버 재시작
7. curl로 테스트

---

## 요약

- 이 문서는 **FastAPI → FCM → iOS/Android 실기기** 푸시 경로를 검증하기 위한 테스트 전용 가이드입니다
- DB, 예약, 사용자 개념은 포함하지 않습니다
- 현재 프로젝트 구조(`fastapi/app/api/`)에 맞게 작성되었습니다

---

## 수정 이력

- 2026-01-17: 초기 문서 작성
  - 현재 프로젝트 구조 반영
  - `fastapi/app/api/push_debug.py` 구조 제시
  - 에러 처리 및 보안 주의사항 추가

- 2026-01-17: 실제 테스트 경험 반영
  - 실패 시 점검 순서 상세화 (서버/클라이언트/네트워크 구분)
  - 네트워크 연결 문제 해결 가이드 추가
  - 로컬 네트워크 테스트 주의사항 추가
