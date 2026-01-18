# 테이블 스펙시트 v5 (ERD_02 기준)

본 문서는 최신 ERD(ERD_02.jpeg)를 기준으로 작성된 **MySQL 8.0용 테이블 스펙시트**이다.
이전 문서(v1~v4)는 혼선 방지를 위해 **폐기 대상**으로 간주한다.

---

## 표기 규칙

- 사각형: 엔티티(Entity)
- 다이아몬드: 릴레이션쉽(Relationship)
- 네모+다이아몬드: 연관 엔티티(Associative Entity)
- PK: 분홍색 타원
- FK: 주황색 타원
- 표기법: snake_case
- `auto_` 접두사: ERD 상의 자동 증가 의미 표현 (컬럼명에는 포함하지 않음)
- Auto Increment: 비고에 `Auto_Increment`로 표기
- NULL 가능 컬럼: ERD에서 타입 뒤 `?` → NULL 허용(Y)
- 날짜/시간: ERD에 `datetime`으로 명시된 경우 MySQL `DATETIME` 사용
- 예약어 회피: `table` 사용 금지 → `store_table`

---

## 타입 매핑 규칙

| ERD 타입 | MySQL 타입   |
| -------- | ------------ |
| int      | INT          |
| double   | DOUBLE       |
| string   | VARCHAR(255) |
| datetime | DATETIME     |

---

## 1. customer (고객)

- 구분: 엔티티(Entity)
- 설명: 고객 계정 정보를 관리한다. 소셜 로그인(구글) 및 일반 로그인을 지원한다.

| 컬럼명           | 타입         | 키  | NULL | 비고            | 설명                                             |
| ---------------- | ------------ | --- | ---- | --------------- | ------------------------------------------------ |
| customer_seq     | INT          | PK  | N    | Auto_Increment  | 고객 번호                                        |
| customer_name    | VARCHAR(255) |     | N    |                 | 고객 이름                                        |
| customer_phone   | VARCHAR(255) |     | Y    |                 | 고객 전화번호 (소셜 로그인 시 NULL 가능)         |
| customer_email   | VARCHAR(255) |     | N    |                 | 고객 이메일                                      |
| customer_pw      | VARCHAR(255) |     | Y    |                 | 비밀번호 (소셜 로그인 시 NULL)                   |
| provider         | VARCHAR(255) |     | N    | 기본값: 'local' | 로그인 제공자 ('local' 또는 'google')            |
| provider_subject | VARCHAR(255) |     | Y    | 인덱스 있음     | 소셜 로그인 제공자의 사용자 ID (구글: google_id) |
| created_at       | DATETIME     |     | N    |                 | 가입 일자                                        |

**비고:**

- `provider`: 'local' (일반 회원가입) 또는 'google' (구글 로그인)
- `provider_subject`: 구글 로그인 사용자의 경우 구글 ID 저장
- `customer_pw`: 구글 로그인 사용자는 NULL, 일반 회원가입 사용자는 비밀번호 저장
- `customer_phone`: 구글 로그인 사용자는 NULL 가능

---

## 2. store (식당)

- 구분: 엔티티(Entity)
- 설명: 식당(매장) 기본 정보

| 컬럼명            | 타입         | 키  | NULL | 비고           | 설명             |
| ----------------- | ------------ | --- | ---- | -------------- | ---------------- |
| store_seq         | INT          | PK  | N    | Auto_Increment | 식당 번호        |
| store_address     | VARCHAR(255) |     | N    |                | 주소             |
| store_lat         | DOUBLE       |     | N    |                | 위도             |
| store_lng         | DOUBLE       |     | N    |                | 경도             |
| store_phone       | VARCHAR(255) |     | N    |                | 전화번호         |
| store_opentime    | VARCHAR(255) |     | Y    |                | 운영 시작시간    |
| store_closetime   | VARCHAR(255) |     | Y    |                | 운영 종료시간    |
| store_description | VARCHAR(255) |     | Y    |                | 식당 설명        |
| store_image       | VARCHAR(255) |     | Y    |                | 이미지 URL       |
| store_placement   | VARCHAR(255) |     | N    |                | 테이블 배치 정보 |
| created_at        | DATETIME     |     | N    |                | 생성 일자        |

---

## 3. store_table (테이블)

- 구분: 릴레이션쉽(Relationship)
- 설명: 식당에 소속된 테이블 정보

| 컬럼명               | 타입         | 키  | NULL | 비고            | 설명           |
| -------------------- | ------------ | --- | ---- | --------------- | -------------- |
| store_table_seq      | INT          | PK  | N    | Auto_Increment  | 테이블 번호    |
| store_seq            | INT          | FK  | N    | store.store_seq | 식당 번호      |
| store_table_name     | INT          |     | N    |                 | 테이블 이름    |
| store_table_capacity | INT          |     | N    |                 | 수용 인원      |
| store_table_inuse    | VARCHAR(255) |     | N    |                 | 사용 가능 여부 |
| created_at           | DATETIME     |     | N    |                 | 생성 일자      |

---

## 4. weather (날씨)

- 구분: 연관 엔티티(Associative Entity)
- 설명: 식당별 특정 시점의 날씨 정보. store와 날씨 정보를 연결하며, reserve가 참조함

| 컬럼명           | 타입         | 키  | NULL | 비고            | 설명           |
| ---------------- | ------------ | --- | ---- | --------------- | -------------- |
| store_seq        | INT          | PK  | N    | store.store_seq | 식당 번호      |
| weather_datetime | DATETIME     | PK  | N    |                 | 날씨 기준 일시 |
| weather_type     | VARCHAR(255) |     | N    |                 | 날씨 상태      |
| weather_low      | DOUBLE       |     | N    |                 | 최저 기온      |
| weather_high     | DOUBLE       |     | N    |                 | 최고 기온      |

**비고:**

- PK는 `(store_seq, weather_datetime)` 복합키
- 각 식당별로 날씨 정보를 저장
- OpenWeatherMap API 호출 시 해당 식당의 `store_lat`, `store_lng`를 사용하여 날씨 정보 저장
- `reserve` 테이블이 `weather` 테이블을 참조하여 예약 시점의 날씨 정보를 연결
- 독립적인 속성(`weather_type`, `weather_low`, `weather_high`)을 보유한 연관 엔티티

---

## 5. reserve (예약)

- 구분: 릴레이션쉽(Relationship)
- 설명: 예약 기본 정보 및 결제 상태

| 컬럼명           | 타입         | 키  | NULL | 비고                    | 설명             |
| ---------------- | ------------ | --- | ---- | ----------------------- | ---------------- |
| reserve_seq      | INT          | PK  | N    | Auto_Increment          | 예약 번호        |
| store_seq        | INT          | FK  | N    | store.store_seq         | 식당 번호        |
| customer_seq     | INT          | FK  | N    | customer.customer_seq   | 고객 번호        |
| weather_datetime | DATETIME     | FK  | N    | weather 복합키 참조     | 날씨 기준 일시   |
| reserve_tables   | VARCHAR(255) |     | N    | 테이블 번호 콤마로 묶음 | 테이블 번호들    |
| reserve_capacity | INT          |     | N    |                         | 예약 인원        |
| reserve_date     | DATETIME     |     | N    |                         | 예약 일시        |
| created_at       | DATETIME     |     | N    |                         | 생성 일자        |
| payment_key      | VARCHAR(255) |     | Y    |                         | Toss Payment Key |
| payment_status   | VARCHAR(255) |     | Y    |                         | 결제 상태        |

**비고:**

- `weather_datetime`: `weather` 테이블의 복합키 `(store_seq, weather_datetime)`를 참조하는 FK의 일부
- `reserve` 테이블의 FK는 `(store_seq, weather_datetime)` 복합키로 `weather` 테이블의 복합키를 참조
- `reserve.store_seq`와 `weather.store_seq`가 자동으로 일치해야 함 (FK 제약조건)

---

## 6. menu (메뉴)

- 구분: 연관 엔티티(Associative Entity)
- 설명: 식당에 속한 메뉴 마스터

| 컬럼명           | 타입         | 키  | NULL | 비고            | 설명            |
| ---------------- | ------------ | --- | ---- | --------------- | --------------- |
| menu_seq         | INT          | PK  | N    | Auto_Increment  | 메뉴 번호       |
| store_seq        | INT          | FK  | N    | store.store_seq | 식당 번호       |
| menu_name        | VARCHAR(255) |     | N    |                 | 메뉴 이름       |
| menu_price       | INT          |     | N    |                 | 메뉴 가격       |
| menu_description | VARCHAR(255) |     | N    |                 | 메뉴 설명       |
| menu_image       | VARCHAR(255) |     | N    |                 | 메뉴 이미지 URL |
| menu_cost        | INT          |     | N    |                 | 메뉴 원가       |
| created_at       | DATETIME     |     | N    |                 | 생성 일자       |

---

## 7. option (추가 메뉴)

- 구분: 릴레이션쉽(Relationship)
- 설명: 메뉴에 종속된 추가 메뉴(옵션)

| 컬럼명       | 타입         | 키  | NULL | 비고            | 설명           |
| ------------ | ------------ | --- | ---- | --------------- | -------------- |
| option_seq   | INT          | PK  | N    | Auto_Increment  | 추가 메뉴 번호 |
| store_seq    | INT          | FK  | N    | store.store_seq | 식당 번호      |
| menu_seq     | INT          | FK  | N    | menu.menu_seq   | 메뉴 번호      |
| option_name  | VARCHAR(255) |     | N    |                 | 추가 메뉴 이름 |
| option_price | INT          |     | N    |                 | 추가 메뉴 가격 |
| option_cost  | INT          |     | N    |                 | 추가 메뉴 원가 |
| created_at   | DATETIME     |     | N    |                 | 생성 일자      |

---

## 8. pay (결제)

- 구분: 연관 엔티티(Associative Entity)
- 설명: 예약 단위의 실제 결제 내역

| 컬럼명       | 타입     | 키  | NULL | 비고                | 설명           |
| ------------ | -------- | --- | ---- | ------------------- | -------------- |
| pay_id       | INT      | PK  | N    |                     | 결제 번호      |
| reserve_seq  | INT      | FK  | N    | reserve.reserve_seq | 예약 번호      |
| store_seq    | INT      | FK  | N    | store.store_seq     | 식당 번호      |
| menu_seq     | INT      | FK  | N    | menu.menu_seq       | 메뉴 번호      |
| option_seq   | INT      | FK  | Y    | option.option_seq   | 추가 메뉴 번호 |
| pay_quantity | INT      |     | N    |                     | 수량           |
| pay_amount   | INT      |     | N    |                     | 결제 금액      |
| created_at   | DATETIME |     | N    |                     | 생성 일자      |

---

## 9. password_reset_auth (비밀번호 변경 인증)

- 구분: 릴레이션쉽(Relationship)
- 설명: 비밀번호 변경 시 이메일 인증 코드를 관리한다. customer와의 관계를 가진다.

| 컬럼명       | 타입         | 키  | NULL | 비고                  | 설명                     |
| ------------ | ------------ | --- | ---- | --------------------- | ------------------------ |
| auth_seq     | INT          | PK  | N    | Auto_Increment        | 인증 번호                |
| customer_seq | INT          | FK  | N    | customer.customer_seq | 고객 번호                |
| auth_token   | VARCHAR(255) |     | N    | 인덱스 있음           | 인증 토큰 (UUID)         |
| auth_code    | VARCHAR(6)   |     | Y    |                       | 인증 코드 (6자리 숫자)   |
| expires_at   | DATETIME     |     | N    | 인덱스 있음           | 만료 일시 (생성 후 10분) |
| is_verified  | BOOLEAN      |     | N    | 기본값: FALSE         | 인증 완료 여부           |
| created_at   | DATETIME     |     | N    |                       | 생성 일시                |

**비고:**

- 비밀번호 변경 요청 시 생성되며, 이메일로 인증 코드가 발송됨
- 인증 코드는 10분간 유효함
- 인증 완료 후 비밀번호 변경에 사용되며, 사용 후 삭제됨 (일회용)
- `auth_token`과 `auth_code`를 조합하여 인증 진행

---

## 10. device_token (FCM 기기 토큰)

- 구분: 릴레이션쉽(Relationship)
- 설명: 사용자 기기의 FCM 토큰을 관리한다. 한 사용자가 여러 기기를 사용할 수 있도록 설계되었다.

| 컬럼명            | 타입         | 키  | NULL | 비고                    | 설명                        |
| ----------------- | ------------ | --- | ---- | ----------------------- | --------------------------- |
| device_token_seq  | INT          | PK  | N    | Auto_Increment          | 기기 토큰 번호              |
| customer_seq      | INT          | FK  | N    | customer.customer_seq   | 고객 번호                   |
| fcm_token         | VARCHAR(255) |     | N    | 인덱스 있음, UNIQUE     | FCM 토큰                    |
| device_type       | VARCHAR(10)  |     | N    |                         | 기기 타입 ('ios' 또는 'android') |
| created_at        | DATETIME     |     | N    | 기본값: CURRENT_TIMESTAMP | 생성 일시                   |
| updated_at        | DATETIME     |     | N    | ON UPDATE CURRENT_TIMESTAMP | 수정 일시                   |

**비고:**

- 한 사용자가 여러 기기를 사용할 수 있으므로 `(customer_seq, fcm_token)` 복합 UNIQUE 키 사용
- `customer_seq`에 대한 외래키 제약조건: `ON DELETE CASCADE` (사용자 삭제 시 관련 토큰도 자동 삭제)
- `fcm_token`에 인덱스 설정 (토큰으로 빠른 조회 가능)
- FCM 토큰은 기기별로 고유하며, 앱 재설치 시 변경될 수 있음

---

## 변경 이력

- **2026-01-15**: customer 테이블 소셜 로그인 컬럼 추가 (작성자: 김택권)
  - `provider` 컬럼 추가 (기본값: 'local')
  - `provider_subject` 컬럼 추가 (구글 ID 저장용)
  - `customer_phone` NULL 허용으로 변경
  - `customer_pw` NULL 허용으로 변경
- **2026-01-15**: password_reset_auth 테이블 추가 (작성자: 김택권)
  - 비밀번호 변경 이메일 인증을 위한 테이블 생성
- **2026-01-15**: v5로 버전 업데이트 (작성자: 김택권)
  - 문서 버전을 v4에서 v5로 업데이트
  - 이전 문서 폐기 대상에 v4 추가
- **2026-01-16**: weather 테이블 구조 변경 (작성자: 김택권)
  - `weather` 테이블에 `store_seq` 컬럼 추가 (FK)
  - `weather` 테이블 PK를 `(store_seq, weather_datetime)` 복합키로 변경
  - `reserve` 테이블의 `weather_datetime` FK를 복합키 FK `(store_seq, weather_datetime)`로 변경
  - 각 식당별로 날씨를 저장할 수 있도록 복합키 구조 적용
- **2026-01-16**: device_token 테이블 추가
  - FCM 푸시 알림을 위한 기기 토큰 관리 테이블 추가
  - 한 사용자가 여러 기기를 사용할 수 있도록 설계
  - `customer_seq`에 대한 외래키 제약조건: `ON DELETE CASCADE`
- **2026-01-16**: weather 테이블 구분 변경
  - `weather` 테이블의 구분을 "릴레이션쉽(Relationship)"에서 "연관 엔티티(Associative Entity)"로 변경
  - `reserve` 테이블이 `weather`를 참조하는 구조를 명확히 함
  - 독립적인 속성을 보유하고 여러 엔티티를 연결하는 연관 엔티티의 특성 반영