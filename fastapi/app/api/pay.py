from fastapi import APIRouter

# 라우터 생성
router = APIRouter()


@router.get("/")
async def get_pay():
    """
    select pay_id,reserve_seq,store_seq,menu_seq,option_seq,pay_quantitiy,pay_amount,created_at
    from pay
    """
    return {
        "message": "This is an example endpoint",
        "status": "success"
    }
 

@router.get("/{id}")
async def get_pay_by_id(id: int):
    
    
    """
    select pay_id,reserve_seq,store_seq,menu_seq,option_seq,pay_quantitiy,pay_amount,created_at
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
