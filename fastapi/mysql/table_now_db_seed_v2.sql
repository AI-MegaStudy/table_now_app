-- =========================================================
-- table_now_db Seed Data (Upsert)
-- 실행해도 중복 삽입되지 않도록 ON DUPLICATE KEY UPDATE 사용
-- 작성일: 2026-01-15
-- 작성자: 김택권
-- =========================================================

USE `table_now_db`;

START TRANSACTION;


SET FOREIGN_KEY_CHECKS = 0;


INSERT INTO `customer` (`customer_seq`, `customer_name`, `customer_phone`, `customer_email`, `customer_pw`, `provider`, `provider_subject`, `created_at`)
VALUES
(1, '테스트유저01', '010-0000-0001', 'user001@gmail.com', 'qwer1234', 'local', NULL, '2026-01-15 09:00:00'),
(2, '테스트유저02', '010-0000-0002', 'user002@gmail.com', 'qwer1234', 'local', NULL, '2026-01-15 09:00:00'),
(3, '테스트유저03', '010-0000-0003', 'user003@gmail.com', 'qwer1234', 'local', NULL, '2026-01-15 09:00:00')
ON DUPLICATE KEY UPDATE 
  `customer_name` = VALUES(`customer_name`),
  `customer_phone` = VALUES(`customer_phone`),
  `customer_email` = VALUES(`customer_email`),
  `customer_pw` = VALUES(`customer_pw`),
  `provider` = VALUES(`provider`),
  `provider_subject` = VALUES(`provider_subject`),
  `created_at` = VALUES(`created_at`);

INSERT INTO `store` (`store_seq`, `store_address`, `store_lat`, `store_lng`, `store_phone`, `store_opentime`, `store_closetime`, `store_description`, `store_image`, `store_placement`, `created_at`)
VALUES
  (1, '서울 마포구 양화로 45 (메세나폴리스 2층)', 0, 0.0, '02-820-7042', '11:00', '21:30', '코코이찌방야 합정 메세나폴리스점', 'coco_hapjeong.jpg', '배치 v1', '2026-01-15 10:00:00'),
  (2, '서울 마포구 홍익로 25', 0, 0.0, '02-323-0129', '11:30', '21:30', '아비꼬 홍대1호점', 'abiko_hongdae.jpg', '배치 v1', '2026-01-15 10:00:00'),
  (3, '서울 마포구 와우산로29길 27 1층', 0, 0.0, '0507-1403-4200', '11:30', '21:00', '토모토 카레 홍대점', 'tomoto_hongdae.jpg', '배치 v1', '2026-01-15 10:00:00')
ON DUPLICATE KEY UPDATE `store_address` = VALUES(`store_address`),`store_lat` = VALUES(`store_lat`),`store_lng` = VALUES(`store_lng`),`store_phone` = VALUES(`store_phone`),`store_opentime` = VALUES(`store_opentime`),`store_closetime` = VALUES(`store_closetime`),`store_description` = VALUES(`store_description`),`store_image` = VALUES(`store_image`),`store_placement` = VALUES(`store_placement`),`created_at` = VALUES(`created_at`);

INSERT INTO `store_table` (`store_table_seq`, `store_seq`, `store_table_name`, `store_table_capacity`, `store_table_inuse`, `created_at`)
VALUES
  (1, 1, 1, 2, 0, '2026-01-15 10:05:00'),
  (2, 1, 2, 2, 0, '2026-01-15 10:05:00'),
  (3, 1, 3, 2, 0, '2026-01-15 10:05:00'),
  (4, 1, 4, 2, 0, '2026-01-15 10:05:00'),
  (5, 1, 5, 2, 0, '2026-01-15 10:05:00'),
  (6, 1, 6, 2, 0, '2026-01-15 10:05:00'),
  (7, 1, 7, 2, 0, '2026-01-15 10:05:00'),
  (8, 1, 8, 4, 0, '2026-01-15 10:05:00'),
  (9, 1, 9, 4, 0, '2026-01-15 10:05:00'),
  (10, 1, 10, 4, 0, '2026-01-15 10:05:00'),
  (11, 1, 11, 4, 0, '2026-01-15 10:05:00'),
  (12, 1, 12, 4, 0, '2026-01-15 10:05:00'),
  (13, 2, 1, 2, 0, '2026-01-15 10:05:00'),
  (14, 2, 2, 2, 0, '2026-01-15 10:05:00'),
  (15, 2, 3, 2, 0, '2026-01-15 10:05:00'),
  (16, 2, 4, 2, 0, '2026-01-15 10:05:00'),
  (17, 2, 5, 2, 0, '2026-01-15 10:05:00'),
  (18, 2, 6, 2, 0, '2026-01-15 10:05:00'),
  (19, 2, 7, 2, 0, '2026-01-15 10:05:00'),
  (20, 2, 8, 4, 0, '2026-01-15 10:05:00'),
  (21, 2, 9, 4, 0, '2026-01-15 10:05:00'),
  (22, 2, 10, 4, 0, '2026-01-15 10:05:00'),
  (23, 2, 11, 4, 0, '2026-01-15 10:05:00'),
  (24, 2, 12, 4, 0, '2026-01-15 10:05:00'),
  (25, 3, 1, 2, 0, '2026-01-15 10:05:00'),
  (26, 3, 2, 2, 0, '2026-01-15 10:05:00'),
  (27, 3, 3, 2, 0, '2026-01-15 10:05:00'),
  (28, 3, 4, 2, 0, '2026-01-15 10:05:00'),
  (29, 3, 5, 2, 0, '2026-01-15 10:05:00'),
  (30, 3, 6, 2, 0, '2026-01-15 10:05:00'),
  (31, 3, 7, 2, 0, '2026-01-15 10:05:00'),
  (32, 3, 8, 4, 0, '2026-01-15 10:05:00'),
  (33, 3, 9, 4, 0, '2026-01-15 10:05:00'),
  (34, 3, 10, 4, 0, '2026-01-15 10:05:00'),
  (35, 3, 11, 4, 0, '2026-01-15 10:05:00'),
  (36, 3, 12, 4, 0, '2026-01-15 10:05:00')
ON DUPLICATE KEY UPDATE `store_seq` = VALUES(`store_seq`),`store_table_name` = VALUES(`store_table_name`),`store_table_capacity` = VALUES(`store_table_capacity`),`store_table_inuse` = VALUES(`store_table_inuse`),`created_at` = VALUES(`created_at`);

INSERT INTO `menu` (`menu_seq`, `store_seq`, `menu_name`, `menu_price`, `menu_description`, `menu_image`, `menu_cost`, `created_at`)
VALUES
  (1, 1, '로스까스카레', 11900, '코코이찌방야 대표 돈까스 카레', 'coco_ross.jpg', 4760, '2026-01-15 10:10:00'),
  (2, 1, '알새우카레', 12900, '새우 토핑 카레', 'coco_shrimp.jpg', 5160, '2026-01-15 10:10:00'),
  (3, 1, '비프샤브카레', 13500, '비프샤브 토핑 카레', 'coco_beefshabu.jpg', 5400, '2026-01-15 10:10:00'),
  (4, 1, '닭가슴살스테이크카레', 13700, '닭가슴살 스테이크 토핑 카레', 'coco_chickensteak.jpg', 5480, '2026-01-15 10:10:00'),
  (5, 2, '100시간카레', 7500, '아비꼬 대표 카레', 'abiko_100h.jpg', 3000, '2026-01-15 10:10:00'),
  (6, 2, '버섯카레', 9500, '버섯 토핑 카레', 'abiko_mushroom.jpg', 3800, '2026-01-15 10:10:00'),
  (7, 2, '허브치킨카레', 9800, '허브치킨 토핑 카레', 'abiko_herbchicken.jpg', 3920, '2026-01-15 10:10:00'),
  (8, 2, '쉬림프카레', 11800, '쉬림프 토핑 카레', 'abiko_shrimp.jpg', 4720, '2026-01-15 10:10:00'),
  (9, 3, '오므카레', 9500, '오므 + 카레', 'tomoto_omucurry.jpg', 3800, '2026-01-15 10:10:00'),
  (10, 3, '토모토카레', 8500, '흰밥 + 카레', 'tomoto_basic.jpg', 3400, '2026-01-15 10:10:00'),
  (11, 3, '토모토+치킨가라아게', 12300, '토모토카레 + 치킨가라아게', 'tomoto_karaage.jpg', 4920, '2026-01-15 10:10:00'),
  (12, 3, '토모토+수제생돈카츠', 13000, '토모토카레 + 수제 생돈카츠', 'tomoto_porkcutlet.jpg', 5200, '2026-01-15 10:10:00')
ON DUPLICATE KEY UPDATE `store_seq` = VALUES(`store_seq`),`menu_name` = VALUES(`menu_name`),`menu_price` = VALUES(`menu_price`),`menu_description` = VALUES(`menu_description`),`menu_image` = VALUES(`menu_image`),`menu_cost` = VALUES(`menu_cost`),`created_at` = VALUES(`created_at`);

INSERT INTO `option` (`option_seq`, `store_seq`, `menu_seq`, `option_name`, `option_price`, `option_cost`, `created_at`)
VALUES
  (1, 1, 1, '눈꽃치즈 토핑', 2200, 660, '2026-01-15 10:15:00'),
  (2, 1, 1, '감자튀김', 2000, 600, '2026-01-15 10:15:00'),
  (3, 1, 1, '치즈볼', 2000, 600, '2026-01-15 10:15:00'),
  (4, 2, 5, '온천계란', 1500, 450, '2026-01-15 10:15:00'),
  (5, 2, 5, '눈꽃치즈', 1500, 450, '2026-01-15 10:15:00'),
  (6, 2, 5, '치킨가라아게', 5000, 1500, '2026-01-15 10:15:00'),
  (7, 2, 5, '왕새우튀김', 5000, 1500, '2026-01-15 10:15:00'),
  (8, 3, 10, '치킨 가라아게 토핑', 3500, 1050, '2026-01-15 10:15:00'),
  (9, 3, 10, '치즈 함바그 토핑', 4000, 1200, '2026-01-15 10:15:00'),
  (10, 3, 10, '야채스아게 토핑', 3000, 900, '2026-01-15 10:15:00'),
  (11, 3, 10, '고로케 토핑', 2500, 750, '2026-01-15 10:15:00')
ON DUPLICATE KEY UPDATE `store_seq` = VALUES(`store_seq`),`menu_seq` = VALUES(`menu_seq`),`option_name` = VALUES(`option_name`),`option_price` = VALUES(`option_price`),`option_cost` = VALUES(`option_cost`),`created_at` = VALUES(`created_at`);

INSERT INTO `weather` (`store_seq`, `weather_datetime`, `weather_type`, `weather_low`, `weather_high`)
VALUES
  (1, '2026-01-15 00:00:00', '맑음', -2, 5),
  (2, '2026-01-15 00:00:00', '구름', -1, 3),
  (3, '2026-01-15 00:00:00', '맑음', 0, 4)
ON DUPLICATE KEY UPDATE `weather_type` = VALUES(`weather_type`),`weather_low` = VALUES(`weather_low`),`weather_high` = VALUES(`weather_high`);

INSERT INTO `reserve` (`reserve_seq`, `store_seq`, `customer_seq`, `weather_datetime`, `reserve_tables`, `reserve_capacity`, `reserve_date`, `created_at`, `payment_key`, `payment_status`)
VALUES
  (1, 1, 1, '2026-01-15 00:00:00', '1,2', 2, '2026-01-15 12:30:00', '2026-01-15 12:20:00', 'paykey_demo_001', 'DONE'),
  (2, 2, 2, '2026-01-15 00:00:00', '6', 1, '2026-01-15 18:30:00', '2026-01-15 18:25:00', 'paykey_demo_002', 'DONE')
ON DUPLICATE KEY UPDATE `store_seq` = VALUES(`store_seq`),`customer_seq` = VALUES(`customer_seq`),`weather_datetime` = VALUES(`weather_datetime`),`reserve_tables` = VALUES(`reserve_tables`),`reserve_capacity` = VALUES(`reserve_capacity`),`reserve_date` = VALUES(`reserve_date`),`created_at` = VALUES(`created_at`),`payment_key` = VALUES(`payment_key`),`payment_status` = VALUES(`payment_status`);

INSERT INTO `pay` (`reserve_seq`, `store_seq`, `menu_seq`, `option_seq`, `pay_quantity`, `pay_amount`, `created_at`)
VALUES
  (1, 1, 1, NULL, 1, 11900, '2026-01-15 12:20:10'),
  (1, 1, 1, 1, 1, 2200, '2026-01-15 12:20:10'),
  (1, 1, 1, 2, 1, 2000, '2026-01-15 12:20:10'),
  (2, 2, 5, NULL, 1, 7500, '2026-01-15 18:25:10'),
  (2, 2, 5, 4, 1, 1500, '2026-01-15 18:25:10')
ON DUPLICATE KEY UPDATE `reserve_seq` = VALUES(`reserve_seq`),`store_seq` = VALUES(`store_seq`),`menu_seq` = VALUES(`menu_seq`),`option_seq` = VALUES(`option_seq`),`pay_quantity` = VALUES(`pay_quantity`),`pay_amount` = VALUES(`pay_amount`),`created_at` = VALUES(`created_at`);

SET FOREIGN_KEY_CHECKS = 1;

COMMIT;

-- ============================================================
-- 생성 이력
-- ============================================================
-- 작성일: 2026-01-15
-- 작성자: 김택권
-- 설명: table_now_db 시드 데이터 스크립트 - 개발 및 테스트를 위한 초기 데이터 삽입
--       ON DUPLICATE KEY UPDATE를 사용하여 중복 실행 시에도 안전하게 업데이트
--
-- ============================================================
-- 수정 이력
-- ============================================================
-- 2026-01-15 김택권: 초기 생성
--   - customer 테이블 시드 데이터 추가 (테스트유저01~03, provider='local')
--   - store 테이블 시드 데이터 추가 (코코이찌방야, 아비꼬, 토모토 카레)
--   - store_table 테이블 시드 데이터 추가 (각 식당별 테이블 12개)
--   - menu 테이블 시드 데이터 추가 (각 식당별 메뉴 4개)
--   - option 테이블 시드 데이터 추가 (각 메뉴별 옵션)
--   - weather 테이블 시드 데이터 추가 (날씨 정보)
--   - reserve 테이블 시드 데이터 추가 (예약 정보)
--   - pay 테이블 시드 데이터 추가 (결제 정보)
--   - customer 테이블에 provider, provider_subject 컬럼 추가 반영
-- 2026-01-16 김택권: weather 테이블 구조 변경 반영
--   - weather 테이블 시드 데이터에 store_seq 추가 (각 식당별 오늘 날씨)
--   - weather_datetime을 00:00:00으로 통일 (오늘 날짜만 저장)
--   - reserve 테이블 시드 데이터의 weather_datetime을 00:00:00으로 변경
-- 2026-01-16 김택권: pay 테이블 PK 변경 반영
--   - pay 테이블 시드 데이터에서 pay_id 컬럼 제거 (AUTO_INCREMENT로 자동 할당)
-- 2026-01-16: device_token 테이블 추가 반영
--   - device_token 테이블은 FCM 토큰이 동적으로 생성되므로 시드 데이터 없음
-- 2026-01-20: device_token 테이블에 device_id 컬럼 추가 반영
--   - device_id 컬럼 추가 (기기 고유 식별자)
--   - 동일 기기에서 여러 사용자 로그인 지원