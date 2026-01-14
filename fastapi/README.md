# Table Now FastAPI 서버

Table Now 애플리케이션을 위한 FastAPI 백엔드 서버입니다.

## 프로젝트 구조

```
fastapi/
├── app/
│   ├── api/              # API 엔드포인트 라우터
│   │   ├── __init__.py
│   │   └── example.py    # 예시 라우터 (참고용)
│   ├── database/         # 데이터베이스 연결 설정
│   │   ├── __init__.py
│   │   └── connection.py
│   └── main.py          # FastAPI 애플리케이션 진입점
├── requirements.txt      # Python 의존성
└── README.md            # 이 파일
```

## 설치 및 실행

### 1. 가상 환경 생성 및 활성화

```bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
```

### 2. 의존성 설치

```bash
pip install -r requirements.txt
```

### 3. 서버 실행

```bash
# 개발 모드
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 또는 main.py 직접 실행
python app/main.py
```

### 4. API 문서 확인

서버 실행 후 다음 URL에서 API 문서를 확인할 수 있습니다:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## 엔드포인트 추가 방법

### 1. 라우터 파일 생성

`app/api/` 폴더에 새로운 라우터 파일을 생성합니다.

예시: `app/api/users.py`

```python
from fastapi import APIRouter

router = APIRouter()

@router.get("/")
async def get_users():
    return {"message": "Get all users"}

@router.get("/{user_id}")
async def get_user(user_id: int):
    return {"user_id": user_id, "message": "Get user by id"}
```

### 2. main.py에 라우터 등록

`app/main.py` 파일에서 라우터를 import하고 등록합니다.

```python
from app.api import users

app.include_router(users.router, prefix="/api/users", tags=["users"])
```

### 3. 데이터베이스 사용 (선택사항)

데이터베이스 연결이 필요한 경우:

1. `app/database/connection.py`에서 DB 설정 수정
2. 라우터에서 `connect_db()` 함수 사용

```python
from app.database.connection import connect_db

@router.get("/")
async def get_users():
    conn = connect_db()
    try:
        # 데이터베이스 쿼리 실행
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users")
        results = cursor.fetchall()
        return {"users": results}
    finally:
        conn.close()
```

## 현재 엔드포인트

- `GET /` - API 정보
- `GET /health` - 헬스 체크

## 데이터베이스 설정

`app/database/connection.py` 파일에서 데이터베이스 연결 정보를 설정하세요.

```python
DB_CONFIG = {
    'host': 'your_host',
    'user': 'your_user',
    'password': 'your_password',
    'database': 'table_now_db',
    'charset': 'utf8mb4',
    'port': 3306
}
```

## CORS 설정

현재 모든 origin을 허용하도록 설정되어 있습니다. 프로덕션 환경에서는 특정 도메인으로 제한하세요.

`app/main.py`에서 CORS 설정을 수정할 수 있습니다:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "https://yourdomain.com"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## 참고사항

- 예시 라우터는 `app/api/example.py`를 참고하세요
- 데이터베이스 연결은 필요할 때만 활성화하세요
- API 문서는 자동으로 생성됩니다 (Swagger UI)
