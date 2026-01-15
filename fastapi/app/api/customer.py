"""
Customer API - 고객 계정 CRUD 및 인증
회원가입 및 로그인 기능 포함
"""

from fastapi import APIRouter, Form
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from ..database.connection import connect_db

router = APIRouter()


# ============================================
# 모델 정의
# ============================================
class Customer(BaseModel):
    customer_seq: Optional[int] = None
    customer_name: str
    customer_phone: str
    customer_email: str
    customer_pw: Optional[str] = None  # 조회 시에는 제외
    created_at: Optional[str] = None


class RegisterRequest(BaseModel):
    customer_name: str
    customer_phone: str
    customer_email: str
    customer_pw: str


class LoginRequest(BaseModel):
    customer_email: str
    customer_pw: str


# ============================================
# 전체 고객 조회
# ============================================
@router.get("")
async def select_customers():
    """전체 고객 목록을 조회합니다 (비밀번호 제외)."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        curs.execute("""
            SELECT customer_seq, customer_name, customer_phone, customer_email, created_at 
            FROM customer 
            ORDER BY customer_seq
        """)
        rows = curs.fetchall()
        conn.close()
        
        result = []
        for row in rows:
            try:
                created_at = None
                if row[4]:
                    if hasattr(row[4], 'isoformat'):
                        created_at = row[4].isoformat()
                    else:
                        created_at = str(row[4])
                
                result.append({
                    'customer_seq': row[0],
                    'customer_name': row[1],
                    'customer_phone': row[2],
                    'customer_email': row[3],
                    'created_at': created_at
                })
            except Exception as e:
                print(f"Error processing row: {e}, row: {row}")
                continue
        
        return {"results": result}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}


# ============================================
# ID로 고객 조회
# ============================================
@router.get("/{customer_seq}")
async def select_customer(customer_seq: int):
    """특정 고객을 ID로 조회합니다 (비밀번호 제외)."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        curs.execute("""
            SELECT customer_seq, customer_name, customer_phone, customer_email, created_at 
            FROM customer 
            WHERE customer_seq = %s
        """, (customer_seq,))
        row = curs.fetchone()
        conn.close()
        
        if row is None:
            return {"result": "Error", "message": "Customer not found"}
        
        created_at = None
        if row[4]:
            if hasattr(row[4], 'isoformat'):
                created_at = row[4].isoformat()
            else:
                created_at = str(row[4])
        
        result = {
            'customer_seq': row[0],
            'customer_name': row[1],
            'customer_phone': row[2],
            'customer_email': row[3],
            'created_at': created_at
        }
        return {"result": result}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}


# ============================================
# 회원가입
# ============================================
@router.post("/register")
async def register_customer(
    customer_name: str = Form(...),
    customer_phone: str = Form(...),
    customer_email: str = Form(...),
    customer_pw: str = Form(...)
):
    """
    회원가입
    - 이메일 중복 확인
    - 고객 정보 저장
    """
    conn = connect_db()
    curs = conn.cursor()
    
    try:
        # 1. 이메일 중복 확인
        curs.execute("""
            SELECT customer_seq FROM customer WHERE customer_email = %s
        """, (customer_email,))
        existing_customer = curs.fetchone()
        
        if existing_customer:
            return {
                "result": "Error",
                "errorMsg": "이미 사용 중인 이메일입니다."
            }
        
        # 2. 고객 정보 저장
        # TODO: 향후 비밀번호 해시화 필요 (bcrypt 등)
        curs.execute("""
            INSERT INTO customer (customer_name, customer_phone, customer_email, customer_pw, created_at) 
            VALUES (%s, %s, %s, %s, NOW())
        """, (customer_name, customer_phone, customer_email, customer_pw))
        customer_seq = curs.lastrowid
        
        conn.commit()
        
        return {
            "result": {
                "customer_seq": customer_seq,
                "customer_name": customer_name,
                "customer_phone": customer_phone,
                "customer_email": customer_email,
                "created_at": datetime.now().isoformat()
            },
            "message": "회원가입 성공"
        }
        
    except Exception as e:
        conn.rollback()
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {
            "result": "Error",
            "errorMsg": error_msg,
            "traceback": traceback.format_exc()
        }
    finally:
        conn.close()


# ============================================
# 로그인
# ============================================
@router.post("/login")
async def login_customer(
    customer_email: str = Form(...),
    customer_pw: str = Form(...)
):
    """
    로그인
    - 이메일과 비밀번호 확인
    - 로그인 성공 시 고객 정보 반환
    """
    conn = connect_db()
    curs = conn.cursor()
    
    try:
        # 1. 이메일과 비밀번호로 고객 확인
        curs.execute("""
            SELECT customer_seq, customer_name, customer_phone, customer_email, created_at 
            FROM customer 
            WHERE customer_email = %s AND customer_pw = %s
        """, (customer_email, customer_pw))
        customer_row = curs.fetchone()
        
        if customer_row is None:
            return {
                "result": "Error",
                "errorMsg": "이메일 또는 비밀번호가 올바르지 않습니다."
            }
        
        # 2. 고객 정보 반환 (비밀번호 제외)
        created_at = None
        if customer_row[4]:
            if hasattr(customer_row[4], 'isoformat'):
                created_at = customer_row[4].isoformat()
            else:
                created_at = str(customer_row[4])
        
        return {
            "result": {
                "customer_seq": customer_row[0],
                "customer_name": customer_row[1],
                "customer_phone": customer_row[2],
                "customer_email": customer_row[3],
                "created_at": created_at
            },
            "message": "로그인 성공"
        }
        
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {
            "result": "Error",
            "errorMsg": error_msg,
            "traceback": traceback.format_exc()
        }
    finally:
        conn.close()


# ============================================
# 고객 정보 수정
# ============================================
@router.put("/{customer_seq}")
async def update_customer(
    customer_seq: int,
    customer_name: str = Form(...),
    customer_phone: str = Form(...),
    customer_email: str = Form(...),
    customer_pw: Optional[str] = Form(None)
):
    """
    고객 정보를 수정합니다.
    - 비밀번호는 선택사항 (변경하지 않으려면 None)
    """
    conn = connect_db()
    curs = conn.cursor()
    
    try:
        # 1. 고객 존재 확인
        curs.execute("""
            SELECT customer_seq FROM customer WHERE customer_seq = %s
        """, (customer_seq,))
        existing_customer = curs.fetchone()
        
        if existing_customer is None:
            return {
                "result": "Error",
                "errorMsg": "고객을 찾을 수 없습니다."
            }
        
        # 2. 이메일 중복 확인 (다른 고객이 사용 중인지)
        curs.execute("""
            SELECT customer_seq FROM customer 
            WHERE customer_email = %s AND customer_seq != %s
        """, (customer_email, customer_seq))
        email_duplicate = curs.fetchone()
        
        if email_duplicate:
            return {
                "result": "Error",
                "errorMsg": "이미 사용 중인 이메일입니다."
            }
        
        # 3. 고객 정보 수정
        if customer_pw:
            # 비밀번호 변경 포함
            curs.execute("""
                UPDATE customer 
                SET customer_name=%s, customer_phone=%s, customer_email=%s, customer_pw=%s 
                WHERE customer_seq=%s
            """, (customer_name, customer_phone, customer_email, customer_pw, customer_seq))
        else:
            # 비밀번호 변경 없음
            curs.execute("""
                UPDATE customer 
                SET customer_name=%s, customer_phone=%s, customer_email=%s 
                WHERE customer_seq=%s
            """, (customer_name, customer_phone, customer_email, customer_seq))
        
        conn.commit()
        conn.close()
        
        return {"result": "OK"}
        
    except Exception as e:
        conn.rollback()
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {
            "result": "Error",
            "errorMsg": error_msg,
            "traceback": traceback.format_exc()
        }
    finally:
        conn.close()


# ============================================
# 고객 삭제
# ============================================
@router.delete("/{customer_seq}")
async def delete_customer(customer_seq: int):
    """고객을 삭제합니다."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        
        # 고객 존재 확인
        curs.execute("""
            SELECT customer_seq FROM customer WHERE customer_seq = %s
        """, (customer_seq,))
        existing_customer = curs.fetchone()
        
        if existing_customer is None:
            return {
                "result": "Error",
                "errorMsg": "고객을 찾을 수 없습니다."
            }
        
        # 고객 삭제
        curs.execute("DELETE FROM customer WHERE customer_seq=%s", (customer_seq,))
        conn.commit()
        conn.close()
        
        return {"result": "OK"}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {
            "result": "Error",
            "errorMsg": error_msg,
            "traceback": traceback.format_exc()
        }
