
from fastapi import APIRouter, Form
from pydantic import BaseModel
from typing import Optional
from datetime import datetime, timedelta
import uuid
import random
from ..database.connection import connect_db

# 라우터 생성
router = APIRouter()

class Payment(BaseModel):
    pay_id: Optional[int] = None
    reserve_seq: int
    store_seq: int
    menu_seq: int
    option_seq: int
    pay_quantity: int
    pay_amount: int
    created_at: datetime


@router.get("/")
async def select_pays():


    try:
        conn = connect_db()
        curs = conn.cursor()
        curs.execute("""
        select pay_id,reserve_seq,store_seq,menu_seq,option_seq,pay_quantity,pay_amount,created_at
        from pay
    """)
        rows = curs.fetchall()
        conn.close()
        
        results = []
        for row in rows:
            try:
                created_at = None
                if row[7]:
                    if hasattr(row[7], 'isoformat'):
                        created_at = row[7].isoformat()
                    else:
                        created_at = str(row[7])
                
                results.append({
                    'pay_id': row[0],
                    'reserve_seq': row[1],
                    'store_seq': row[2],
                    'menu_seq': row[3],
                    'option_seq': row[4],
                    'pay_quantity': row[5],
                    'pay_amount': row[6],
                    'created_at' : created_at
                })
            except Exception as e:
                print(f"Error processing row: {e}, row: {row}")
                continue
        
        return {"results": results}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}



@router.get("/{id}")
async def get_pay_by_id(id: int):
    
    
    """
    select pay_id,reserve_seq,store_seq,menu_seq,option_seq,pay_quantity,pay_amount,created_at
    from pay where pay.pay_id=?
    [id]
    """
    return {
        "id": id,
        "message": f"Example item with id {id}",
        "status": "success"
    }


@router.post("/")
async def create_pay(data: dict):
    """예시 POST 엔드포인트"""
    return {
        "message": "Example item created",
        "data": data,
        "status": "success"
    }


@router.put("/{id}")
async def update_pay(id: int, data: dict):
    """예시 PUT 엔드포인트"""
    return {
        "id": id,
        "message": f"Example item {id} updated",
        "data": data,
        "status": "success"
    }


@router.delete("/{id}")
async def delete_pay(id: int):
    """예시 DELETE 엔드포인트"""
    return {
        "id": id,
        "message": f"Example item {id} deleted",
        "status": "success"
    }
