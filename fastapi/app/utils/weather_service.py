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
    
    def fetch_daily_weather(self, lat: str = DEFAULT_LAT, lon: str = DEFAULT_LON) -> List[Dict]:
        """
        OpenWeatherMap OneCall API에서 일별 날씨 데이터 가져오기
        
        Args:
            lat: 위도 (기본값: 서울)
            lon: 경도 (기본값: 서울)
            
        Returns:
            List[Dict]: 일별 날씨 데이터 리스트
            각 딕셔너리는 다음 키를 포함:
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
            
            if "daily" not in data:
                raise ValueError("API 응답에 'daily' 데이터가 없습니다.")
            
            daily_forecasts = []
            
            for day in data["daily"]:
                # Unix timestamp를 datetime으로 변환
                dt = datetime.fromtimestamp(day["dt"])
                # 날짜의 시작 시간 (00:00:00)으로 설정
                weather_datetime = dt.replace(hour=0, minute=0, second=0, microsecond=0)
                
                # 날씨 정보 추출
                weather_info = day["weather"][0] if day.get("weather") else {}
                weather_main = weather_info.get("main", "Clear")
                icon_code = weather_info.get("icon", "01d")
                
                # 온도 정보 추출
                temp = day.get("temp", {})
                weather_low = temp.get("min", 0.0)
                weather_high = temp.get("max", 0.0)
                
                daily_forecasts.append({
                    "dt": day["dt"],
                    "weather_datetime": weather_datetime,
                    "weather_type": get_weather_type_korean(weather_main),
                    "weather_type_en": weather_main,
                    "weather_low": float(weather_low),
                    "weather_high": float(weather_high),
                    "icon_code": icon_code,
                    "icon_url": get_weather_icon_url(icon_code)
                })
            
            return daily_forecasts
            
        except requests.RequestException as e:
            raise requests.RequestException(f"OpenWeatherMap API 요청 실패: {str(e)}") from e
        except (KeyError, ValueError, TypeError) as e:
            raise ValueError(f"API 응답 파싱 실패: {str(e)}") from e
    
    def save_weather_to_db(self, lat: str = DEFAULT_LAT, lon: str = DEFAULT_LON, 
                           overwrite: bool = False) -> Dict:
        """
        OpenWeatherMap API에서 날씨 데이터를 가져와서 데이터베이스에 저장
        
        Args:
            lat: 위도
            lon: 경도
            overwrite: 기존 데이터가 있으면 덮어쓸지 여부 (기본값: False)
            
        Returns:
            Dict: 저장 결과
            - success: 성공 여부
            - inserted_count: 삽입된 레코드 수
            - updated_count: 업데이트된 레코드 수
            - errors: 에러 리스트
        """
        conn = None
        curs = None
        
        try:
            # API에서 데이터 가져오기
            daily_forecasts = self.fetch_daily_weather(lat, lon)
            
            if not daily_forecasts:
                return {
                    "success": False,
                    "message": "가져올 날씨 데이터가 없습니다.",
                    "inserted_count": 0,
                    "updated_count": 0,
                    "errors": []
                }
            
            # 데이터베이스 연결
            conn = connect_db()
            curs = conn.cursor()
            
            inserted_count = 0
            updated_count = 0
            errors = []
            
            for forecast in daily_forecasts:
                try:
                    weather_datetime = forecast["weather_datetime"]
                    weather_type = forecast["weather_type"]
                    weather_low = forecast["weather_low"]
                    weather_high = forecast["weather_high"]
                    
                    # 기존 데이터 확인
                    curs.execute("""
                        SELECT weather_datetime FROM weather 
                        WHERE weather_datetime = %s
                    """, (weather_datetime,))
                    existing = curs.fetchone()
                    
                    if existing:
                        if overwrite:
                            # 업데이트 (icon_code 제거)
                            curs.execute("""
                                UPDATE weather 
                                SET weather_type = %s, weather_low = %s, weather_high = %s
                                WHERE weather_datetime = %s
                            """, (weather_type, weather_low, weather_high, weather_datetime))
                            updated_count += 1
                        else:
                            # 건너뛰기
                            continue
                    else:
                        # 삽입 (icon_code 제거)
                        curs.execute("""
                            INSERT INTO weather (weather_datetime, weather_type, weather_low, weather_high)
                            VALUES (%s, %s, %s, %s)
                        """, (weather_datetime, weather_type, weather_low, weather_high))
                        inserted_count += 1
                        
                except Exception as e:
                    errors.append({
                        "datetime": forecast.get("weather_datetime"),
                        "error": str(e)
                    })
            
            conn.commit()
            
            return {
                "success": True,
                "message": f"날씨 데이터 저장 완료 (삽입: {inserted_count}, 업데이트: {updated_count})",
                "inserted_count": inserted_count,
                "updated_count": updated_count,
                "errors": errors
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
