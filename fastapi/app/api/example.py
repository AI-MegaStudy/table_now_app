"""
예시 라우터 파일
새로운 엔드포인트를 추가할 때 이 파일을 참고하세요.

사용 방법:
1. 이 파일을 복사하여 새로운 라우터 파일 생성 (예: users.py, restaurants.py)
2. router 변수명과 함수명을 적절히 변경
3. main.py에서 라우터 등록
"""

from fastapi import APIRouter

# 라우터 생성
router = APIRouter()


@router.get("/")
async def get_example():
    """예시 GET 엔드포인트"""
    return {
        "message": "This is an example endpoint",
        "status": "success"
    }


@router.get("/{id}")
async def get_example_by_id(id: int):
    """예시 GET 엔드포인트 (ID로 조회)"""
    return {
        "id": id,
        "message": f"Example item with id {id}",
        "status": "success"
    }


@router.post("/")
async def create_example(data: dict):
    """예시 POST 엔드포인트"""
    return {
        "message": "Example item created",
        "data": data,
        "status": "success"
    }


@router.put("/{id}")
async def update_example(id: int, data: dict):
    """예시 PUT 엔드포인트"""
    return {
        "id": id,
        "message": f"Example item {id} updated",
        "data": data,
        "status": "success"
    }


@router.delete("/{id}")
async def delete_example(id: int):
    """예시 DELETE 엔드포인트"""
    return {
        "id": id,
        "message": f"Example item {id} deleted",
        "status": "success"
    }
