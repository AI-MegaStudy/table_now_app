# WeatherService 사용 시나리오

**작성일**: 2026-01-18  
**수정일**: 2026-01-21 (weather 테이블 제거 마이그레이션)  
**작성자**: AI Assistant  
**설명**: `WeatherService` 클래스의 각 메서드 사용 시나리오 및 선택 가이드

---

## 개요

`WeatherService`는 OpenWeatherMap API를 사용하여 날씨 데이터를 가져오는 서비스 클래스입니다.  

> ⚠️ **중요 변경사항 (2026-01-21)**  
> weather 테이블이 삭제되었습니다. 날씨 정보는 더 이상 DB에 저장하지 않고, OpenWeatherMap API를 통해 **실시간으로 조회**합니다.

---

## 메서드 목록

1. **`fetch_daily_forecast()`** - 8일치 예보 가져오기
2. **`fetch_single_day_weather()`** - 하루치 날씨만 가져오기

---

## 1. `fetch_daily_forecast()` - 8일치 예보 가져오기

### 목적
- OpenWeatherMap API에서 **최대 8일치 예보**를 가져오기
- `start_date` 지정 시 해당 날짜부터 남은 날짜만 반환

### 사용 시나리오

**✅ 사용해야 하는 경우**
- 8일치 예보가 필요할 때
- 특정 날짜부터 남은 날짜의 날씨가 필요할 때
- 예약 화면에서 날짜별 날씨를 보여줄 때
- 클라이언트에서 날씨를 조회할 때 (주 사용 케이스)

**❌ 사용하지 말아야 하는 경우**
- 하루치 날씨만 필요할 때 → `fetch_single_day_weather()` 사용

### 파라미터
```python
lat: str = DEFAULT_LAT              # 위도 (기본값: 서울)
lon: str = DEFAULT_LON              # 경도 (기본값: 서울)
start_date: Optional[datetime] = None  # 시작 날짜 (None이면 오늘 포함 8일치 모두)
```

### 반환값
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

### 동작 방식
- `start_date`가 None이면: 오늘 포함 8일치 모두 반환
- `start_date`가 있으면: 해당 날짜부터 남은 날짜만 반환
  - 예: 오늘+3일 지정 → 오늘+3일부터 5일치만 반환 (총 8일 중 남은 5일)

### 날짜 제한
- **과거 날짜 불가**: 오늘 이전 날짜는 조회 불가
- **최대 8일까지만 가능**: 오늘 포함 최대 8일까지만 조회 가능
- 날짜 검증은 내부에서 수행됨

### 사용 예시
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

### 실제 사용처
- `GET /api/weather/direct` 엔드포인트에서 사용됨
- 클라이언트(`WeatherNotifier.fetchWeatherDirect`)에서 호출

---

## 2. `fetch_single_day_weather()` - 하루치 날씨만 가져오기

### 목적
- OpenWeatherMap API에서 **특정 날짜의 날씨 데이터만** 가져오기
- 하루치만 반환

### 구현 방식
- 내부적으로 `fetch_daily_forecast()`를 호출하여 해당 날짜부터 가져온 후 첫 번째 항목만 반환
- `fetch_daily_forecast()`의 편의 래퍼 함수

### 사용 시나리오

**✅ 사용해야 하는 경우**
- 특정 날짜의 날씨만 필요할 때
- 날짜를 지정해서 하루만 조회할 때

**❌ 사용하지 말아야 하는 경우**
- 8일치 예보가 필요할 때 → `fetch_daily_forecast()` 사용

### 파라미터
```python
lat: str = DEFAULT_LAT              # 위도 (기본값: 서울)
lon: str = DEFAULT_LON              # 경도 (기본값: 서울)
target_date: Optional[datetime] = None  # 조회할 날짜 (None이면 오늘 날짜)
```

### 반환값
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

### 날짜 제한
- **과거 날짜 불가**: 오늘 이전 날짜는 조회 불가
- **최대 8일까지만 가능**: 오늘 포함 최대 8일까지만 조회 가능

### 사용 예시
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

### 실제 사용처
- `GET /api/weather/direct/single` 엔드포인트에서 사용됨

---

## 메서드 선택 가이드

### 시나리오별 선택

| 시나리오 | 사용할 메서드 | 이유 |
|---------|--------------|------|
| 8일치 예보 표시 | `fetch_daily_forecast()` | 최대 8일치 반환 |
| 특정 날짜부터 남은 날짜 조회 | `fetch_daily_forecast(start_date=...)` | 시작일 지정 가능 |
| 하루치 날씨만 표시 | `fetch_single_day_weather()` | 단일 날짜 반환 |

### 비교표

| 메서드 | 날짜 범위 | 반환 타입 | 주 사용처 |
|--------|----------|----------|----------|
| `fetch_daily_forecast()` | 최대 8일 | List[Dict] | 예보 목록 표시 |
| `fetch_single_day_weather()` | 하루만 | Dict | 단일 날씨 표시 |

---

## API 엔드포인트 매핑

### `GET /api/weather/direct`
- **사용 메서드**: `fetch_daily_forecast()`
- **용도**: 8일치 예보 또는 특정 날짜부터 조회
- **파라미터**: 
  - `lat` (float, 필수): 위도
  - `lon` (float, 필수): 경도
  - `start_date` (str, 선택): 시작 날짜 (YYYY-MM-DD 형식), 없으면 오늘 포함 8일치 모두 반환

### `GET /api/weather/direct/single`
- **사용 메서드**: `fetch_single_day_weather()`
- **용도**: 하루치 날씨만 조회
- **파라미터**: 
  - `lat` (float, 필수): 위도
  - `lon` (float, 필수): 경도
  - `target_date` (str, 선택): 조회할 날짜 (YYYY-MM-DD 형식), 없으면 오늘 날짜

---

## 주의사항

### 1. 날짜 범위 제한
- OpenWeatherMap API는 최대 8일까지만 예보 제공
- 과거 날짜는 조회 불가
- 모든 메서드에서 날짜 검증 수행

### 2. API 호출 제한
- OpenWeatherMap API는 호출 횟수 제한이 있음
- 불필요한 API 호출을 줄이기 위해 캐싱 고려

### 3. 좌표 직접 전달
- `lat`, `lon` 파라미터를 직접 전달
- store 테이블 조회 없이 바로 API 호출

---

## 삭제된 기능 (2026-01-21)

> ⚠️ 다음 기능들은 weather 테이블 제거로 인해 삭제되었습니다.

- ~~`save_weather_to_db()`~~ - 날씨 데이터 DB 저장 메서드 삭제
- ~~`GET /api/weather`~~ - DB 조회 엔드포인트 삭제
- ~~`GET /api/weather/{store_seq}/{weather_datetime}`~~ - DB 단일 조회 엔드포인트 삭제
- ~~`POST /api/weather`~~ - DB 생성 엔드포인트 삭제
- ~~`PUT /api/weather/{store_seq}/{weather_datetime}`~~ - DB 수정 엔드포인트 삭제
- ~~`DELETE /api/weather/{store_seq}/{weather_datetime}`~~ - DB 삭제 엔드포인트 삭제
- ~~`POST /api/weather/fetch-from-api`~~ - API→DB 저장 엔드포인트 삭제

---

## 요약

### 날씨 조회 방법
1. **8일치 예보** → `fetch_daily_forecast()` 또는 `GET /api/weather/direct`
2. **하루치 날씨** → `fetch_single_day_weather()` 또는 `GET /api/weather/direct/single`

### 핵심 변경사항
- **날씨 데이터는 더 이상 DB에 저장하지 않음**
- **OpenWeatherMap API를 통해 실시간으로 조회**
- **예약 시 필요한 날씨 정보는 API에서 직접 가져와서 표시**
