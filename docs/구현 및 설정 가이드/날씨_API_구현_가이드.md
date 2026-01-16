# 날씨 API 구현 가이드

**작성일**: 2026-01-15  
**작성자**: 김택권  
**설명**: OpenWeatherMap API를 사용한 날씨 데이터 수집 및 저장 가이드

---

## 개요

Table Now 앱에서 사용할 날씨 데이터를 OpenWeatherMap OneCall API에서 가져와서 데이터베이스에 저장하는 시스템입니다.

### 주요 기능

1. **OpenWeatherMap OneCall API 연동**: 일별 날씨 예보 데이터 가져오기
2. **날씨 상태 매핑**: 영문 날씨 상태를 한글로 변환
3. **아이콘 URL 생성**: OpenWeatherMap에서 제공하는 날씨 아이콘 URL 생성
4. **데이터베이스 저장**: weather 테이블에 날씨 데이터 저장

---

## 파일 구조

```
fastapi/app/
├── utils/
│   ├── weather_mapping.py    # 날씨 상태 매핑 테이블
│   └── weather_service.py     # OpenWeatherMap API 서비스
└── api/
    └── weather.py            # Weather API 라우터
```

---

## 1. 날씨 상태 매핑 테이블

### 파일: `fastapi/app/utils/weather_mapping.py`

OpenWeatherMap API의 `weather.main` 값을 한글로 변환하는 매핑 테이블입니다.

### 지원하는 날씨 상태

| 영문 (weather.main) | 한글 | 아이콘 코드 (기본값) |
|---------------------|------|---------------------|
| Clear | 맑음 | 01d |
| Clouds | 흐림 | 02d |
| Rain | 비 | 10d |
| Drizzle | 이슬비 | 09d |
| Thunderstorm | 천둥번개 | 11d |
| Snow | 눈 | 13d |
| Mist | 안개 | 50d |
| Fog | 짙은 안개 | 50d |
| Haze | 연무 | 50d |
| Dust | 먼지 | 50d |
| Sand | 모래 | 50d |
| Ash | 화산재 | 50d |
| Squall | 돌풍 | 11d |
| Tornado | 토네이도 | 11d |

### 주요 함수

#### `get_weather_type_korean(weather_main: str) -> str`
영문 날씨 상태를 한글로 변환합니다.

```python
from app.utils.weather_mapping import get_weather_type_korean

korean = get_weather_type_korean("Clear")  # "맑음"
```

#### `get_weather_icon_url(icon_code: str, size: str = "2x") -> str`
OpenWeatherMap 아이콘 URL을 생성합니다.

```python
from app.utils.weather_mapping import get_weather_icon_url

icon_url = get_weather_icon_url("01d", "2x")
# "http://openweathermap.org/img/wn/01d@2x.png"
```

**아이콘 크기 옵션:**
- `1x`: 작은 크기
- `2x`: 중간 크기 (기본값)
- `4x`: 큰 크기

---

## 2. OpenWeatherMap API 서비스

### 파일: `fastapi/app/utils/weather_service.py`

OpenWeatherMap OneCall API를 호출하여 날씨 데이터를 가져오고 데이터베이스에 저장하는 서비스입니다.

### 환경 변수 설정

`.env` 파일에 OpenWeatherMap API 키를 설정해야 합니다:

```env
OPENWEATHER_API_KEY=your_api_key_here
```

### 주요 클래스 및 메서드

#### `WeatherService`

```python
from app.utils.weather_service import WeatherService

# 초기화
weather_service = WeatherService()

# 또는 API 키 직접 지정
weather_service = WeatherService(api_key="your_api_key")
```

#### `fetch_daily_weather(lat: str, lon: str) -> List[Dict]`

OpenWeatherMap API에서 일별 날씨 데이터를 가져옵니다.

**파라미터:**
- `lat`: 위도 (기본값: 서울 37.5665)
- `lon`: 경도 (기본값: 서울 126.9780)

**반환값:**
```python
[
    {
        "dt": 1705276800,  # Unix timestamp
        "weather_datetime": datetime(2026, 1, 15, 0, 0, 0),
        "weather_type": "맑음",
        "weather_type_en": "Clear",
        "weather_low": -2.5,
        "weather_high": 5.0,
        "icon_code": "01d",
        "icon_url": "http://openweathermap.org/img/wn/01d@2x.png"
    },
    # ... 최대 8일치 데이터
]
```

#### `save_weather_to_db(lat: str, lon: str, overwrite: bool) -> Dict`

API에서 가져온 날씨 데이터를 데이터베이스에 저장합니다.

**파라미터:**
- `lat`: 위도
- `lon`: 경도
- `overwrite`: 기존 데이터 덮어쓰기 여부 (기본값: False)

**반환값:**
```python
{
    "success": True,
    "message": "날씨 데이터 저장 완료 (삽입: 5, 업데이트: 0)",
    "inserted_count": 5,
    "updated_count": 0,
    "errors": []
}
```

---

## 3. Weather API 엔드포인트

### 파일: `fastapi/app/api/weather.py`

날씨 데이터를 조회하고 관리하는 REST API 엔드포인트입니다.

### 엔드포인트 목록

#### 1. 전체 날씨 데이터 조회

```
GET /api/weather
```

**쿼리 파라미터:**
- `start_date` (선택): 시작 날짜 (YYYY-MM-DD)
- `end_date` (선택): 종료 날짜 (YYYY-MM-DD)

**예시:**
```bash
# 전체 조회
GET /api/weather

# 기간별 조회
GET /api/weather?start_date=2026-01-15&end_date=2026-01-20
```

**응답:**
```json
{
  "results": [
    {
      "weather_datetime": "2026-01-15T00:00:00",
      "weather_type": "맑음",
      "weather_low": -2.5,
      "weather_high": 5.0
    }
  ]
}
```

#### 2. 특정 날짜의 날씨 데이터 조회

```
GET /api/weather/{weather_datetime}
```

**예시:**
```bash
GET /api/weather/2026-01-15
# 또는
GET /api/weather/2026-01-15%2000:00:00
```

#### 3. 날씨 데이터 수동 추가

```
POST /api/weather
```

**Form 데이터:**
- `weather_datetime`: 날짜 (YYYY-MM-DD 또는 YYYY-MM-DD HH:MM:SS)
- `weather_type`: 날씨 상태 (한글)
- `weather_low`: 최저 온도
- `weather_high`: 최고 온도

#### 4. 날씨 데이터 수정

```
PUT /api/weather/{weather_datetime}
```

**Form 데이터 (모두 선택사항):**
- `weather_type`: 날씨 상태
- `weather_low`: 최저 온도
- `weather_high`: 최고 온도

#### 5. 날씨 데이터 삭제

```
DELETE /api/weather/{weather_datetime}
```

#### 6. OpenWeatherMap API에서 데이터 가져오기 및 저장

```
POST /api/weather/fetch-from-api
```

**Form 데이터:**
- `lat` (선택): 위도 (기본값: 서울)
- `lon` (선택): 경도 (기본값: 서울)
- `overwrite` (선택): 기존 데이터 덮어쓰기 여부 (기본값: false)

**예시:**
```bash
# 서울 날씨 데이터 가져오기
POST /api/weather/fetch-from-api

# 특정 위치의 날씨 데이터 가져오기
POST /api/weather/fetch-from-api
Content-Type: application/x-www-form-urlencoded

lat=37.5665&lon=126.9780&overwrite=false
```

**응답:**
```json
{
  "result": "OK",
  "message": "날씨 데이터 저장 완료 (삽입: 5, 업데이트: 0)",
  "inserted_count": 5,
  "updated_count": 0,
  "errors": []
}
```

---

## 4. OpenWeatherMap 아이콘 사용

OpenWeatherMap은 날씨 아이콘을 무료로 제공합니다.

### 아이콘 URL 형식

```
http://openweathermap.org/img/wn/{icon_code}@{size}.png
```

**예시:**
- `http://openweathermap.org/img/wn/01d@2x.png` - 맑음 (낮)
- `http://openweathermap.org/img/wn/10n@2x.png` - 비 (밤)
- `http://openweathermap.org/img/wn/13d@4x.png` - 눈 (낮, 큰 크기)

### 아이콘 코드 형식

- 첫 2자리: 날씨 상태 코드
  - `01`: 맑음
  - `02`: 약간 흐림
  - `03`: 흐림
  - `04`: 매우 흐림
  - `09`: 소나기
  - `10`: 비
  - `11`: 천둥번개
  - `13`: 눈
  - `50`: 안개/연무 등

- 마지막 문자: 시간대
  - `d`: 낮 (day)
  - `n`: 밤 (night)

### Flutter 앱에서 사용

```dart
// API 응답에서 icon_code를 받아서 사용
String iconCode = "01d";  // API에서 받은 값
String iconUrl = "http://openweathermap.org/img/wn/${iconCode}@2x.png";

// Image.network로 표시
Image.network(iconUrl)
```

---

## 5. 사용 예시

### Python에서 직접 사용

```python
from app.utils.weather_service import WeatherService

# 서비스 초기화
weather_service = WeatherService()

# API에서 데이터 가져오기
daily_forecasts = weather_service.fetch_daily_weather(
    lat="37.5665",
    lon="126.9780"
)

# 데이터베이스에 저장
result = weather_service.save_weather_to_db(
    lat="37.5665",
    lon="126.9780",
    overwrite=False
)

print(f"삽입: {result['inserted_count']}, 업데이트: {result['updated_count']}")
```

### API 엔드포인트 사용

```bash
# 1. OpenWeatherMap API에서 데이터 가져오기
curl -X POST "http://localhost:8000/api/weather/fetch-from-api" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "lat=37.5665&lon=126.9780&overwrite=false"

# 2. 저장된 데이터 조회
curl "http://localhost:8000/api/weather"

# 3. 특정 날짜 조회
curl "http://localhost:8000/api/weather/2026-01-15"
```

---

## 6. 주기적 업데이트 설정

날씨 데이터를 주기적으로 업데이트하려면 스케줄러를 사용할 수 있습니다.

### 예시: cron 작업 (Linux/Mac)

```bash
# 매일 오전 6시에 날씨 데이터 업데이트
0 6 * * * curl -X POST "http://localhost:8000/api/weather/fetch-from-api" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "lat=37.5665&lon=126.9780&overwrite=true"
```

### 예시: Python 스케줄러 (APScheduler)

```python
from apscheduler.schedulers.background import BackgroundScheduler
from app.utils.weather_service import WeatherService

def update_weather():
    weather_service = WeatherService()
    weather_service.save_weather_to_db(overwrite=True)

scheduler = BackgroundScheduler()
scheduler.add_job(update_weather, 'cron', hour=6)  # 매일 오전 6시
scheduler.start()
```

---

## 7. 에러 처리

### API 키가 없는 경우

```
ValueError: OpenWeatherMap API 키가 설정되지 않았습니다.
```

**해결 방법:** `.env` 파일에 `OPENWEATHER_API_KEY` 설정

### API 요청 실패

```
requests.RequestException: OpenWeatherMap API 요청 실패: ...
```

**해결 방법:** 
- 네트워크 연결 확인
- API 키 유효성 확인
- OpenWeatherMap 서비스 상태 확인

### 데이터베이스 연결 실패

```
pymysql.Error: Database connection failed: ...
```

**해결 방법:** `fastapi/app/database/connection.py`의 DB 설정 확인

---

## 8. 참고 자료

- [OpenWeatherMap OneCall API 문서](https://openweathermap.org/api/one-call-3)
- [OpenWeatherMap 아이콘 가이드](https://openweathermap.org/weather-conditions)
- [OpenWeatherMap API 키 발급](https://home.openweathermap.org/api_keys)

---

## 9. 생성/수정 이력

**2026-01-15 김택권: 초기 생성**
- 날씨 상태 매핑 테이블 구현 (weather_mapping.py)
- OpenWeatherMap API 서비스 구현 (weather_service.py)
- Weather API 라우터 구현 (weather.py)
- OpenWeatherMap 아이콘 URL 생성 기능 추가
- 일별 날씨 데이터 수집 및 저장 기능 구현
