"""
OpenWeatherMap API 서비스
날씨 데이터를 가져와서 데이터베이스에 저장하는 서비스
작성일: 2026-01-15
작성자: 김택권
"""

import os
import requests
from datetime import datetime
from typing import List, Dict, Optional
from dotenv import load_dotenv
from ..database.connection import connect_db  # noqa: E402
from .weather_mapping import get_weather_type_korean, get_weather_icon_url  # noqa: E402

# .env 파일에서 환경변수 로드
env_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), '.env')
load_dotenv(dotenv_path=env_path)

# OpenWeatherMap API 설정
OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY")
OPENWEATHER_BASE_URL = "https://api.openweathermap.org/data/3.0/onecall"

# 기본 위치 설정 (서울)
DEFAULT_LAT = "37.5665"
DEFAULT_LON = "126.9780"


class WeatherService:
    """OpenWeatherMap API를 사용하여 날씨 데이터를 가져오는 서비스"""
    
    def __init__(self, api_key: Optional[str] = None):
        """
        WeatherService 초기화
        
        Args:
            api_key: OpenWeatherMap API 키 (None이면 환경변수에서 가져옴)
        """
        self.api_key = api_key or OPENWEATHER_API_KEY
        if not self.api_key:
            raise ValueError("OpenWeatherMap API 키가 설정되지 않았습니다. 환경변수 OPENWEATHER_API_KEY를 설정하거나 api_key 파라미터를 제공하세요.")
    
    def fetch_today_weather(self, lat: str = DEFAULT_LAT, lon: str = DEFAULT_LON) -> Dict:
        """
        OpenWeatherMap OneCall API에서 오늘 날씨 데이터만 가져오기
        
        Args:
            lat: 위도 (기본값: 서울)
            lon: 경도 (기본값: 서울)
            
        Returns:
            Dict: 오늘 날씨 데이터
            다음 키를 포함:
            - dt: Unix timestamp
            - weather_datetime: DATETIME 형식의 날짜 (00:00:00)
            - weather_type: 날씨 상태 (한글)
            - weather_type_en: 날씨 상태 (영문)
            - weather_low: 최저 온도
            - weather_high: 최고 온도
            - icon_code: 아이콘 코드
            - icon_url: 아이콘 URL
            
        Raises:
            requests.RequestException: API 요청 실패 시
            ValueError: API 응답이 유효하지 않을 때
        """
        url = f"{OPENWEATHER_BASE_URL}?lat={lat}&lon={lon}&units=metric&exclude=minutely,alerts&appid={self.api_key}"
        
        try:
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            if "daily" not in data or len(data["daily"]) == 0:
                raise ValueError("API 응답에 'daily' 데이터가 없습니다.")
            
            # 오늘 날씨만 가져오기 (첫 번째 요소)
            today = data["daily"][0]
            
            # Unix timestamp를 datetime으로 변환
            dt = datetime.fromtimestamp(today["dt"])
            # 날짜의 시작 시간 (00:00:00)으로 설정
            weather_datetime = dt.replace(hour=0, minute=0, second=0, microsecond=0)
            
            # 날씨 정보 추출
            weather_info = today["weather"][0] if today.get("weather") else {}
            weather_main = weather_info.get("main", "Clear")
            icon_code = weather_info.get("icon", "01d")
            
            # 온도 정보 추출
            temp = today.get("temp", {})
            weather_low = temp.get("min", 0.0)
            weather_high = temp.get("max", 0.0)
            
            return {
                "dt": today["dt"],
                "weather_datetime": weather_datetime,
                "weather_type": get_weather_type_korean(weather_main),
                "weather_type_en": weather_main,
                "weather_low": float(weather_low),
                "weather_high": float(weather_high),
                "icon_code": icon_code,
                "icon_url": get_weather_icon_url(icon_code)
            }
            
        except requests.RequestException as e:
            raise requests.RequestException(f"OpenWeatherMap API 요청 실패: {str(e)}") from e
        except (KeyError, ValueError, TypeError) as e:
            raise ValueError(f"API 응답 파싱 실패: {str(e)}") from e
    
    def save_weather_to_db(self, store_seq: int, overwrite: bool = True) -> Dict:
        """
        OpenWeatherMap API에서 오늘 날씨 데이터를 가져와서 데이터베이스에 저장
        
        Args:
            store_seq: 식당 번호 (store 테이블의 store_seq)
            overwrite: 기존 데이터가 있으면 덮어쓸지 여부 (기본값: True)
            
        Returns:
            Dict: 저장 결과
            - success: 성공 여부
            - inserted: 삽입 여부 (True면 INSERT, False면 UPDATE)
            - message: 결과 메시지
            - errors: 에러 리스트
        """
        conn = None
        curs = None
        
        try:
            # store 정보 조회 (store_lat, store_lng 가져오기)
            conn = connect_db()
            curs = conn.cursor()
            
            curs.execute("""
                SELECT store_lat, store_lng FROM store WHERE store_seq = %s
            """, (store_seq,))
            
            store_row = curs.fetchone()
            if not store_row:
                return {
                    "success": False,
                    "message": f"store_seq={store_seq}인 식당을 찾을 수 없습니다.",
                    "inserted": False,
                    "errors": []
                }
            
            store_lat = str(store_row[0])
            store_lng = str(store_row[1])
            
            # API에서 오늘 날씨 데이터 가져오기
            today_forecast = self.fetch_today_weather(store_lat, store_lng)
            
            if not today_forecast:
                return {
                    "success": False,
                    "message": "가져올 날씨 데이터가 없습니다.",
                    "inserted": False,
                    "errors": []
                }
            
            weather_datetime = today_forecast["weather_datetime"]
            weather_type = today_forecast["weather_type"]
            weather_low = today_forecast["weather_low"]
            weather_high = today_forecast["weather_high"]
            
            # 오늘 날씨 데이터만 저장 (기존 데이터는 삭제하지 않음 - 예약 데이터 참조 유지)
            # UPSERT 패턴: 이미 있으면 업데이트, 없으면 삽입
            curs.execute("""
                SELECT weather_datetime FROM weather 
                WHERE store_seq = %s AND weather_datetime = %s
            """, (store_seq, weather_datetime))
            existing_new = curs.fetchone()
            
            if not existing_new:
                # 새로운 데이터가 없으면 삽입
                curs.execute("""
                    INSERT INTO weather (store_seq, weather_datetime, weather_type, weather_low, weather_high)
                    VALUES (%s, %s, %s, %s, %s)
                """, (store_seq, weather_datetime, weather_type, weather_low, weather_high))
                is_inserted = True
            else:
                # 이미 있으면 업데이트 (날씨 예보는 시간이 지나면서 업데이트될 수 있음)
                curs.execute("""
                    UPDATE weather 
                    SET weather_type = %s, weather_low = %s, weather_high = %s
                    WHERE store_seq = %s AND weather_datetime = %s
                """, (weather_type, weather_low, weather_high, store_seq, weather_datetime))
                is_inserted = False
            
            # reserve 테이블의 weather_datetime은 변경하지 않음 (예약한 날짜의 날씨를 유지)
            
            conn.commit()
            
            action = "삽입" if is_inserted else "업데이트"
            return {
                "success": True,
                "message": f"날씨 데이터 저장 완료 ({action})",
                "inserted": is_inserted,
                "errors": []
            }
            
        except Exception as e:
            if conn:
                conn.rollback()
            return {
                "success": False,
                "message": f"날씨 데이터 저장 실패: {str(e)}",
                "inserted_count": 0,
                "updated_count": 0,
                "errors": [{"error": str(e)}]
            }
        finally:
            if curs:
                curs.close()
            if conn:
                conn.close()


# ============================================================
# 생성 이력
# ============================================================
# 작성일: 2026-01-15
# 작성자: 김택권
# 설명: OpenWeatherMap API 서비스 - 날씨 데이터를 가져와서 데이터베이스에 저장하는 서비스
#
# ============================================================
# 수정 이력
# ============================================================
# 2026-01-15 김택권: 초기 생성
#   - OpenWeatherMap OneCall API 연동 구현
#   - 일별 날씨 데이터 가져오기 기능 (fetch_daily_weather)
#   - 날씨 데이터를 데이터베이스에 저장하는 기능 (save_weather_to_db)
#   - 환경변수에서 API 키 로드 (OPENWEATHER_API_KEY)
#   - 날씨 타입 한글 변환 및 아이콘 URL 생성 기능 연동
#
# 2026-01-15 김택권: OpenWeatherMap API 키 환경변수 사용
#   - .env 파일에서 OPENWEATHER_API_KEY 환경변수 로드
#   - 보안을 위해 코드에 하드코딩하지 않고 환경변수만 사용
