# PHP 웹서버 경로 찾기 가이드

## QNAP 파일 스테이션에서 실제 경로 확인하기

### 방법 1: 파일 스테이션 주소창 확인
1. QNAP 파일 스테이션 접속
2. 파일을 선택하고 우클릭 → **속성** 또는 **정보**
3. 주소창의 경로 확인 (예: `/share/Web` 또는 `/share/CACHEDEV1_DATA/Web`)

### 방법 2: 파일 스테이션 개발자 도구 사용
1. 파일 스테이션에서 파일 선택
2. 브라우저 개발자 도구(F12) 열기
3. Network 탭에서 파일 다운로드 요청 확인
4. 요청 URL에서 실제 경로 추정

### 방법 3: phpinfo.php로 확인 (가장 확실한 방법) ⭐
1. 웹 브라우저에서 `https://cheng80.myqnapcloud.com/phpinfo.php` 접속
2. 다음 항목들을 확인:
   - **`$_SERVER["DOCUMENT_ROOT"]`** → 웹서버의 DocumentRoot 경로 (가장 중요!)
   - **`$_SERVER["SCRIPT_FILENAME"]`** → phpinfo.php 파일의 실제 경로
   - **`upload_tmp_dir`** → 파일 업로드 임시 디렉토리
   - **`open_basedir`** → PHP가 접근 가능한 기본 디렉토리
3. `DOCUMENT_ROOT` 경로를 확인하면, model 디렉토리는 `{DOCUMENT_ROOT}/model`이 됩니다.

**예시**: 
- `DOCUMENT_ROOT`가 `/share/Web`이면 → model 디렉토리는 `/share/Web/model`
- `DOCUMENT_ROOT`가 `/share/Qweb`이면 → model 디렉토리는 `/share/Qweb/model`

### 방법 4: 파일 스테이션에서 공유 폴더 경로 확인
1. 파일 스테이션 → **공유 폴더** 메뉴
2. 공유 폴더 목록에서 웹서버 관련 폴더 확인
3. 폴더 우클릭 → **속성** → **일반** 탭에서 경로 확인

**참고**: QNAP 파일 스테이션은 일반적으로 `/share/[공유폴더명]` 형식으로 표시됩니다.
- 공유 폴더명이 `Web`이면 → `/share/Web`
- 공유 폴더명이 `www`이면 → `/share/www`

**실제 예시**: 
- 파일 스테이션에서 보이는 경로: `/Web/images`
- 실제 파일 시스템 경로: `/share/Web/images`
- 따라서 model 디렉토리는: `/share/Web/model`

### 방법 5: SSH에서 공유 폴더 경로 확인
```bash
# 공유 폴더 목록과 실제 경로 확인
cat /etc/config/smb.conf | grep path

# 또는
ls -la /share/
```

## QNAP NAS에서 웹서버 구동 경로 찾기

### 방법 1: 웹서버 프로세스 확인 (가장 확실한 방법)

SSH에서 다음 명령 실행:

```bash
# Apache 프로세스 확인
ps aux | grep apache | grep -v grep

# Nginx 프로세스 확인  
ps aux | grep nginx | grep -v grep

# 웹서버 프로세스의 작업 디렉토리 확인
lsof -p $(pgrep -f apache | head -1) | grep cwd
lsof -p $(pgrep -f nginx | head -1) | grep cwd
```

### 방법 2: 웹서버 설정 파일 확인

```bash
# Apache 설정 파일 찾기
find /etc -name "httpd.conf" 2>/dev/null
find /usr/local -name "httpd.conf" 2>/dev/null

# Nginx 설정 파일 찾기
find /etc -name "nginx.conf" 2>/dev/null
find /usr/local -name "nginx.conf" 2>/dev/null

# 설정 파일에서 DocumentRoot 또는 root 확인
grep -r "DocumentRoot" /etc/config/apache/ 2>/dev/null
grep -r "root" /etc/config/nginx/ 2>/dev/null
```

### 방법 3: 실제 웹 접속으로 확인

1. 웹 브라우저에서 QNAP 도메인/IP로 접속
2. 개발자 도구(F12) → Network 탭
3. 이미지나 파일 요청의 실제 경로 확인
4. 예: `https://your-domain.com/images/logo.png` → 실제 파일 시스템 경로 추정

### 방법 4: QNAP 웹 관리 페이지 확인

1. QNAP 웹 관리 페이지 접속
2. 제어판 → 웹 서버 → 가상 호스트 설정 확인
3. Document Root 경로 확인

### 방법 5: 테스트 파일로 확인

```bash
# 임시 테스트 파일 생성
echo "test" > /share/Web/test.txt
# 또는
echo "test" > /share/Qweb/test.txt

# 웹 브라우저에서 접속 시도
# https://your-domain.com/test.txt
# 접속되는 경로가 실제 웹서버 경로
```

## 경로 설정 (완료 ✅)

**확인된 경로:**
- DOCUMENT_ROOT: `/share/Web` (phpinfo.php에서 확인)
- PHP 웹서버 URL: `https://cheng80.myqnapcloud.com`
- Model 디렉토리: `/share/Web/model` (GLB 파일용)
- Images 디렉토리: `/share/Web/images` (제품 이미지용)

**현재 설정 상태:**
`fastapi/app/api/product.py` 파일에 이미 설정되어 있습니다:
```python
PHP_MODEL_DIR_STR = "/share/Web/model"  # ✅ GLB 파일용
PHP_IMAGES_DIR_STR = "/share/Web/images"  # ✅ 제품 이미지용
PHP_WEB_SERVER_URL = "https://cheng80.myqnapcloud.com"  # ✅ 설정 완료
```

**파일 저장 규칙:**
- **GLB 파일**: `/share/Web/model/{model_name}.glb`
  - URL: `https://cheng80.myqnapcloud.com/model.php?name={model_name}`
- **이미지 파일**: `/share/Web/images/product_{p_seq}_{filename}`
  - URL: `https://cheng80.myqnapcloud.com/images/product_{p_seq}_{filename}`

**다음 단계:**
1. 디렉토리 확인 (이미 존재하는지 확인):
   ```bash
   ls -la /share/Web/model
   ls -la /share/Web/images
   ```

2. 디렉토리가 없으면 생성:
   ```bash
   mkdir -p /share/Web/model
   mkdir -p /share/Web/images
   chmod 755 /share/Web/model
   chmod 755 /share/Web/images
   ```

3. FastAPI 재시작 후 파일 업로드 테스트

**환경 변수로 오버라이드 (선택사항):**
```bash
export PHP_MODEL_DIR="/share/Web/model"
export PHP_IMAGES_DIR="/share/Web/images"
export PHP_WEB_SERVER_URL="https://cheng80.myqnapcloud.com"
```

