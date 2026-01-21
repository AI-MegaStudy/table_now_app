# Weather 테이블 제거 마이그레이션 (옵션 A)

## 개요

이 마이그레이션은 `weather` 테이블을 완전히 제거하고, `reserve` 테이블에서 `weather_datetime` 컬럼을 삭제합니다.

날씨 정보는 더 이상 DB에 저장하지 않고, OpenWeatherMap API를 통해 실시간으로 조회합니다.

## 파일 목록

| 파일 | 설명 |
|------|------|
| `table_now_db_init_v2.sql` | 옵션 A 적용된 스키마 초기화 스크립트 |
| `table_now_db_seed_v2.sql` | 기존 데이터 마이그레이션된 시드 스크립트 |
| `README.md` | 마이그레이션 가이드 (본 문서) |

## 변경 사항

### 삭제된 항목

1. **`weather` 테이블** - 완전 삭제
2. **`reserve.weather_datetime` 컬럼** - 삭제
3. **`fk_reserve_weather` FK 제약조건** - 삭제

### 테이블 수 변경

- v1: 10개 테이블
- v2: **9개 테이블** (weather 제거)

## 적용 방법

### 신규 설치 (처음부터 시작)

```bash
# 1. 스키마 생성
mysql -u root -p < table_now_db_init_v2.sql

# 2. 시드 데이터 삽입
mysql -u root -p < table_now_db_seed_v2.sql
```

### 기존 DB 마이그레이션 (데이터 유지)

```sql
-- 1. 데이터 백업 (권장)
-- mysqldump -u root -p table_now_db > backup_before_migration.sql

-- 2. FK 제약조건 해제
SET FOREIGN_KEY_CHECKS = 0;

-- 3. reserve 테이블에서 weather FK 제거
ALTER TABLE `reserve` DROP FOREIGN KEY `fk_reserve_weather`;

-- 4. reserve 테이블에서 weather_datetime 컬럼 삭제
ALTER TABLE `reserve` DROP COLUMN `weather_datetime`;

-- 5. weather 테이블 삭제
DROP TABLE IF EXISTS `weather`;

-- 6. FK 제약조건 복원
SET FOREIGN_KEY_CHECKS = 1;
```

## 데이터 영향

| 테이블 | 영향 |
|--------|------|
| customer | ✅ 변경 없음 |
| store | ✅ 변경 없음 |
| store_table | ✅ 변경 없음 |
| menu | ✅ 변경 없음 |
| option | ✅ 변경 없음 |
| **weather** | ❌ **삭제됨** |
| **reserve** | 🟡 weather_datetime 컬럼 삭제 |
| pay | ✅ 변경 없음 |
| device_token | ✅ 변경 없음 |
| password_reset_auth | ✅ 변경 없음 |

## 추가 작업 필요

이 DB 마이그레이션 후 다음 코드 수정이 필요합니다:

### 백엔드 (FastAPI)

- [ ] `fastapi/app/api/weather.py` - DB 관련 엔드포인트 제거
- [ ] `fastapi/app/utils/weather_service.py` - `save_weather_to_db()` 제거
- [ ] `fastapi/app/api/reserve.py` - `weather_datetime` 파라미터 제거

### 프론트엔드 (Flutter)

- [ ] `lib/vm/weather_notifier.dart` - DB 관련 메서드 제거
- [ ] `lib/model/reserve.dart` - `weather_datetime` 필드 제거
- [ ] `lib/view/weather/weather_screen.dart` - 삭제

### 문서

- [ ] `docs/테이블_스펙시트_v_5_erd_02_반영.md` - weather 관련 내용 제거
- [ ] `docs/weather_service_사용_시나리오.md` - DB 저장 부분 제거
- [ ] `docs/화면별_워크플로우.md` - weather 테이블 언급 수정

## 롤백 방법

마이그레이션 전 백업한 SQL 파일로 복원:

```bash
mysql -u root -p < backup_before_migration.sql
```

또는 기존 v1 스크립트로 재설치:

```bash
mysql -u root -p < ../table_now_db_init_v1.sql
mysql -u root -p < ../table_now_db_current_data.sql
```

---

**작성일**: 2026-01-21  
**작성자**: 김택권
