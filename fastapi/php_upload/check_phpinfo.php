<?php
/**
 * phpinfo.php에서 DOCUMENT_ROOT 확인용 간단한 스크립트
 * 
 * 사용 방법:
 * 1. 이 파일을 웹서버의 루트 디렉토리에 업로드
 * 2. 웹 브라우저에서 접속: https://cheng80.myqnapcloud.com/check_phpinfo.php
 * 3. DOCUMENT_ROOT 경로 확인
 */

header('Content-Type: text/plain; charset=utf-8');

echo "=== PHP 웹서버 경로 정보 ===\n\n";

echo "1. DOCUMENT_ROOT (웹서버 루트 경로):\n";
echo "   " . ($_SERVER['DOCUMENT_ROOT'] ?? 'N/A') . "\n\n";

echo "2. SCRIPT_FILENAME (현재 스크립트 실제 경로):\n";
echo "   " . ($_SERVER['SCRIPT_FILENAME'] ?? 'N/A') . "\n\n";

echo "3. 추천 model 디렉토리 경로:\n";
$docRoot = $_SERVER['DOCUMENT_ROOT'] ?? '';
if ($docRoot) {
    echo "   " . $docRoot . "/model\n\n";
} else {
    echo "   DOCUMENT_ROOT를 확인할 수 없습니다.\n\n";
}

echo "4. upload_tmp_dir:\n";
echo "   " . ini_get('upload_tmp_dir') . "\n\n";

echo "5. open_basedir:\n";
echo "   " . ini_get('open_basedir') . "\n\n";

echo "=== FastAPI 설정 예시 ===\n\n";
if ($docRoot) {
    echo "fastapi/app/api/product.py 파일에서:\n";
    echo "PHP_MODEL_DIR_STR = \"" . $docRoot . "/model\"\n";
    echo "PHP_WEB_SERVER_URL = \"https://cheng80.myqnapcloud.com\"\n\n";
    
    echo "또는 환경 변수로:\n";
    echo "export PHP_MODEL_DIR=\"" . $docRoot . "/model\"\n";
    echo "export PHP_WEB_SERVER_URL=\"https://cheng80.myqnapcloud.com\"\n";
} else {
    echo "DOCUMENT_ROOT를 확인할 수 없습니다.\n";
}

