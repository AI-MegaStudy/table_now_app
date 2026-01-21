# Weather 테이블 제거 마이그레이션 공지

**작업일**: 2026-01-21  
**작업자**: 김택권  
**커밋**: 34c339c

---

## 전체 변경 요약

### 삭제된 항목
- `weather` 테이블 완전 삭제
- `reserve` 테이블에서 `weather_datetime` 컬럼 삭제
- `fk_reserve_weather` 외래키 삭제
- `lib/view/weather/weather_screen.dart` 파일 삭제

### 유지되는 기능
- `GET /api/weather/direct` (8일 예보 - OpenWeatherMap API 직접 호출)
- `GET /api/weather/direct/single` (단일 날짜 예보)
- `weather_forecast_screen.dart` (날씨 예보 화면)

---

## 팀원별 수정 내용

### 유다원 (reserve 담당)

**수정된 파일**: `fastapi/app/api/reserve.py`

#### 변경 내용
1. reserve 테이블 스키마 변경
   - `weather_datetime` 컬럼 삭제됨
   - `fk_reserve_weather` 외래키 삭제됨

2. reserve.py 수정 사항
   - INSERT/UPDATE/SELECT SQL에서 `weather_datetime` 제거
   - 함수 파라미터에서 `weather_datetime` 제거
   - API 응답에서 `weather_datetime` 필드 제거

#### 조치 필요
- `git pull origin main` 실행
- 작업 중인 reserve 관련 코드에서 `weather_datetime` 참조가 있다면 제거
- 충돌 발생 시 `weather_datetime` 관련 코드 삭제 방향으로 해결

---

### 이광태 (payment 담당)

**수정된 파일**: `lib/vm/payment_list_notifier.dart`

#### 변경 내용
- `receiveData` 더미 데이터에서 `weather_datetime` 필드 제거

#### 조치 필요
- `git pull origin main` 실행
- 충돌 발생 시 `weather_datetime` 필드 삭제 방향으로 해결

---

## 기타 팀원

임소연, 이예은: 담당 코드에 직접적인 수정 없음

---

## 문의

작업 관련 문의: 김택권
