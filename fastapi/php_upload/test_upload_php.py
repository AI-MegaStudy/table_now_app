#!/usr/bin/env python3
"""
PHP 파일 업로드 테스트 스크립트
FastAPI를 통해 PHP로 이미지 업로드 테스트

사용 방법:
    python test_upload_php.py
"""

import requests
from pathlib import Path
import sys

# 테스트 이미지 파일 경로 (php_upload 폴더에서 상위로 올라가서 images 폴더 접근)
TEST_IMAGE = Path(__file__).parent.parent.parent / "images" / "Nike_Air_1_Black_01.png"
API_BASE_URL = "http://127.0.0.1:8000"
PRODUCT_SEQ = 1  # 테스트용 제품 번호

def test_upload():
    """PHP를 통한 이미지 업로드 테스트"""
    
    if not TEST_IMAGE.exists():
        print(f"❌ 테스트 이미지를 찾을 수 없습니다: {TEST_IMAGE}")
        print(f"   다른 이미지 파일 경로를 지정하세요.")
        return False
    
    print("=" * 60)
    print("PHP 파일 업로드 테스트 (FastAPI 경유)")
    print("=" * 60)
    print(f"FastAPI URL: {API_BASE_URL}")
    print(f"제품 번호: {PRODUCT_SEQ}")
    print(f"테스트 이미지: {TEST_IMAGE}")
    print(f"파일 크기: {TEST_IMAGE.stat().st_size / 1024:.2f} KB")
    print()
    
    # 1. FastAPI 서버 연결 확인
    print("1️⃣ FastAPI 서버 연결 확인...")
    try:
        response = requests.get(f"{API_BASE_URL}/health", timeout=2)
        if response.status_code == 200:
            print("   ✅ FastAPI 서버 연결 성공")
        else:
            print(f"   ⚠️  서버 응답: {response.status_code}")
    except requests.exceptions.ConnectionError:
        print("   ❌ FastAPI 서버에 연결할 수 없습니다.")
        print("   서버가 실행 중인지 확인하세요:")
        print("   cd fastapi && uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload")
        return False
    except Exception as e:
        print(f"   ❌ 오류: {e}")
        return False
    
    print()
    
    # 2. 제품 존재 확인
    print("2️⃣ 제품 존재 확인...")
    try:
        response = requests.get(f"{API_BASE_URL}/api/products/{PRODUCT_SEQ}", timeout=5)
        if response.status_code == 200:
            product_data = response.json()
            if product_data.get('result') != 'Error':
                print(f"   ✅ 제품 {PRODUCT_SEQ} 존재 확인")
                product_name = product_data.get('result', {}).get('p_name', 'N/A')
                print(f"   제품명: {product_name}")
            else:
                print(f"   ⚠️  제품 {PRODUCT_SEQ}를 찾을 수 없습니다.")
                print("   다른 제품 번호를 사용하거나 제품을 먼저 생성하세요.")
        else:
            print(f"   ⚠️  제품 조회 실패: {response.status_code}")
    except Exception as e:
        print(f"   ⚠️  제품 조회 중 오류: {e}")
    
    print()
    
    # 3. 파일 업로드 (FastAPI → PHP)
    print("3️⃣ 파일 업로드 테스트 (FastAPI → PHP)...")
    try:
        url = f"{API_BASE_URL}/api/products/{PRODUCT_SEQ}/upload_file"
        
        with open(TEST_IMAGE, 'rb') as f:
            files = {
                'file': (TEST_IMAGE.name, f, 'image/png')
            }
            data = {
                'file_type': 'image'
            }
            
            print(f"   업로드 URL: {url}")
            print(f"   파일: {TEST_IMAGE.name}")
            print(f"   파일 타입: image")
            print()
            print("   FastAPI가 PHP로 파일을 전달합니다...")
            print(f"   PHP 스크립트: https://cheng80.myqnapcloud.com/upload_image.php")
            
            response = requests.post(url, files=files, data=data, timeout=30)
            
            print(f"   HTTP 상태 코드: {response.status_code}")
            
            if response.status_code == 200:
                result = response.json()
                print()
                print("   ✅ 업로드 성공!")
                print(f"   응답: {result}")
                
                if result.get('result') == 'OK':
                    file_url = result.get('file_url')
                    saved_path = result.get('saved_path')
                    file_name = result.get('file_name')
                    
                    print()
                    print("=" * 60)
                    print("업로드 결과:")
                    print("=" * 60)
                    print(f"   파일명: {file_name}")
                    print(f"   저장 경로: {saved_path}")
                    print(f"   웹 URL: {file_url}")
                    print("=" * 60)
                    print()
                    print("✅ NAS의 /share/Web/images/ 디렉토리에서 파일을 확인하세요.")
                    print(f"   예상 파일명: {file_name}")
                    print()
                    print("웹 브라우저에서 접속하여 파일이 정상적으로 저장되었는지 확인:")
                    print(f"   {file_url}")
                    
                    return True
                else:
                    error_msg = result.get('errorMsg', '알 수 없는 오류')
                    print(f"   ❌ 업로드 실패: {error_msg}")
                    return False
            else:
                print(f"   ❌ 업로드 실패")
                print(f"   응답: {response.text}")
                return False
                
    except requests.exceptions.Timeout:
        print("   ❌ 요청 시간 초과")
        return False
    except Exception as e:
        print(f"   ❌ 오류 발생: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    print()
    success = test_upload()
    print()
    if success:
        print("✅ 테스트 완료!")
        print()
        print("다음 단계:")
        print("1. NAS의 /share/Web/images/ 디렉토리에서 파일 확인")
        print("2. 웹 브라우저에서 URL 접속하여 이미지 확인")
        print("3. DB의 product 테이블에서 p_image 필드 확인")
        sys.exit(0)
    else:
        print("❌ 테스트 실패")
        sys.exit(1)

