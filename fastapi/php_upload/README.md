# 이미지 업로드 도구

NAS에 이미지 파일을 업로드하기 위한 PHP 스크립트 및 테스트 도구입니다.

## 📁 파일 목록

### PHP 스크립트 (NAS에 업로드 필요)
- **`upload_image.php`** - 이미지 업로드용 PHP 스크립트
  - 배치 위치: NAS의 웹서버 디렉토리 (예: `/share/Web/`)
  - 역할: 이미지 파일을 웹서버 디렉토리에 저장
  
- **`upload_model.php`** - 3D 모델 파일 업로드용 PHP 스크립트 (선택사항)
  - 배치 위치: NAS의 웹서버 디렉토리
  - 역할: GLB 등 모델 파일 저장

- **`check_phpinfo.php`** - PHP 웹서버 경로 확인용 스크립트
  - 배치 위치: NAS의 웹서버 디렉토리
  - 역할: DOCUMENT_ROOT 등 PHP 서버 정보 확인

### 테스트 스크립트
- **`test_upload_php.py`** - PHP 업로드 테스트 (FastAPI 경유)
- **`test_upload_local.py`** - 로컬 파일 업로드 테스트
- **`test_upload.py`** - 범용 업로드 테스트 스크립트
- **`test_upload_simple.sh`** - 간단한 curl 기반 테스트

### 문서
- **`README_PHP_PATH.md`** - PHP 웹서버 경로 찾기 가이드

## 🚀 사용 방법

### 1. PHP 파일 배치

NAS의 웹서버 디렉토리에 PHP 파일을 업로드합니다:

```bash
# 예시: QNAP NAS의 경우
scp upload_image.php user@nas:/share/Web/
scp upload_model.php user@nas:/share/Web/  # 필요시
```

### 2. PHP 스크립트 설정 수정

`upload_image.php` 파일에서 다음 설정을 확인/수정하세요:
- 저장 경로 설정
- 파일명 규칙
- 허용 파일 형식
- 최대 파일 크기

### 3. FastAPI 엔드포인트 추가

FastAPI에서 이미지 업로드 엔드포인트를 추가할 때:

```python
# app/api/upload.py 예시
from fastapi import APIRouter, UploadFile, File
import httpx

router = APIRouter()

@router.post("/upload")
async def upload_image(file: UploadFile = File(...)):
    # PHP 스크립트로 파일 전송
    php_url = "https://your-nas-domain.com/upload_image.php"
    # ... 업로드 로직
```

### 4. 테스트 실행

```bash
# FastAPI 서버 실행 후
cd fastapi/php_upload
python test_upload_php.py
```

## ⚙️ 설정

### PHP 스크립트 설정
- 웹서버 URL: 실제 NAS 도메인으로 변경 필요
- 이미지 저장 경로: 프로젝트에 맞게 수정
- 파일명 규칙: 프로젝트 요구사항에 맞게 수정

### FastAPI 설정
이미지 업로드 엔드포인트를 만들 때 PHP 스크립트 URL을 설정하세요.

## 📝 참고사항

- 이 파일들은 이전 프로젝트에서 테스트용으로 사용되었습니다
- Table Now 프로젝트에 맞게 경로와 설정을 수정해야 합니다
- PHP 파일은 NAS의 웹서버 디렉토리에 배치해야 합니다
- DB 업데이트는 FastAPI가 담당합니다 (PHP는 파일 저장만)

## 🔄 Table Now 프로젝트 적용 시

1. `upload_image.php`의 저장 경로와 파일명 규칙을 Table Now 프로젝트에 맞게 수정
2. FastAPI에 이미지 업로드 엔드포인트 추가
3. 테스트 스크립트로 동작 확인
