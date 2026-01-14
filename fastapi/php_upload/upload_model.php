<?php
/**
 * 제품 GLB 모델 업로드 PHP 스크립트
 * NAS의 /share/Web/ 디렉토리에 배치
 * 
 * 역할: GLB 모델 파일 저장만 담당 (DB 업데이트는 FastAPI가 처리)
 * 
 * 사용 방법:
 *   POST https://cheng80.myqnapcloud.com/upload_model.php
 *   - file: 업로드할 GLB 파일 (multipart/form-data)
 *   - product_seq: 제품 번호
 *   - model_name: 모델명 (예: 'nike_v2k')
 * 
 * 반환:
 *   JSON 형식:
 *   {
 *     "result": "OK" 또는 "Error",
 *     "file_url": "https://cheng80.myqnapcloud.com/model.php?name=nike_v2k",
 *     "file_name": "nike_v2k.glb",
 *     "saved_path": "/share/Web/model/nike_v2k.glb",
 *     "file_path": "/share/Web/model/nike_v2k.glb",
 *     "errorMsg": "오류 메시지" (오류 시)
 *   }
 * 
 * 저장 경로:
 *   /share/Web/model/{model_name}.glb
 */

header('Content-Type: application/json; charset=utf-8');

// CORS 허용
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// OPTIONS 요청 처리 (CORS preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// POST 요청만 허용
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'result' => 'Error',
        'errorMsg' => 'POST 메서드만 허용됩니다.'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 필수 파라미터 확인
    if (!isset($_POST['product_seq'])) {
        throw new Exception('product_seq 파라미터가 필요합니다.');
    }
    
    if (!isset($_POST['model_name']) || empty(trim($_POST['model_name']))) {
        throw new Exception('model_name 파라미터가 필요합니다.');
    }
    
    $product_seq = intval($_POST['product_seq']);
    $model_name = trim($_POST['model_name']);
    
    // 모델명 검증 (안전한 파일명인지 확인)
    if (!preg_match('/^[a-zA-Z0-9_-]+$/', $model_name)) {
        throw new Exception('model_name은 영문, 숫자, 언더스코어(_), 하이픈(-)만 사용할 수 있습니다.');
    }
    
    // 파일 업로드 확인
    if (!isset($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK) {
        $error_msg = '파일 업로드 실패';
        if (isset($_FILES['file']['error'])) {
            switch ($_FILES['file']['error']) {
                case UPLOAD_ERR_INI_SIZE:
                case UPLOAD_ERR_FORM_SIZE:
                    $error_msg = '파일 크기가 너무 큽니다.';
                    break;
                case UPLOAD_ERR_PARTIAL:
                    $error_msg = '파일이 부분적으로만 업로드되었습니다.';
                    break;
                case UPLOAD_ERR_NO_FILE:
                    $error_msg = '파일이 업로드되지 않았습니다.';
                    break;
                case UPLOAD_ERR_NO_TMP_DIR:
                    $error_msg = '임시 폴더가 없습니다.';
                    break;
                case UPLOAD_ERR_CANT_WRITE:
                    $error_msg = '파일 쓰기 실패.';
                    break;
                case UPLOAD_ERR_EXTENSION:
                    $error_msg = '파일 업로드가 확장에 의해 중지되었습니다.';
                    break;
            }
        }
        throw new Exception($error_msg);
    }
    
    $uploaded_file = $_FILES['file'];
    $original_filename = $uploaded_file['name'];
    $tmp_path = $uploaded_file['tmp_name'];
    
    // GLB 파일 확장자 확인
    $file_ext = strtolower(pathinfo($original_filename, PATHINFO_EXTENSION));
    
    if ($file_ext !== 'glb') {
        throw new Exception('GLB 파일만 업로드 가능합니다. 업로드된 파일: ' . $file_ext);
    }
    
    // 파일명 생성: {model_name}.glb
    $file_name = $model_name . '.glb';
    $save_dir = '/share/Web/model';
    
    // 저장 디렉토리 확인 및 생성
    if (!is_dir($save_dir)) {
        if (!mkdir($save_dir, 0755, true)) {
            throw new Exception("디렉토리를 생성할 수 없습니다: {$save_dir}");
        }
    }
    
    // 쓰기 권한 확인
    if (!is_writable($save_dir)) {
        throw new Exception("디렉토리에 쓰기 권한이 없습니다: {$save_dir}");
    }
    
    // 저장할 파일 경로
    $save_path = $save_dir . '/' . $file_name;
    
    // 기존 파일이 있으면 삭제 (덮어쓰기)
    if (file_exists($save_path)) {
        unlink($save_path);
    }
    
    // 파일 이동
    if (!move_uploaded_file($tmp_path, $save_path)) {
        throw new Exception("파일 저장 실패: {$save_path}");
    }
    
    // 파일 권한 설정 (읽기 가능하도록)
    chmod($save_path, 0644);
    
    // 웹서버 URL 생성
    $web_server_url = 'https://cheng80.myqnapcloud.com';
    // GLB 파일: PHP 파일을 통해 접근 (model.php가 있다고 가정)
    $file_url = "{$web_server_url}/model.php?name={$model_name}";
    
    // 성공 응답 (파일 저장만 담당, DB 업데이트는 FastAPI가 처리)
    echo json_encode([
        'result' => 'OK',
        'file_url' => $file_url,
        'file_name' => $file_name,
        'file_type' => 'glb',
        'model_name' => $model_name,
        'saved_path' => $save_path,
        'file_path' => $save_path
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'result' => 'Error',
        'errorMsg' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}

