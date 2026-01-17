# Table Now FastAPI 서버

Table Now 애플리케이션을 위한 FastAPI 백엔드 서버입니다.

## 프로젝트 구조

```
fastapi/
├── app/
│   ├── api/              # API 엔드포인트 라우터
│   │   ├── __init__.py
│   │   ├── customer.py  # 고객 API (회원가입, 로그인, 소셜 로그인 등)
│   │   ├── menu.py       # 메뉴 API
│   │   ├── option.py     # 옵션 API
│   │   ├── payment.py    # 결제 API
│   │   ├── reserve.py    # 예약 API
│   │   ├── store.py      # 식당 API
│   │   ├── store_table.py # 테이블 API
│   │   └── weather.py    # 날씨 API (OpenWeatherMap 연동)
│   ├── database/         # 데이터베이스 연결 설정
│   │   ├── __init__.py
│   │   └── connection.py
│   ├── utils/            # 유틸리티 함수
│   │   ├── email_service.py      # 이메일 서비스 (비밀번호 변경 인증)
│   │   ├── weather_mapping.py    # 날씨 타입 매핑
│   │   └── weather_service.py    # 날씨 데이터 처리 서비스
│   ├── main.py           # FastAPI 애플리케이션 진입점
│   └── main_gt.py        # (백업 파일)
├── mysql/                # 데이터베이스 스키마 및 시드 데이터
│   ├── README.md
│   ├── table_now_db_init_v1.sql  # 데이터베이스 초기화 스키마
│   ├── table_now_db_seed_v2.sql  # 시드 데이터
│   └── Workbench/        # MySQL Workbench 관련 파일
├── php_upload/            # PHP 이미지 업로드 관련 파일
├── requirements.txt       # Python 의존성
└── README.md             # 이 파일
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

## 현재 엔드포인트

### 기본 엔드포인트
- `GET /` - API 정보
- `GET /health` - 헬스 체크

### Customer API (`/api/customer`)
- `POST /api/customer/register` - 회원가입
- `POST /api/customer/login` - 로그인
- `POST /api/customer/social-login` - 소셜 로그인 (구글)
- `POST /api/customer/password-reset-request` - 비밀번호 변경 요청
- `POST /api/customer/password-reset-verify` - 비밀번호 변경 인증 코드 확인
- `POST /api/customer/password-reset` - 비밀번호 변경

### Weather API (`/api/weather`)
- `GET /api/weather` - 날씨 데이터 조회 (store_seq 필수)
- `POST /api/weather/fetch` - OpenWeatherMap API에서 날씨 데이터 가져오기
- `DELETE /api/weather/{store_seq}/{weather_datetime}` - 날씨 데이터 삭제

### Menu API (`/api/menu`)
- `GET /api/menu` - 메뉴 목록 조회
- `GET /api/menu/{menu_seq}` - 메뉴 상세 조회

### Option API (`/api/option`)
- `GET /api/option` - 옵션 목록 조회
- `GET /api/option/{store_seq}/{menu_seq}` - 특정 메뉴의 옵션 조회
- `POST /api/option/insert` - 옵션 추가

### Store API (`/api/store`)
- `GET /api/store` - 식당 목록 조회
- `GET /api/store/{store_seq}` - 식당 상세 조회

### Reserve API (`/api/reserve`)
- `GET /api/reserve` - 예약 목록 조회
- `GET /api/reserve/{reserve_seq}` - 예약 상세 조회
- `POST /api/reserve/insert` - 예약 생성

### StoreTable API (`/api/store_table`)
- `GET /api/store_table` - 테이블 목록 조회
- `GET /api/store_table/{store_seq}` - 특정 식당의 테이블 조회

### Payment API (`/api/payment`)
- `GET /api/payment` - 결제 목록 조회
- `GET /api/payment/{id}` - 결제 상세 조회
- `POST /api/payment/insert` - 결제 정보 추가

## 엔드포인트 추가 방법

### 1. 라우터 파일 생성

`app/api/` 폴더에 새로운 라우터 파일을 생성합니다.

예시: `app/api/users.py`

```python
from fastapi import APIRouter
from app.database.connection import connect_db

router = APIRouter()

@router.get("/")
async def get_users():
    conn = connect_db()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users")
        results = cursor.fetchall()
        return {"users": results}
    finally:
        conn.close()
```

### 2. main.py에 라우터 등록

`app/main.py` 파일에서 라우터를 import하고 등록합니다.

```python
from app.api import users

app.include_router(users.router, prefix="/api/users", tags=["users"])
```

### 3. 데이터베이스 사용

데이터베이스 연결이 필요한 경우:

1. `app/database/connection.py`에서 DB 설정 확인 (환경변수 사용)
2. 라우터에서 `connect_db()` 함수 사용

```python
from app.database.connection import connect_db

@router.get("/")
async def get_users():
    conn = connect_db()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users")
        results = cursor.fetchall()
        return {"users": results}
    finally:
        conn.close()
```

## 데이터베이스 설정

### 1. 환경변수 설정

프로젝트 루트에 `.env` 파일을 생성하고 다음 환경변수를 설정하세요:

```env
DB_HOST=localhost
DB_USER=your_user
DB_PASSWORD=your_password
DB_NAME=table_now_db
DB_PORT=3306
```

### 2. 데이터베이스 초기화

`mysql/` 폴더의 SQL 스크립트를 실행하여 데이터베이스를 초기화하세요:

```bash
# 데이터베이스 스키마 생성
mysql -u your_user -p < mysql/table_now_db_init_v1.sql

# 시드 데이터 삽입
mysql -u your_user -p < mysql/table_now_db_seed_v2.sql
```

자세한 내용은 `mysql/README.md`를 참고하세요.

### 3. 데이터베이스 연결

`app/database/connection.py` 파일에서 환경변수를 읽어 데이터베이스에 연결합니다.

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

## 주요 기능

### 날씨 API 연동
- OpenWeatherMap API를 사용하여 식당별 날씨 정보를 가져옵니다
- `app/utils/weather_service.py`에서 날씨 데이터 처리 로직을 관리합니다
- 날씨 데이터는 `weather` 테이블에 저장되며, 각 식당별로 관리됩니다

### 이메일 인증
- 비밀번호 변경 시 이메일 인증 코드를 발송합니다
- `app/utils/email_service.py`에서 이메일 발송 로직을 관리합니다
- 환경변수에 이메일 서버 설정이 필요합니다

### 소셜 로그인
- 구글 소셜 로그인을 지원합니다
- `customer` 테이블의 `provider` 및 `provider_subject` 컬럼을 사용합니다

## 참고사항

- API 문서는 자동으로 생성됩니다 (Swagger UI: `/docs`)
- 데이터베이스 연결은 `app/database/connection.py`에서 환경변수를 읽어 설정됩니다
- 각 API 라우터는 `app/main.py`에 등록되어 있습니다
- MySQL 8.0을 사용하며, UTF-8 인코딩(utf8mb4)을 사용합니다
