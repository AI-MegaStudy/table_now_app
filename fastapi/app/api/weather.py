"""
Weather API - 날씨 데이터 CRUD 및 OpenWeatherMap API 연동
작성일: 2026-01-15
작성자: 김택권
"""

from fastapi import APIRouter, Form, Query, HTTPException
from typing import Optional
from datetime import datetime
from ..database.connection import connect_db
from ..utils.weather_service import WeatherService

router = APIRouter()


# ============================================
# 전체 날씨 데이터 조회
# ============================================
@router.get("")
async def select_weathers(
    start_date: Optional[str] = Query(None, description="시작 날짜 (YYYY-MM-DD)"),
    end_date: Optional[str] = Query(None, description="종료 날짜 (YYYY-MM-DD)")
):
    """
    전체 날씨 데이터 조회
    - start_date와 end_date가 제공되면 해당 기간의 데이터만 조회
    """
    try:
        conn = connect_db()
        curs = conn.cursor()
        
        if start_date and end_date:
            # 기간별 조회
            curs.execute("""
                SELECT weather_datetime, weather_type, weather_low, weather_high
                FROM weather
                WHERE weather_datetime >= %s AND weather_datetime <= %s
                ORDER BY weather_datetime
            """, (start_date, end_date))
        else:
            # 전체 조회
            curs.execute("""
                SELECT weather_datetime, weather_type, weather_low, weather_high
                FROM weather
                ORDER BY weather_datetime
            """)
        
        rows = curs.fetchall()
        conn.close()
        
        result = []
        for row in rows:
            weather_datetime = row[0]
            if isinstance(weather_datetime, datetime):
                weather_datetime = weather_datetime.isoformat()
            elif hasattr(weather_datetime, 'isoformat'):
                weather_datetime = weather_datetime.isoformat()
            else:
                weather_datetime = str(weather_datetime)
            
            # weather_type을 기반으로 아이콘 코드 결정
            weather_type = row[1]
            from ..utils.weather_mapping import get_default_icon_code
            icon_code = get_default_icon_code(weather_type)
            from ..utils.weather_mapping import get_weather_icon_url
            icon_url = get_weather_icon_url(icon_code)
            
            result.append({
                'weather_datetime': weather_datetime,
                'weather_type': weather_type,
                'weather_low': float(row[2]),
                'weather_high': float(row[3]),
                'icon_url': icon_url
            })
        
        return {"results": result}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}


# ============================================
# 특정 날짜의 날씨 데이터 조회
# ============================================
@router.get("/{weather_datetime}")
async def select_weather(weather_datetime: str):
    """
    특정 날짜의 날씨 데이터 조회
    - weather_datetime: 날짜 (YYYY-MM-DD 또는 YYYY-MM-DD HH:MM:SS)
    """
    try:
        conn = connect_db()
        curs = conn.cursor()
        
        # 날짜 형식 정규화 (시간이 없으면 00:00:00 추가)
        if len(weather_datetime) == 10:  # YYYY-MM-DD
            weather_datetime = f"{weather_datetime} 00:00:00"
        
        curs.execute("""
            SELECT weather_datetime, weather_type, weather_low, weather_high
            FROM weather
            WHERE weather_datetime = %s
        """, (weather_datetime,))
        
        row = curs.fetchone()
        conn.close()
        
        if row is None:
            return {"result": "Error", "message": "날씨 데이터를 찾을 수 없습니다."}
        
        weather_datetime_val = row[0]
        if isinstance(weather_datetime_val, datetime):
            weather_datetime_val = weather_datetime_val.isoformat()
        elif hasattr(weather_datetime_val, 'isoformat'):
            weather_datetime_val = weather_datetime_val.isoformat()
        else:
            weather_datetime_val = str(weather_datetime_val)
        
        # weather_type을 기반으로 아이콘 코드 결정
        weather_type = row[1]
        from ..utils.weather_mapping import get_default_icon_code, get_weather_icon_url
        icon_code = get_default_icon_code(weather_type)
        icon_url = get_weather_icon_url(icon_code)
        
        result = {
            'weather_datetime': weather_datetime_val,
            'weather_type': weather_type,
            'weather_low': float(row[2]),
            'weather_high': float(row[3]),
            'icon_url': icon_url
        }
        return {"result": result}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}


# ============================================
# 날씨 데이터 수동 추가
# ============================================
@router.post("")
async def insert_weather(
    weather_datetime: str = Form(..., description="날짜 (YYYY-MM-DD 또는 YYYY-MM-DD HH:MM:SS)"),
    weather_type: str = Form(..., description="날씨 상태 (한글)"),
    weather_low: float = Form(..., description="최저 온도"),
    weather_high: float = Form(..., description="최고 온도")
):
    """
    날씨 데이터 수동 추가
    """
    conn = connect_db()
    curs = conn.cursor()
    
    try:
        # 날짜 형식 정규화
        if len(weather_datetime) == 10:  # YYYY-MM-DD
            weather_datetime = f"{weather_datetime} 00:00:00"
        
        # 중복 확인
        curs.execute("""
            SELECT weather_datetime FROM weather WHERE weather_datetime = %s
        """, (weather_datetime,))
        existing = curs.fetchone()
        
        if existing:
            return {
                "result": "Error",
                "errorMsg": "해당 날짜의 날씨 데이터가 이미 존재합니다."
            }
        
        # 삽입
        curs.execute("""
            INSERT INTO weather (weather_datetime, weather_type, weather_low, weather_high)
            VALUES (%s, %s, %s, %s)
        """, (weather_datetime, weather_type, weather_low, weather_high))
        
        conn.commit()
        
        return {
            "result": "OK",
            "message": "날씨 데이터가 추가되었습니다."
        }
    except Exception as e:
        conn.rollback()
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {
            "result": "Error",
            "errorMsg": error_msg,
            "traceback": traceback.format_exc()
        }
    finally:
        conn.close()


# ============================================
# 날씨 데이터 수정
# ============================================
@router.put("/{weather_datetime}")
async def update_weather(
    weather_datetime: str,
    weather_type: Optional[str] = Form(None),
    weather_low: Optional[float] = Form(None),
    weather_high: Optional[float] = Form(None)
):
    """
    날씨 데이터 수정
    """
    conn = connect_db()
    curs = conn.cursor()
    
    try:
        # 날짜 형식 정규화
        if len(weather_datetime) == 10:
            weather_datetime = f"{weather_datetime} 00:00:00"
        
        # 기존 데이터 확인
        curs.execute("""
            SELECT weather_type, weather_low, weather_high
            FROM weather
            WHERE weather_datetime = %s
        """, (weather_datetime,))
        existing = curs.fetchone()
        
        if existing is None:
            return {
                "result": "Error",
                "errorMsg": "날씨 데이터를 찾을 수 없습니다."
            }
        
        # 업데이트할 값 결정
        update_type = weather_type if weather_type is not None else existing[0]
        update_low = weather_low if weather_low is not None else existing[1]
        update_high = weather_high if weather_high is not None else existing[2]
        
        # 업데이트
        curs.execute("""
            UPDATE weather
            SET weather_type = %s, weather_low = %s, weather_high = %s
            WHERE weather_datetime = %s
        """, (update_type, update_low, update_high, weather_datetime))
        
        conn.commit()
        
        return {"result": "OK"}
    except Exception as e:
        conn.rollback()
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {
            "result": "Error",
            "errorMsg": error_msg,
            "traceback": traceback.format_exc()
        }
    finally:
        conn.close()


# ============================================
# 날씨 데이터 삭제
# ============================================
@router.delete("/{weather_datetime}")
async def delete_weather(weather_datetime: str):
    """
    날씨 데이터 삭제
    """
    try:
        conn = connect_db()
        curs = conn.cursor()
        
        # 날짜 형식 정규화
        if len(weather_datetime) == 10:
            weather_datetime = f"{weather_datetime} 00:00:00"
        
        # 존재 확인
        curs.execute("""
            SELECT weather_datetime FROM weather WHERE weather_datetime = %s
        """, (weather_datetime,))
        existing = curs.fetchone()
        
        if existing is None:
            return {
                "result": "Error",
                "errorMsg": "날씨 데이터를 찾을 수 없습니다."
            }
        
        # 삭제
        curs.execute("DELETE FROM weather WHERE weather_datetime = %s", (weather_datetime,))
        conn.commit()
        conn.close()
        
        return {"result": "OK"}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {
            "result": "Error",
            "errorMsg": error_msg,
            "traceback": traceback.format_exc()
        }


# ============================================
# OpenWeatherMap API에서 날씨 데이터 가져오기 및 저장
# ============================================
@router.post("/fetch-from-api")
async def fetch_weather_from_api(
    lat: Optional[str] = Form(None, description="위도 (기본값: 서울)"),
    lon: Optional[str] = Form(None, description="경도 (기본값: 서울)"),
    overwrite: bool = Form(False, description="기존 데이터 덮어쓰기 여부")
):
    """
    OpenWeatherMap API에서 날씨 데이터를 가져와서 데이터베이스에 저장
    
    - lat, lon이 제공되지 않으면 서울 좌표 사용
    - 최대 8일치 데이터를 가져옴 (오늘 포함)
    """
    try:
        weather_service = WeatherService()
        # lat, lon이 None이면 기본값(서울) 사용
        from ..utils.weather_service import DEFAULT_LAT, DEFAULT_LON
        result = weather_service.save_weather_to_db(
            lat=lat if lat else DEFAULT_LAT,
            lon=lon if lon else DEFAULT_LON,
            overwrite=overwrite
        )
        
        if result["success"]:
            return {
                "result": "OK",
                "message": result["message"],
                "inserted_count": result["inserted_count"],
                "updated_count": result["updated_count"],
                "errors": result["errors"]
            }
        else:
            raise HTTPException(status_code=500, detail=result["message"])
            
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {
            "result": "Error",
            "errorMsg": error_msg,
            "traceback": traceback.format_exc()
        }


# ============================================================
# 생성 이력
# ============================================================
# 작성일: 2026-01-15
# 작성자: 김택권
# 설명: Weather API - 날씨 데이터 CRUD 및 OpenWeatherMap API 연동
#
# ============================================================
# 수정 이력
# ============================================================
# 2026-01-15 김택권: 초기 생성
#   - 날씨 데이터 CRUD 엔드포인트 구현 (select_weathers, select_weather, insert_weather, update_weather, delete_weather)
#   - OpenWeatherMap API 연동 엔드포인트 구현 (fetch_weather_from_api)
#   - 날짜 형식 정규화 처리 (YYYY-MM-DD → YYYY-MM-DD 00:00:00)
#   - 기간별 조회 기능 추가 (start_date, end_date)
#
# 2026-01-15 김택권: OpenWeatherMap API 호출 버그 수정
#   - lat, lon이 None일 때 기본값(서울 좌표)을 사용하도록 수정
#   - None 값이 API URL에 포함되어 400 에러가 발생하던 문제 해결