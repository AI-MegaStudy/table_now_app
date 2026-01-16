# StoreTable API 수정 사항

**작성일**: 2026-01-16  
**작성자**: 이예은  
**수정 파일**: `fastapi/app/api/store_table.py`, `fastapi/app/main.py`

---

## 📋 수정 개요

`store_table.py` 파일에서 발견된 여러 문제점을 수정하고, `main.py`의 import 구조를 개선했습니다.

---

## 🔧 주요 수정 사항

### 1. `store_table.py` 파일 구조 개선

#### 1.1 중복 코드 제거
- **문제**: 파일 전체가 중복되어 있었음 (515줄 → 248줄로 정리)
- **수정**: 중복된 코드 블록 제거

#### 1.2 Import 경로 수정
- **문제**: `from database.connection import connect_db` (절대 경로)
- **수정**: `from ..database.connection import connect_db` (상대 경로)
- **이유**: 다른 API 파일들(`store.py`, `reserve.py`, `menu.py` 등)과 일관성 유지

#### 1.3 FastAPI 앱 선언 변경
- **문제**: `app = FastAPI()` 사용
- **수정**: `router = APIRouter()` 사용
- **이유**: `main.py`에서 라우터로 등록하기 위해 필요

#### 1.4 테이블 이름 수정
- **문제**: SQL 쿼리에서 `StoreTable` (대문자) 사용
- **수정**: `store_table` (소문자)로 변경
- **이유**: 데이터베이스 스키마와 일치 (`table_now_db_init_v1.sql` 기준)

**수정된 SQL 쿼리:**
```sql
-- 수정 전
FROM StoreTable
INSERT INTO StoreTable
UPDATE StoreTable
DELETE FROM StoreTable

-- 수정 후
FROM store_table
INSERT INTO store_table
UPDATE store_table
DELETE FROM store_table
```

#### 1.5 타입 수정 (스키마와 일치)

**`store_table_name` 타입:**
- **문제**: `Optional[str]` (문자열)
- **수정**: `Optional[int]` (정수)
- **이유**: 스키마에서 `INT NOT NULL`로 정의됨
- **주의**: 테이블 이름이 INT인 것은 비정상적일 수 있으나, 현재 스키마 기준으로 수정

**`store_table_inuse` 타입:**
- **문제**: `Optional[str]` (문자열)
- **수정**: `Optional[bool]` (불린)
- **이유**: 스키마에서 `BOOLEAN NOT NULL`로 정의됨

**수정된 모델:**
```python
class StoreTable(BaseModel):
    store_table_seq: Optional[int] = None
    store_seq: Optional[int] = None
    store_table_name: Optional[int] = None  # INT 타입
    store_table_capacity: Optional[int] = None
    store_table_inuse: Optional[bool] = None  # BOOLEAN 타입
    created_at: Optional[str] = None
```

#### 1.6 불필요한 파라미터 제거

**`insert_one` 함수:**
- **문제**: `created_at: str = Form(...)` 파라미터 존재
- **수정**: 파라미터 제거 (SQL에서 `NOW()` 사용)
- **이유**: `created_at`은 데이터베이스에서 자동 생성

**`update_one` 함수:**
- **문제**: `created_at: Optional[str] = Form(None)` 파라미터 존재
- **수정**: 파라미터 제거
- **이유**: 일반적으로 `created_at`은 수정하지 않음

#### 1.7 사용하지 않는 Import 제거
- **문제**: `UploadFile`, `File`, `Response` import되었으나 사용되지 않음
- **수정**: 주석 처리 (이미지 기능 구현 시 사용 예정)

---

### 2. `main.py` 파일 개선

#### 2.1 Import 통합
- **문제**: 각 라우터를 개별적으로 import
- **수정**: 한 줄로 통합

**수정 전:**
```python
from app.api import customer
app.include_router(customer.router, ...)

from app.api import weather
app.include_router(weather.router, ...)

from app.api import menu
app.include_router(menu.router, ...)
# ... (반복)
```

**수정 후:**
```python
from app.api import customer, weather, menu, option, store, reserve, store_table

app.include_router(customer.router, prefix="/api/customer", tags=["customer"])
app.include_router(weather.router, prefix="/api/weather", tags=["weather"])
# ... (라우터 등록만 유지)
```

- **효과**: 코드 가독성 향상, Linter 오류 해결

---

## ✅ 테스트 결과

모든 API 엔드포인트가 정상 동작함을 확인했습니다.

### 테스트 항목
1. ✅ **전체 조회** (`GET /api/store_table/select_StoreTables`)
   - 36개 레코드 조회 성공

2. ✅ **단일 조회** (`GET /api/store_table/select_StoreTable/{store_table_seq}`)
   - store_table_seq=1 조회 성공

3. ✅ **추가** (`POST /api/store_table/insert_StoreTable`)
   - 새 레코드 추가 성공 (id=37)

4. ✅ **수정** (`POST /api/store_table/update_StoreTable`)
   - 레코드 수정 성공

5. ✅ **삭제** (`DELETE /api/store_table/delete_StoreTable/{store_table_seq}`)
   - 레코드 삭제 성공

---

## 📝 참고 사항

### 스키마 정보
```sql
CREATE TABLE `store_table` (
    `store_table_seq` INT NOT NULL AUTO_INCREMENT COMMENT '테이블 번호',
    `store_seq` INT NOT NULL COMMENT '식당 번호',
    `store_table_name` INT NOT NULL COMMENT '테이블 이름(라벨)',
    `store_table_capacity` INT NOT NULL COMMENT '수용 인원',
    `store_table_inuse` BOOLEAN NOT NULL COMMENT '사용 중 여부',
    `created_at` DATETIME NOT NULL COMMENT '생성 일자',
    PRIMARY KEY (`store_table_seq`),
    KEY `idx_store_table_store_seq` (`store_seq`),
    CONSTRAINT `fk_store_table_store_seq` FOREIGN KEY (`store_seq`) 
        REFERENCES `store` (`store_seq`) ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
```

### 주의사항
- `store_table_name`이 `INT` 타입인 것은 비정상적일 수 있습니다. 일반적으로 테이블 이름은 문자열(`VARCHAR`)이어야 합니다.
- 향후 스키마 변경 시 코드도 함께 수정이 필요할 수 있습니다.

---

## 📌 관련 파일

- `fastapi/app/api/store_table.py` - StoreTable API 라우터
- `fastapi/app/main.py` - FastAPI 메인 애플리케이션
- `fastapi/mysql/table_now_db_init_v1.sql` - 데이터베이스 스키마

---

## 🔄 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-16 | 이예은 | APIRouter로 변경, 중복 코드 제거, import 수정 |
| 2026-01-16 | 이예은 | 테이블 이름 수정, 타입 수정, 불필요한 파라미터 제거 |
