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
