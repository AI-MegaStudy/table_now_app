
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



@router.get("/select_group_by_reserve/{reserve_seq}")
async def select_pays_group_by_reserve(reserve_seq: int):
    # if qry['reserve_seq'] == None:
    #     raise Exception("401 Unauthorized: 인증에 실패했습니다.")

    try:
        conn = connect_db()
        curs = conn.cursor()
        curs.execute("""
            select pp.*,m.menu_name ,s.store_description,o.option_name from 
   (
   select count(p.pay_id) as total_row_count,
                     p.reserve_seq,
                     p.store_seq,
                     p.menu_seq,
                     p.option_seq,
                     sum(p.pay_quantity) as total_quantity,
                     sum(p.pay_amount) as total_amount,
                     sum(p.pay_quantity*p.pay_amount) as total_pay
   from pay p
   where p.reserve_seq =%s
   group by p.reserve_seq, p.store_seq, p.menu_seq, p.option_seq
   order by p.reserve_seq desc
   ) as pp
   inner join menu m on pp.menu_seq=m.menu_seq
   inner join store s on pp.store_seq=s.store_seq
   left join `option` o on pp.option_seq = o.option_seq
    """,[reserve_seq])
        
        rows = curs.fetchall()
        print(len(rows))
        conn.close()
        
        results = []
        for row in rows:
            try:
                
                
                results.append({
                    'total_count': row[0],
                    'reserve_seq': row[1],
                    'store_seq': row[2],
                    'menu_seq': row[3],
                    'option_seq': row[4],
                    'total_quantity': row[5],
                    'total_pay': row[6],
                    'menu_name' : row[8],
                    'store_description': row[9],
                    'option_name': row[10]
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




@router.get("/select_by_reserve/{reserve_seq}")
async def select_pays_by_reserve(reserve_seq:int):
    # if qry['customer_seq'] == None or qry['reserve_seq'] == None:
    #     raise Exception("401 Unauthorized: 인증에 실패했습니다.")

    try:
        conn = connect_db()
        curs = conn.cursor()
        curs.execute("""
        select pay_id,reserve_seq,store_seq,menu_seq,option_seq,pay_quantity,pay_amount,created_at
        from pay where reserve_seq=%s
    """,[reserve_seq])
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


@router.post("/insert")
async def create_pay(items: list[dict]):
    conn = connect_db()
    try:
               
        curs = conn.cursor()
        for item in items:
            # print("insert into pay(reserve_seq,store_seq,menu_seq,option_seq,pay_quantity,pay_amount,created_at) values(?,?,?,?,?,?,current_timestamp)",[item['reserve_seq'],item['store_seq'],item['menu_seq'],1,item['pay_quantity'],item['pay_amount']])
            curs.execute("insert into pay(reserve_seq,store_seq,menu_seq,option_seq,pay_quantity,pay_amount,created_at) values(%s,%s,%s,%s,%s,%s,current_timestamp)",(item['reserve_seq'],item['store_seq'],item['menu_seq'],1,item['pay_quantity'],item['pay_amount']))
        conn.commit()

        return {"result": "OK"}
    except Exception as e:
        conn.rollback()
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}
    finally:
        conn.close()


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
