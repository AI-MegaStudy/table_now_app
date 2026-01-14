#!/usr/bin/env python3
"""
제품 이미지 업로드 테스트 스크립트
FastAPI 서버에 파일 업로드를 테스트합니다.

사용 방법:
    python test_upload.py [product_seq] [image_path]

예시:
    python test_upload.py 1 /path/to/test_image.jpg
"""

import sys
import requests
from pathlib import Path

def test_upload_image(product_seq: int, image_path: str, api_base_url: str = "http://127.0.0.1:8000"):
    """
    제품 이미지 업로드 테스트
    
    Args:
        product_seq: 제품 시퀀스 번호
        image_path: 업로드할 이미지 파일 경로
        api_base_url: FastAPI 서버 URL
    """
    image_file = Path(image_path)
    
    if not image_file.exists():
        print(f"❌ 파일을 찾을 수 없습니다: {image_path}")
        return False
    
    if not image_file.is_file():
        print(f"❌ 파일이 아닙니다: {image_path}")
        return False
    
    # 파일 확장자 확인
    valid_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp']
    if image_file.suffix.lower() not in valid_extensions:
        print(f"❌ 지원하지 않는 이미지 형식입니다: {image_file.suffix}")
        print(f"   지원 형식: {', '.join(valid_extensions)}")
        return False
    
    print(f"📤 제품 이미지 업로드 테스트 시작")
    print(f"   제품 번호: {product_seq}")
    print(f"   파일: {image_path}")
    print(f"   파일 크기: {image_file.stat().st_size / 1024:.2f} KB")
    print(f"   API URL: {api_base_url}")
    print()
    
    try:
        # 파일 업로드
        url = f"{api_base_url}/api/products/{product_seq}/upload_file"
        
        with open(image_file, 'rb') as f:
            files = {
                'file': (image_file.name, f, 'image/jpeg')
            }
            data = {
                'file_type': 'image'
            }
            
            print(f"🔄 업로드 중...")
            print(f"   URL: {url}")
            
            response = requests.post(url, files=files, data=data, timeout=30)
            
            print(f"📥 응답 수신")
            print(f"   상태 코드: {response.status_code}")
            print(f"   응답 본문: {response.text[:500]}")
            print()
            
            if response.status_code == 200:
                result = response.json()
                if result.get('result') == 'OK' or 'file_url' in result:
                    print("✅ 업로드 성공!")
                    if 'file_url' in result:
                        print(f"   파일 URL: {result['file_url']}")
                    return True
                else:
                    print(f"❌ 업로드 실패: {result}")
                    return False
            else:
                print(f"❌ HTTP 오류: {response.status_code}")
                print(f"   응답: {response.text}")
                return False
                
    except requests.exceptions.ConnectionError:
        print(f"❌ 연결 실패: FastAPI 서버에 연결할 수 없습니다.")
        print(f"   서버가 실행 중인지 확인하세요: {api_base_url}")
        return False
    except Exception as e:
        print(f"❌ 오류 발생: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_upload_glb(product_seq: int, glb_path: str, model_name: str, api_base_url: str = "http://127.0.0.1:8000"):
    """
    GLB 모델 파일 업로드 테스트
    
    Args:
        product_seq: 제품 시퀀스 번호
        glb_path: 업로드할 GLB 파일 경로
        model_name: 모델 이름 (예: 'nike_v2k')
        api_base_url: FastAPI 서버 URL
    """
    glb_file = Path(glb_path)
    
    if not glb_file.exists():
        print(f"❌ 파일을 찾을 수 없습니다: {glb_path}")
        return False
    
    if glb_file.suffix.lower() != '.glb':
        print(f"❌ GLB 파일이 아닙니다: {glb_path}")
        return False
    
    print(f"📤 GLB 모델 파일 업로드 테스트 시작")
    print(f"   제품 번호: {product_seq}")
    print(f"   파일: {glb_path}")
    print(f"   모델명: {model_name}")
    print(f"   파일 크기: {glb_file.stat().st_size / 1024:.2f} KB")
    print(f"   API URL: {api_base_url}")
    print()
    
    try:
        url = f"{api_base_url}/api/products/{product_seq}/upload_file"
        
        with open(glb_file, 'rb') as f:
            files = {
                'file': (glb_file.name, f, 'model/gltf-binary')
            }
            data = {
                'file_type': 'glb',
                'model_name': model_name
            }
            
            print(f"🔄 업로드 중...")
            print(f"   URL: {url}")
            
            response = requests.post(url, files=files, data=data, timeout=60)
            
            print(f"📥 응답 수신")
            print(f"   상태 코드: {response.status_code}")
            print(f"   응답 본문: {response.text[:500]}")
            print()
            
            if response.status_code == 200:
                result = response.json()
                if result.get('result') == 'OK' or 'file_url' in result:
                    print("✅ 업로드 성공!")
                    if 'file_url' in result:
                        print(f"   파일 URL: {result['file_url']}")
                    return True
                else:
                    print(f"❌ 업로드 실패: {result}")
                    return False
            else:
                print(f"❌ HTTP 오류: {response.status_code}")
                print(f"   응답: {response.text}")
                return False
                
    except requests.exceptions.ConnectionError:
        print(f"❌ 연결 실패: FastAPI 서버에 연결할 수 없습니다.")
        print(f"   서버가 실행 중인지 확인하세요: {api_base_url}")
        return False
    except Exception as e:
        print(f"❌ 오류 발생: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("사용 방법:")
        print("  이미지 업로드: python test_upload.py <product_seq> <image_path>")
        print("  GLB 업로드:   python test_upload.py <product_seq> <glb_path> <model_name>")
        print()
        print("예시:")
        print("  python test_upload.py 1 /path/to/image.jpg")
        print("  python test_upload.py 1 /path/to/model.glb nike_v2k")
        sys.exit(1)
    
    product_seq = int(sys.argv[1])
    file_path = sys.argv[2]
    
    # API Base URL (환경 변수 또는 기본값)
    import os
    api_base_url = os.getenv("API_BASE_URL", "http://127.0.0.1:8000")
    
    # GLB 파일인지 확인
    if Path(file_path).suffix.lower() == '.glb':
        if len(sys.argv) < 4:
            print("❌ GLB 파일은 model_name이 필요합니다.")
            print("   사용 방법: python test_upload.py <product_seq> <glb_path> <model_name>")
            sys.exit(1)
        model_name = sys.argv[3]
        success = test_upload_glb(product_seq, file_path, model_name, api_base_url)
    else:
        success = test_upload_image(product_seq, file_path, api_base_url)
    
    sys.exit(0 if success else 1)

