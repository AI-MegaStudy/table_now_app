"""
FCM 푸시 알림 발송 서비스
다른 API 파일에서 import하여 사용할 수 있는 공통 FCM 서비스
작성일: 2026-01-19
작성자: 김택권
"""

import firebase_admin
from firebase_admin import credentials, messaging
import os
from typing import Optional, Dict, List


class FCMService:
    """FCM 푸시 알림 발송 서비스 클래스"""
    
    _initialized = False
    
    @classmethod
    def _ensure_initialized(cls):
        """Firebase Admin SDK 초기화 확인 및 초기화"""
        if cls._initialized:
            return
        
        if firebase_admin._apps:
            cls._initialized = True
            return
        
        # serviceAccountKey.json 경로 설정
        cred_path = os.path.join(
            os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
            "serviceAccountKey.json"
        )
        
        if not os.path.exists(cred_path):
            print(f"⚠️  Warning: serviceAccountKey.json not found at {cred_path}")
            print("⚠️  FCM push will not work until serviceAccountKey.json is added")
            return
        
        try:
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            cls._initialized = True
            print("✅ Firebase Admin SDK initialized successfully")
        except Exception as e:
            print(f"❌ Firebase Admin SDK initialization failed: {e}")
    
    @classmethod
    def send_notification(
        cls,
        token: str,
        title: str,
        body: str,
        data: Optional[Dict[str, str]] = None
    ) -> Optional[str]:
        """
        단일 기기에 푸시 알림 발송
        
        Args:
            token: FCM 토큰
            title: 알림 제목
            body: 알림 내용
            data: 추가 데이터 (선택사항)
            
        Returns:
            str: 메시지 ID (성공 시), None (실패 시)
        """
        cls._ensure_initialized()
        
        if not firebase_admin._apps:
            print("⚠️  Firebase Admin SDK not initialized")
            return None
        
        try:
            message = messaging.Message(
                token=token,
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data={k: str(v) for k, v in (data or {}).items()},
            )
            
            message_id = messaging.send(message)
            print(f"✅ Push notification sent: {message_id}")
            return message_id
            
        except messaging.UnregisteredError:
            print("⚠️  FCM token is invalid or expired")
            return None
        except Exception as e:
            print(f"❌ Failed to send push notification: {e}")
            return None
    
    @classmethod
    def send_notification_to_customer(
        cls,
        customer_seq: int,
        title: str,
        body: str,
        data: Optional[Dict[str, str]] = None
    ) -> int:
        """
        고객의 모든 기기에 푸시 알림 발송
        
        Args:
            customer_seq: 고객 번호
            title: 알림 제목
            body: 알림 내용
            data: 추가 데이터 (선택사항)
            
        Returns:
            int: 발송 성공한 기기 수
        """
        from app.database.connection import connect_db
        
        cls._ensure_initialized()
        
        if not firebase_admin._apps:
            print("⚠️  Firebase Admin SDK not initialized")
            return 0
        
        # 고객의 FCM 토큰 조회
        conn = connect_db()
        curs = conn.cursor()
        
        try:
            curs.execute("""
                SELECT fcm_token FROM device_token 
                WHERE customer_seq = %s
            """, (customer_seq,))
            
            tokens = [row[0] for row in curs.fetchall()]
            
            if not tokens:
                print(f"⚠️  No FCM tokens found for customer_seq: {customer_seq}")
                return 0
            
            # 각 토큰에 알림 발송
            success_count = 0
            for token in tokens:
                message_id = cls.send_notification(token, title, body, data)
                if message_id:
                    success_count += 1
            
            print(f"✅ Sent notifications to {success_count}/{len(tokens)} devices")
            return success_count
            
        except Exception as e:
            print(f"❌ Failed to send notifications to customer: {e}")
            return 0
        finally:
            try:
                curs.close()
                conn.close()
            except:
                pass
    
    @classmethod
    def send_multicast_notification(
        cls,
        tokens: List[str],
        title: str,
        body: str,
        data: Optional[Dict[str, str]] = None
    ) -> int:
        """
        여러 기기에 동시에 푸시 알림 발송 (최대 500개)
        
        Args:
            tokens: FCM 토큰 리스트
            title: 알림 제목
            body: 알림 내용
            data: 추가 데이터 (선택사항)
            
        Returns:
            int: 발송 성공한 기기 수
        """
        cls._ensure_initialized()
        
        if not firebase_admin._apps:
            print("⚠️  Firebase Admin SDK not initialized")
            return 0
        
        if not tokens:
            return 0
        
        # FCM은 최대 500개까지 한 번에 발송 가능
        if len(tokens) > 500:
            print(f"⚠️  Too many tokens ({len(tokens)}). Maximum is 500.")
            tokens = tokens[:500]
        
        try:
            message = messaging.MulticastMessage(
                tokens=tokens,
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data={k: str(v) for k, v in (data or {}).items()},
            )
            
            response = messaging.send_multicast(message)
            success_count = response.success_count
            
            print(f"✅ Sent notifications to {success_count}/{len(tokens)} devices")
            return success_count
            
        except Exception as e:
            print(f"❌ Failed to send multicast notification: {e}")
            return 0


# ============================================================
# 생성 이력
# ============================================================
# 작성일: 2026-01-19
# 작성자: 김택권
# 설명: FCM 푸시 알림 발송 서비스 - 다른 API 파일에서 import하여 사용 가능
#
# ============================================================
# 수정 이력
# ============================================================
# 2026-01-19 김택권: 초기 생성
#   - Firebase Admin SDK 전역 초기화 로직
#   - 단일 기기 알림 발송 함수 (`send_notification`)
#   - 고객의 모든 기기 알림 발송 함수 (`send_notification_to_customer`)
#   - 여러 기기 동시 알림 발송 함수 (`send_multicast_notification`)
