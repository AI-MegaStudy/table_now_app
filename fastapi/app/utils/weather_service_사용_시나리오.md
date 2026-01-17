# WeatherService 사용 시나리오

**작성일**: 2026-01-18  
**작성자**: AI Assistant  
**설명**: `WeatherService` 클래스의 각 메서드 사용 시나리오 및 선택 가이드

---

## 개요

`WeatherService`는 OpenWeatherMap API를 사용하여 날씨 데이터를 가져오는 서비스 클래스입니다.  
총 3개의 메서드가 있으며, 각각 다른 목적과 사용 시나리오를 가지고 있습니다.

---

## 메서드 목록

1. **`fetch_daily_forecast()`** - 8일치 예보 가져오기 (DB 저장 없이)
2. **`fetch_single_day_weather()`** - 하루치 날씨만 가져오기 (DB 저장 없이)
3. **`save_weather_to_db()`** - 날씨 데이터를 DB에 저장

---

## 1. 조회만 가능한 경우 (DB 저장 없이)

### 1-1. `fetch_daily_forecast()` - 8일치 예보 가져오기

#### 목적
- OpenWeatherMap API에서 **최대 8일치 예보**를 가져오기
- DB 저장 없이 메모리에서만 사용
- `start_date` 지정 시 해당 날짜부터 남은 날짜만 반환

#### 사용 시나리오

**✅ 사용해야 하는 경우**
- 8일치 예보가 필요할 때
- 특정 날짜부터 남은 날짜의 날씨가 필요할 때
- DB에 저장하지 않고 바로 화면에 표시할 때
- 예약 화면에서 날짜별 날씨를 보여줄 때
- **클라이언트에서 직접 날씨를 조회할 때** (주 사용 케이스)

**❌ 사용하지 말아야 하는 경우**
- 하루치 날씨만 필요할 때 → `fetch_single_day_weather()` 사용
- DB에 저장이 필요할 때 → `save_weather_to_db()` 사용
- DB에 저장된 데이터를 조회할 때 → DB 조회 API 사용

#### 파라미터
```python
lat: str = DEFAULT_LAT              # 위도 (기본값: 서울)
lon: str = DEFAULT_LON              # 경도 (기본값: 서울)
start_date: Optional[datetime] = None  # 시작 날짜 (None이면 오늘 포함 8일치 모두)
```

#### 반환값
```python
List[Dict]: [
    {
        "dt": int,
        "weather_datetime": datetime,
        "weather_type": str,
        "weather_type_en": str,
        "weather_low": float,
        "weather_high": float,
        "icon_code": str,
        "icon_url": str
    },
    ...  # 최대 8개
]
```

#### 동작 방식
- `start_date`가 None이면: 오늘 포함 8일치 모두 반환
- `start_date`가 있으면: 해당 날짜부터 남은 날짜만 반환
  - 예: 오늘+3일 지정 → 오늘+3일부터 5일치만 반환 (총 8일 중 남은 5일)

#### 날짜 제한
- **과거 날짜 불가**: 오늘 이전 날짜는 조회 불가
- **최대 8일까지만 가능**: 오늘 포함 최대 8일까지만 조회 가능
- 날짜 검증은 내부에서 수행됨

#### 사용 예시
```python
weather_service = WeatherService()

# 8일치 예보 모두 가져오기
forecast_list = weather_service.fetch_daily_forecast(
    lat="37.5665",
    lon="126.9780"
)

# 특정 날짜부터 남은 날짜만 가져오기
from datetime import datetime, timedelta
start_date = datetime.now() + timedelta(days=3)
forecast_list = weather_service.fetch_daily_forecast(
    lat="37.5665",
    lon="126.9780",
    start_date=start_date
)
```

#### 실제 사용처
- `GET /api/weather/direct` 엔드포인트에서 사용됨
- 클라이언트(`WeatherNotifier.fetchWeatherDirect`)에서 호출

---

### 1-2. `fetch_single_day_weather()` - 하루치 날씨만 가져오기

#### 목적
- OpenWeatherMap API에서 **특정 날짜의 날씨 데이터만** 가져오기
- DB 저장 없이 메모리에서만 사용
- 하루치만 반환

#### 구현 방식
- 내부적으로 `fetch_daily_forecast()`를 호출하여 해당 날짜부터 가져온 후 첫 번째 항목만 반환
- `fetch_daily_forecast()`의 편의 래퍼 함수

#### 사용 시나리오

**✅ 사용해야 하는 경우**
- 특정 날짜의 날씨만 필요할 때
- DB에 저장하지 않고 바로 화면에 표시할 때
- 날짜를 지정해서 하루만 조회할 때

**❌ 사용하지 말아야 하는 경우**
- 8일치 예보가 필요할 때 → `fetch_daily_forecast()` 사용
- DB에 저장이 필요할 때 → `save_weather_to_db()` 사용
- DB에 저장된 데이터를 조회할 때 → DB 조회 API 사용

#### 파라미터
```python
lat: str = DEFAULT_LAT              # 위도 (기본값: 서울)
lon: str = DEFAULT_LON              # 경도 (기본값: 서울)
target_date: Optional[datetime] = None  # 조회할 날짜 (None이면 오늘 날짜)
```

#### 반환값
```python
Dict: {
    "dt": int,
    "weather_datetime": datetime,
    "weather_type": str,
    "weather_type_en": str,
    "weather_low": float,
    "weather_high": float,
    "icon_code": str,
    "icon_url": str
}
```

#### 날짜 제한
- **과거 날짜 불가**: 오늘 이전 날짜는 조회 불가
- **최대 8일까지만 가능**: 오늘 포함 최대 8일까지만 조회 가능

#### 사용 예시
```python
weather_service = WeatherService()

# 오늘 날씨만 가져오기
today_weather = weather_service.fetch_single_day_weather(
    lat="37.5665",
    lon="126.9780"
)

# 특정 날짜의 날씨만 가져오기
from datetime import datetime
target_date = datetime(2026, 1, 25)
weather = weather_service.fetch_single_day_weather(
    lat="37.5665",
    lon="126.9780",
    target_date=target_date
)
```

#### 실제 사용처
- `GET /api/weather/direct/single` 엔드포인트에서 사용됨

---

## 2. 날씨 데이터를 DB에 저장하는 경우

### 2-1. `save_weather_to_db()` - 날씨 데이터를 DB에 저장

#### 목적
- OpenWeatherMap API에서 날씨 데이터를 가져와서 **데이터베이스에 저장**
- 하루치만 저장
- UPSERT 패턴 사용 (있으면 UPDATE, 없으면 INSERT)

#### 사용 시나리오

**✅ 사용해야 하는 경우**
- 날씨 데이터를 DB에 저장해야 할 때
- 스케줄러/크론잡에서 주기적으로 날씨 데이터를 갱신할 때
- 예약 시스템에서 DB에 저장된 날씨 데이터를 참조할 때
- **서버 측에서 날씨 데이터를 관리할 때**

**❌ 사용하지 말아야 하는 경우**
- DB 저장 없이 화면에만 표시할 때 → `fetch_daily_forecast()` 또는 `fetch_single_day_weather()` 사용
- 8일치 예보가 필요할 때 → `fetch_daily_forecast()` 사용
- 클라이언트에서 직접 조회할 때 → `fetch_daily_forecast()` 또는 `fetch_single_day_weather()` 사용

#### 파라미터
```python
store_seq: int                    # 식당 번호 (store 테이블의 store_seq)
target_date: Optional[datetime] = None  # 저장할 날짜 (None이면 오늘 날짜)
overwrite: bool = True            # 기존 데이터 덮어쓰기 여부 (기본값: True)
```

#### 동작 방식
1. `store` 테이블에서 `store_seq`로 `store_lat`, `store_lng` 조회
2. `fetch_daily_forecast()`를 호출하여 해당 날짜의 날씨 데이터 가져오기
3. `weather` 테이블에 저장 (UPSERT 패턴)
   - 이미 있으면 UPDATE
   - 없으면 INSERT

#### 날짜 제한
- **과거 날짜 불가**: 오늘 이전 날짜는 저장 불가
- **최대 8일까지만 가능**: 오늘 포함 최대 8일까지만 저장 가능
- 날짜 검증은 `fetch_daily_forecast()` 내부에서 수행됨

#### 반환값
```python
Dict: {
    "success": bool,      # 성공 여부
    "inserted": bool,     # 삽입 여부 (True면 INSERT, False면 UPDATE)
    "message": str,       # 결과 메시지
    "errors": List        # 에러 리스트
}
```

#### 사용 예시
```python
weather_service = WeatherService()

# 오늘 날씨를 DB에 저장
result = weather_service.save_weather_to_db(store_seq=1)

# 특정 날짜의 날씨를 DB에 저장
from datetime import datetime
target_date = datetime(2026, 1, 25)
result = weather_service.save_weather_to_db(
    store_seq=1,
    target_date=target_date
)

if result["success"]:
    print(f"저장 완료: {result['message']}")
    print(f"삽입 여부: {result['inserted']}")
else:
    print(f"저장 실패: {result['message']}")
```

#### 실제 사용처
- `POST /api/weather/fetch-from-api` 엔드포인트에서 사용됨
- 스케줄러/크론잡에서 주기적으로 호출 가능

---

## 3. DB에서 날씨 데이터 조회하는 경우

### 3-1. DB 조회 API 엔드포인트

#### `GET /api/weather`
- **용도**: DB에 저장된 날씨 데이터 조회
- **파라미터**: `store_seq`, `start_date`, `end_date` (선택)
- **반환**: DB에 저장된 날씨 데이터 리스트

#### `GET /api/weather/{store_seq}/{weather_datetime}`
- **용도**: 특정 식당의 특정 날짜 날씨 데이터 조회
- **파라미터**: `store_seq`, `weather_datetime`
- **반환**: DB에 저장된 날씨 데이터 (하루치)

#### 사용 시나리오

**✅ 사용해야 하는 경우**
- DB에 저장된 날씨 데이터를 조회할 때
- 예약 시스템에서 저장된 날씨 데이터를 참조할 때
- 과거 날씨 데이터가 필요할 때 (DB에 저장된 경우)

**❌ 사용하지 말아야 하는 경우**
- 실시간 날씨 데이터가 필요할 때 → `fetch_daily_forecast()` 또는 `fetch_single_day_weather()` 사용
- DB에 저장되지 않은 날짜의 날씨가 필요할 때 → OpenWeatherMap API 직접 조회

---

## 메서드 선택 가이드

### 시나리오별 선택

| 시나리오 | 사용할 메서드 | 이유 |
|---------|--------------|------|
| 클라이언트에서 8일치 예보 표시 | `fetch_daily_forecast()` | DB 저장 없이 바로 표시 |
| 클라이언트에서 특정 날짜부터 남은 날짜 조회 | `fetch_daily_forecast(start_date=...)` | DB 저장 없이 바로 표시 |
| 클라이언트에서 하루치 날씨만 표시 | `fetch_single_day_weather()` | DB 저장 없이 바로 표시 |
| 서버에서 날씨를 DB에 저장 | `save_weather_to_db()` | DB 저장 필요 |
| 서버에서 특정 날짜의 날씨를 DB에 저장 | `save_weather_to_db(target_date=...)` | 날짜 지정 저장 필요 |
| 스케줄러에서 주기적 날씨 갱신 | `save_weather_to_db()` | DB 저장 필요 |
| DB에 저장된 날씨 데이터 조회 | `GET /api/weather` | DB 조회 API 사용 |

### 비교표

| 메서드 | DB 저장 | 날짜 범위 | store 테이블 조회 | 반환 타입 | 주 사용처 |
|--------|---------|----------|------------------|----------|----------|
| `fetch_daily_forecast()` | ❌ | 최대 8일 | ❌ | List[Dict] | 클라이언트 직접 조회 |
| `fetch_single_day_weather()` | ❌ | 하루만 (최대 8일 이내) | ❌ | Dict | 클라이언트 직접 조회 |
| `save_weather_to_db()` | ✅ | 하루만 (최대 8일 이내) | ✅ | Dict | 서버 측 DB 저장 |
| `GET /api/weather` | ❌ | 제한 없음 (DB 범위) | ❌ | List[Dict] | DB 조회 |

---

## 주의사항

### 1. 날짜 범위 제한
- OpenWeatherMap API는 최대 8일까지만 예보 제공
- 과거 날짜는 조회 불가
- 모든 메서드에서 날짜 검증 수행

### 2. DB 저장 전략
- 날씨 데이터는 필요할 때만 DB에 저장
- 8일치 예보는 DB에 저장하지 않고 API에서 직접 조회
- 예약 시스템에서는 DB에 저장된 날씨 데이터를 참조

### 3. store 테이블 의존성
- `save_weather_to_db()`는 `store` 테이블 조회 필요
- `fetch_daily_forecast()`와 `fetch_single_day_weather()`는 좌표만 필요 (완전 분리)

### 4. API 호출 제한
- OpenWeatherMap API는 호출 횟수 제한이 있음
- 불필요한 API 호출을 줄이기 위해 적절한 메서드 선택 필요

---

## 실제 API 엔드포인트 매핑

### 조회 전용 (DB 저장 없이)

#### `GET /api/weather/direct`
- **사용 메서드**: `fetch_daily_forecast()`
- **용도**: 클라이언트에서 직접 날씨 조회 (8일치 또는 특정 날짜부터)
- **DB 저장**: ❌
- **파라미터**: `lat`, `lon`, `start_date` (선택)

#### `GET /api/weather/direct/single`
- **사용 메서드**: `fetch_single_day_weather()`
- **용도**: 클라이언트에서 직접 날씨 조회 (하루치만)
- **DB 저장**: ❌
- **파라미터**: `lat`, `lon`, `target_date` (선택)

### DB 저장

#### `POST /api/weather/fetch-from-api`
- **사용 메서드**: `save_weather_to_db()`
- **용도**: 서버에서 날씨를 DB에 저장
- **DB 저장**: ✅
- **파라미터**: `store_seq`, `target_date` (선택), `overwrite`

### DB 조회

#### `GET /api/weather`
- **용도**: DB에 저장된 날씨 데이터 조회
- **DB 저장**: ❌
- **파라미터**: `store_seq`, `start_date`, `end_date` (선택)

#### `GET /api/weather/{store_seq}/{weather_datetime}`
- **용도**: 특정 식당의 특정 날짜 날씨 데이터 조회
- **DB 저장**: ❌
- **파라미터**: `store_seq`, `weather_datetime`

---

## 요약

### 조회만 가능한 경우 (DB 저장 없이)
1. **8일치 예보** → `fetch_daily_forecast()` 사용
2. **하루치 날씨** → `fetch_single_day_weather()` 사용

### 날씨 데이터를 DB에 저장하는 경우
1. **날씨 저장** → `save_weather_to_db()` 사용
   - 오늘 날씨: `save_weather_to_db(store_seq=1)`
   - 특정 날짜: `save_weather_to_db(store_seq=1, target_date=날짜)`

### DB에서 날씨 데이터 조회하는 경우
1. **DB 조회** → `GET /api/weather` 엔드포인트 사용
   - 전체 조회: `GET /api/weather?store_seq=1`
   - 특정 날짜: `GET /api/weather/1/2026-01-25`
