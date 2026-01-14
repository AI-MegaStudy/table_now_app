# Table Now 데이터베이스 스키마

Table Now 프로젝트의 MySQL 데이터베이스 스키마 및 관련 파일을 관리하는 폴더입니다.

## 폴더 구조

```
mysql/
├── README.md                    # 이 파일
├── table_now_db_init.sql        # 데이터베이스 초기화 스키마 (작성 예정)
├── create_db.py                 # 데이터베이스 생성 스크립트 (작성 예정)
└── Workbench/                   # MySQL Workbench 관련 파일
    ├── table_now_db.mwb         # Workbench 모델 파일 (작성 예정)
    └── table_now_db_forward.sql # 포워드 엔지니어링 SQL (작성 예정)
```

## 사용 방법

### 1. 데이터베이스 스키마 작성

`table_now_db_init.sql` 파일에 Table Now 프로젝트의 데이터베이스 스키마를 작성하세요.

### 2. 데이터베이스 생성

`create_db.py` 스크립트를 실행하여 데이터베이스를 생성할 수 있습니다:

```bash
python mysql/create_db.py
```

### 3. MySQL Workbench 사용

- `Workbench/table_now_db.mwb`: MySQL Workbench에서 EER 다이어그램을 그릴 때 사용
- 포워드 엔지니어링: Workbench에서 SQL 파일로 내보내기
- 리버스 엔지니어링: 기존 데이터베이스에서 Workbench 모델 생성

## 참고사항

- 이전 프로젝트(슈즈샵앱)의 스키마 파일들은 삭제되었습니다
- Table Now 프로젝트에 맞는 새로운 스키마를 작성하세요
