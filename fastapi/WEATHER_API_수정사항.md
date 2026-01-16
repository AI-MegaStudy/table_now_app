# Weather API 수정 사항

**작성일**: 2026-01-16  
**작성자**: 김택권  
**수정 파일**: 
- `fastapi/mysql/add_store_seq_to_weather.sql` (마이그레이션)
- `fastapi/app/utils/weather_service.py`
- `fastapi/app/api/weather.py`
- `docs/테이블_스펙시트_v_5_erd_02_반영.md`

---

## 📋 수정 개요

weather 테이블에 `store_seq` FK를 추가하여 각 식당별 날씨 정보를 저장할 수 있도록 변경했습니다. 또한 OpenWeatherMap API 호출 시 해당 식당의 좌표를 사용하여 오늘 날씨만 저장하도록 수정했습니다.

---

## 🔧 주요 수정 사항

### 1. 데이터베이스 스키마 변경

#### 1.1 weather 테이블 구조 변경

**변경 전:**
- PK: `weather_datetime` (단일 키)
- 컬럼: `weather_datetime`, `weather_type`, `weather_low`, `weather_high`

**변경 후:**
- PK: `(store_seq, weather_datetime)` (복합 키)
- 컬럼: `store_seq` (FK), `weather_datetime`, `weather_type`, `weather_low`, `weather_high`
- FK: `store_seq` → `store.store_seq`

#### 1.2 reserve 테이블 FK 변경

**변경 전:**
- FK: `weather_datetime` → `weather.weather_datetime`

**변경 후:**
- FK: `(store_seq, weather_datetime)` → `weather(store_seq, weather_datetime)` (복합 FK)

#### 1.3 마이그레이션 SQL

**파일**: `fastapi/mysql/add_store_seq_to_weather.sql`

```sql
-- 기존 날씨 데이터 삭제
DELETE FROM weather;

-- reserve 테이블의 FK 제약조건 삭제
ALTER TABLE `reserve` DROP FOREIGN KEY `fk_reserve_weather_datetime`;
ALTER TABLE `reserve` DROP INDEX `idx_reserve_weather_datetime`;

-- weather 테이블의 기존 PK 제약조건 삭제
ALTER TABLE `weather` DROP PRIMARY KEY;

-- store_seq 컬럼 추가
ALTER TABLE `weather` 
ADD COLUMN `store_seq` INT NOT NULL COMMENT '식당 번호' AFTER `weather_datetime`;

-- 인덱스 및 복합 PK 설정
ALTER TABLE `weather` 
ADD INDEX `idx_weather_store_seq` (`store_seq`),
ADD PRIMARY KEY (`store_seq`, `weather_datetime`);

-- FK 제약조건 추가
ALTER TABLE `weather` 
ADD CONSTRAINT `fk_weather_store_seq` 
FOREIGN KEY (`store_seq`) REFERENCES `store` (`store_seq`) 
ON UPDATE RESTRICT ON DELETE RESTRICT;

-- reserve 테이블의 복합 FK 재생성
ALTER TABLE `reserve` 
ADD CONSTRAINT `fk_reserve_weather` 
FOREIGN KEY (`store_seq`, `weather_datetime`) REFERENCES `weather` (`store_seq`, `weather_datetime`) 
ON UPDATE RESTRICT ON DELETE RESTRICT;
```

---

### 2. WeatherService 수정

#### 2.1 메서드 변경

**변경 전:**
- `fetch_daily_weather(lat, lon)` - 8일치 데이터 가져오기
- `save_weather_to_db(lat, lon, overwrite)` - 8일치 데이터 저장

**변경 후:**
- `fetch_today_weather(lat, lon)` - 오늘 날씨만 가져오기
- `save_weather_to_db(store_seq, overwrite)` - 오늘 날씨만 저장

#### 2.2 주요 변경 내용

1. **store_seq 기반 좌표 조회**
   ```python
   # store 테이블에서 store_lat, store_lng 조회
   curs.execute("""
       SELECT store_lat, store_lng FROM store WHERE store_seq = %s
   """, (store_seq,))
   ```

2. **오늘 날씨만 저장**
   - OpenWeatherMap API의 `daily[0]`만 사용 (오늘 날씨)
   - 8일치가 아닌 당일 하루치만 저장

3. **복합 키 UPSERT**
   ```python
   INSERT INTO weather (store_seq, weather_datetime, weather_type, weather_low, weather_high)
   VALUES (%s, %s, %s, %s, %s)
   ON DUPLICATE KEY UPDATE
       weather_type = VALUES(weather_type),
       weather_low = VALUES(weather_low),
       weather_high = VALUES(weather_high)
   ```

---

### 3. Weather API 엔드포인트 수정

#### 3.1 엔드포인트 변경

| 엔드포인트 | 변경 전 | 변경 후 |
|-----------|---------|---------|
| `GET /api/weather` | `?start_date=&end_date=` | `?store_seq=&start_date=&end_date=` |
| `GET /api/weather/{weather_datetime}` | `/{weather_datetime}` | `/{store_seq}/{weather_datetime}` |
| `POST /api/weather` | `weather_datetime, ...` | `store_seq, weather_datetime, ...` |
| `PUT /api/weather/{weather_datetime}` | `/{weather_datetime}` | `/{store_seq}/{weather_datetime}` |
| `DELETE /api/weather/{weather_datetime}` | `/{weather_datetime}` | `/{store_seq}/{weather_datetime}` |
| `POST /api/weather/fetch-from-api` | `lat, lon, overwrite` | `store_seq, overwrite` |

#### 3.2 주요 변경 내용

1. **모든 엔드포인트에 `store_seq` 파라미터 추가**
   - 조회, 삽입, 수정, 삭제 모두 `store_seq` 필요

2. **`fetch-from-api` 엔드포인트 변경**
   - `lat`, `lon` 파라미터 제거
   - `store_seq` 파라미터 추가 (필수)
   - 해당 식당의 `store_lat`, `store_lng`를 자동으로 사용

---

## 📝 사용 예시

### API 호출 예시

#### 1. 오늘 날씨 가져오기 및 저장
```bash
POST /api/weather/fetch-from-api
Content-Type: application/x-www-form-urlencoded

store_seq=1&overwrite=true
```

**응답:**
```json
{
  "result": "OK",
  "message": "날씨 데이터 저장 완료 (삽입)",
  "inserted": true,
  "errors": []
}
```

#### 2. 특정 식당의 날씨 데이터 조회
```bash
GET /api/weather?store_seq=1
```

**응답:**
```json
{
  "results": [
    {
      "store_seq": 1,
      "weather_datetime": "2026-01-16T00:00:00",
      "weather_type": "맑음",
      "weather_low": -5.0,
      "weather_high": 5.0,
      "icon_url": "https://openweathermap.org/img/wn/01d@2x.png"
    }
  ]
}
```

#### 3. 특정 식당의 특정 날짜 날씨 조회
```bash
GET /api/weather/1/2026-01-16
```

---

## ⚠️ 주의사항

### 1. 기존 데이터 삭제
- 마이그레이션 SQL 실행 시 기존 날씨 데이터가 모두 삭제됩니다.
- 필요시 백업 후 실행하세요.

### 2. reserve 테이블 FK 변경
- reserve 테이블의 FK가 복합 키로 변경되었습니다.
- 기존 reserve 데이터가 있다면 `store_seq`와 `weather_datetime`이 모두 일치해야 합니다.

### 3. API 호출 변경
- 모든 Weather API 호출에 `store_seq` 파라미터가 필요합니다.
- 기존 코드는 수정이 필요합니다.

---

## 🔄 마이그레이션 순서

1. **기존 데이터 백업** (필요시)
   ```sql
   CREATE TABLE weather_backup AS SELECT * FROM weather;
   ```

2. **마이그레이션 SQL 실행**
   ```bash
   mysql -u [user] -p [database] < fastapi/mysql/add_store_seq_to_weather.sql
   ```

3. **데이터 확인**
   ```sql
   SELECT * FROM weather;
   ```

4. **API 테스트**
   ```bash
   POST /api/weather/fetch-from-api
   store_seq=1
   ```

---

## 📌 관련 파일

- `fastapi/mysql/add_store_seq_to_weather.sql` - 마이그레이션 SQL
- `fastapi/app/utils/weather_service.py` - WeatherService 클래스
- `fastapi/app/api/weather.py` - Weather API 라우터
- `docs/테이블_스펙시트_v_5_erd_02_반영.md` - 테이블 스펙시트 문서

---

## 🔄 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-16 | 김택권 | weather 테이블에 store_seq FK 추가, 오늘 날씨만 저장하도록 변경 |
