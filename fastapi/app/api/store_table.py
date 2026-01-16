"""
store_table API - store_table CRUD
개별 실행: python store_table.py

작성자: 이예은     
작성일: 2026.01.15

수정 이력:
| 날짜     | 작성자| 내용 |
|2026.01.15|이예은| ———|
|      |        |      |
"""

from fastapi import FastAPI, Form, UploadFile, File, Response
from pydantic import BaseModel
from typing import Optional
from database.connection import connect_db

app = FastAPI()
ipAddress = "127.0.0.1"
port = 8000


# ============================================
# 모델 정의
# ============================================
# TODO: 테이블 컬럼에 맞게 모델 정의
# - id는 Optional[int] = None 으로 정의 (자동 생성)
# - 필수 컬럼은 타입만 지정 (예: cEmail: str)
# - 선택 컬럼은 Optional로 지정 (예: cProfileImage: Optional[bytes] = None)

class StoreTable(BaseModel):
        store_table_seq: Optional[int] = None
        store_seq: Optional[int] = None
        store_table_name: Optional[int] = None
        store_table_capacity: Optional[int] = None
        store_table_inuse: Optional[str] = None
        created_at: Optional[str] = None
    # TODO: 컬럼 추가


# ============================================
# 전체 조회 (Read All)
# ============================================
# TODO: 전체 목록 조회 API 구현
# - 이미지 BLOB 컬럼은 제외하고 조회
# - ORDER BY id 정렬
@router.get("/select_StoreTables")
async def select_all():
    conn = connect_db()
    curs = conn.cursor()
    
    # 테이블명을 StoreTable로 통일
    curs.execute("""
        SELECT store_table_seq, store_seq, store_table_name, store_table_capacity, store_table_inuse, created_at
        FROM StoreTable 
        ORDER BY store_table_seq
    """)
    
    rows = curs.fetchall()
    conn.close()
    
    result = [{
         'store_table_seq':row[0],
         'store_seq':row[1],
         'store_table_name':row[2],
         'store_table_capacity':row[3], 
         'store_table_inuse':row[4],
         'created_at':row[5]
    } for row in rows]
    
    return {"results": result}

# ============================================
# 단일 조회 (Read One)
# ============================================
# TODO: ID로 단일 조회 API 구현
# - 존재하지 않으면 에러 응답
@router.get("/select_StoreTable/{store_table_seq}")
async def select_one(store_table_seq: int):
    conn = connect_db()
    curs = conn.cursor()
    
    curs.execute("""
        SELECT store_table_seq, store_seq, store_table_name, store_table_capacity, store_table_inuse, created_at
        FROM StoreTable
        WHERE store_table_seq = %s
    """, (store_table_seq,))
    
    row = curs.fetchone()
    conn.close()
    
    if row is None:
        return {"result": "Error", "message": "StoreTable not found"}
    
    result = {
         'store_table_seq':row[0],
         'store_seq':row[1],
         'store_table_name':row[2],
         'store_table_capacity':row[3], 
         'store_table_inuse':row[4],
         'created_at':row[5]
    }
    return {"result": result}


# ============================================
# 추가 (Create)
# ============================================
# TODO: 새 레코드 추가 API 구현
# - Form 데이터로 받기: 파라미터 = Form(...)
# - 성공 시 생성된 ID 반환
# - 에러 처리 필수
@router.post("/insert_StoreTable")
async def insert_one(
      store_seq: int = Form(...),
      store_table_name: int = Form(...), 
      store_table_capacity: int = Form(...), 
      store_table_inuse: str = Form(...), # String -> str 수정
      created_at: str = Form(...),        # String -> str 수정
):
    try:
        conn = connect_db()
        curs = conn.cursor()
        
        sql = """
            INSERT INTO StoreTable (store_seq, store_table_name, store_table_capacity, store_table_inuse, created_at) 
            VALUES (%s, %s, %s, %s, NOW())
        """
        curs.execute(sql, (store_seq, store_table_name, store_table_capacity, store_table_inuse))
        
        conn.commit()
        inserted_id = curs.lastrowid
        conn.close()
        
        return {"result": "OK", "id": inserted_id}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}

# ============================================
# 수정 (Update)
# ============================================
# TODO: 레코드 수정 API 구현
# - 이미지 BLOB이 있는 경우: 이미지 제외/포함 두 가지 API 구현 권장
@router.post("/update_StoreTable")
async def update_one(
    store_table_seq: int = Form(...),
    store_seq: int = Form(...),
    store_table_name: int = Form(...), 
    store_table_capacity: int = Form(...),
    store_table_inuse: Optional[str] = Form(None),
    created_at: Optional[str] = Form(None),
):
    try:
        conn = connect_db()
        curs = conn.cursor()
        
        sql = """
            UPDATE StoreTable 
            SET store_seq=%s, store_table_name=%s, store_table_capacity=%s, store_table_inuse=%s, created_at=%s
            WHERE store_table_seq=%s 
        """
        curs.execute(sql, (store_seq, store_table_name, store_table_capacity, store_table_inuse, created_at, store_table_seq))
        
        conn.commit()
        conn.close()
        
        return {"result": "OK"}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}


# ============================================
# 삭제 (Delete)
# ============================================
# TODO: 레코드 삭제 API 구현
# - FK 참조 시 삭제 실패할 수 있음 (에러 처리)
@router.delete("/delete_StoreTable/{store_table_seq}")
async def delete_one(store_table_seq: int):
    try:
        conn = connect_db()
        curs = conn.cursor()
        
        # 테이블명과 ID 컬럼명 수정
        sql = "DELETE FROM StoreTable WHERE store_table_seq=%s"
        curs.execute(sql, (store_table_seq,))
        
        conn.commit()
        conn.close()
        
        return {"result": "OK"}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}

# ============================================
# [선택] 이미지 조회 (이미지 BLOB 컬럼이 있는 경우)
# ============================================
# TODO: 이미지 바이너리 직접 반환
# - Response 객체 사용
# - media_type: "image/jpeg" 또는 "image/png"
# @app.get("/view_[테이블명]_image/{item_id}")
# async def view_image(item_id: int):
#     try:
#         conn = connect_db()
#         curs = conn.cursor()
#         curs.execute("SELECT [이미지컬럼] FROM [테이블명] WHERE id = %s", (item_id,))
#         row = curs.fetchone()
#         conn.close()
#         
#         if row is None:
#             return {"result": "Error", "message": "Not found"}
#         
#         if row[0] is None:
#             return {"result": "Error", "message": "No image"}
#         
#         return Response(
#             content=row[0],
#             media_type="image/jpeg",
#             headers={"Cache-Control": "no-cache"}
#         )
#     except Exception as e:
#         return {"result": "Error", "errorMsg": str(e)}


# ============================================
# [선택] 이미지 업데이트 (이미지 BLOB 컬럼이 있는 경우)
# ============================================
# TODO: 이미지만 별도로 업데이트
# - UploadFile = File(...) 사용
# @app.post("/update_[테이블명]_image")
# async def update_image(
#     item_id: int = Form(...),
#     file: UploadFile = File(...)
# ):
#     try:
#         image_data = await file.read()
#         
#         conn = connect_db()
#         curs = conn.cursor()
#         sql = "UPDATE [테이블명] SET [이미지컬럼]=%s WHERE id=%s"
#         curs.execute(sql, (image_data, item_id))
#         conn.commit()
#         conn.close()
#         
#         return {"result": "OK"}
#     except Exception as e:
#         return {"result": "Error", "errorMsg": str(e)}


# ============================================
# 개별 실행
# ============================================
if __name__ == "__main__":
    import uvicorn
    print(f"🚀 [테이블명] API 서버 시작")
    print(f"   서버 주소: http://{ipAddress}:{port}")
    print(f"   Swagger UI: http://{ipAddress}:{port}/docs")
    uvicorn.run(app, host=ipAddress, port=port)