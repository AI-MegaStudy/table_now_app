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
    store_seq: Optional[int] = Query(None, description="식당 번호 (필수)"),
    start_date: Optional[str] = Query(None, description="시작 날짜 (YYYY-MM-DD)"),
    end_date: Optional[str] = Query(None, description="종료 날짜 (YYYY-MM-DD)")
):
    """
    날씨 데이터 조회
    - store_seq: 식당 번호 (필수)
    - start_date와 end_date가 제공되면 해당 기간의 데이터만 조회
    """
    try:
        if store_seq is None:
            return {
                "result": "Error",
                "errorMsg": "store_seq 파라미터가 필요합니다."
            }
        
        conn = connect_db()
        curs = conn.cursor()
        
        if start_date and end_date:
            # 기간별 조회
            curs.execute("""
                SELECT store_seq, weather_datetime, weather_type, weather_low, weather_high
                FROM weather
                WHERE store_seq = %s AND weather_datetime >= %s AND weather_datetime <= %s
                ORDER BY weather_datetime
            """, (store_seq, start_date, end_date))
        else:
            # 전체 조회 (해당 store_seq의 모든 날씨 데이터)
            curs.execute("""
                SELECT store_seq, weather_datetime, weather_type, weather_low, weather_high
                FROM weather
                WHERE store_seq = %s
                ORDER BY weather_datetime
            """, (store_seq,))
        
        rows = curs.fetchall()
        conn.close()
        
        result = []
        for row in rows:
            weather_datetime = row[1]
            if isinstance(weather_datetime, datetime):
                weather_datetime = weather_datetime.isoformat()
            elif hasattr(weather_datetime, 'isoformat'):
                weather_datetime = weather_datetime.isoformat()
            else:
                weather_datetime = str(weather_datetime)
            
            # weather_type을 기반으로 아이콘 코드 결정
            weather_type = row[2]
            from ..utils.weather_mapping import get_default_icon_code
            icon_code = get_default_icon_code(weather_type)
            from ..utils.weather_mapping import get_weather_icon_url
            icon_url = get_weather_icon_url(icon_code)
            
            result.append({
                'store_seq': row[0],
                'weather_datetime': weather_datetime,
                'weather_type': weather_type,
                'weather_low': float(row[3]),
                'weather_high': float(row[4]),
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
@router.get("/{store_seq}/{weather_datetime}")
async def select_weather(store_seq: int, weather_datetime: str):
    """
    특정 식당의 특정 날짜 날씨 데이터 조회
    - store_seq: 식당 번호
    - weather_datetime: 날짜 (YYYY-MM-DD 또는 YYYY-MM-DD HH:MM:SS)
    """
    try:
        conn = connect_db()
        curs = conn.cursor()
        
        # 날짜 형식 정규화 (시간이 없으면 00:00:00 추가)
        if len(weather_datetime) == 10:  # YYYY-MM-DD
            weather_datetime = f"{weather_datetime} 00:00:00"
        
        curs.execute("""
            SELECT store_seq, weather_datetime, weather_type, weather_low, weather_high
            FROM weather
            WHERE store_seq = %s AND weather_datetime = %s
        """, (store_seq, weather_datetime))
        
        row = curs.fetchone()
        conn.close()
        
        if row is None:
            return {"result": "Error", "message": "날씨 데이터를 찾을 수 없습니다."}
        
        weather_datetime_val = row[1]
        if isinstance(weather_datetime_val, datetime):
            weather_datetime_val = weather_datetime_val.isoformat()
        elif hasattr(weather_datetime_val, 'isoformat'):
            weather_datetime_val = weather_datetime_val.isoformat()
        else:
            weather_datetime_val = str(weather_datetime_val)
        
        # weather_type을 기반으로 아이콘 코드 결정
        weather_type = row[2]
        from ..utils.weather_mapping import get_default_icon_code, get_weather_icon_url
        icon_code = get_default_icon_code(weather_type)
        icon_url = get_weather_icon_url(icon_code)
        
        result = {
            'store_seq': row[0],
            'weather_datetime': weather_datetime_val,
            'weather_type': weather_type,
            'weather_low': float(row[3]),
            'weather_high': float(row[4]),
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
    store_seq: int = Form(..., description="식당 번호"),
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
        
        # 중복 확인 (store_seq와 weather_datetime 복합키)
        curs.execute("""
            SELECT weather_datetime FROM weather 
            WHERE store_seq = %s AND weather_datetime = %s
        """, (store_seq, weather_datetime))
        existing = curs.fetchone()
        
        if existing:
            return {
                "result": "Error",
                "errorMsg": "해당 식당의 해당 날짜 날씨 데이터가 이미 존재합니다."
            }
        
        # 삽입
        curs.execute("""
            INSERT INTO weather (store_seq, weather_datetime, weather_type, weather_low, weather_high)
            VALUES (%s, %s, %s, %s, %s)
        """, (store_seq, weather_datetime, weather_type, weather_low, weather_high))
        
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
@router.put("/{store_seq}/{weather_datetime}")
async def update_weather(
    store_seq: int,
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
            WHERE store_seq = %s AND weather_datetime = %s
        """, (store_seq, weather_datetime))
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
            WHERE store_seq = %s AND weather_datetime = %s
        """, (update_type, update_low, update_high, store_seq, weather_datetime))
        
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
@router.delete("/{store_seq}/{weather_datetime}")
async def delete_weather(store_seq: int, weather_datetime: str):
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
            SELECT weather_datetime FROM weather 
            WHERE store_seq = %s AND weather_datetime = %s
        """, (store_seq, weather_datetime))
        existing = curs.fetchone()
        
        if existing is None:
            return {
                "result": "Error",
                "errorMsg": "날씨 데이터를 찾을 수 없습니다."
            }
        
        # reserve 테이블에서 참조 중인지 확인
        curs.execute("""
            SELECT COUNT(*) FROM reserve 
            WHERE store_seq = %s AND weather_datetime = %s
        """, (store_seq, weather_datetime))
        reserve_count = curs.fetchone()[0]
        
        if reserve_count > 0:
            return {
                "result": "Error",
                "errorMsg": f"예약 데이터가 {reserve_count}개 참조 중이어서 삭제할 수 없습니다. 예약 데이터를 먼저 삭제하거나 수정해주세요."
            }
        
        # 삭제 (참조가 없을 때만)
        curs.execute("""
            DELETE FROM weather 
            WHERE store_seq = %s AND weather_datetime = %s
        """, (store_seq, weather_datetime))
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
    store_seq: int = Form(..., description="식당 번호 (필수)"),
    target_date: Optional[str] = Form(None, description="저장할 날짜 (YYYY-MM-DD), 없으면 오늘 날짜"),
    overwrite: bool = Form(True, description="기존 데이터 덮어쓰기 여부 (기본값: True - 날씨 예보는 항상 최신으로 갱신)")
):
    """
    OpenWeatherMap API에서 날씨 데이터를 가져와서 데이터베이스에 저장
    
    - store_seq를 받아서 해당 식당의 store_lat, store_lng를 사용
    - target_date가 없으면 오늘 날씨 데이터 저장
    - target_date가 있으면 해당 날짜의 날씨 데이터 저장 (오늘부터 최대 8일까지만 가능)
    """
    try:
        # 날짜 파싱
        target_date_obj = None
        if target_date:
            try:
                target_date_obj = datetime.strptime(target_date, "%Y-%m-%d")
            except ValueError:
                return {
                    "result": "Error",
                    "errorMsg": f"날짜 형식이 올바르지 않습니다. (YYYY-MM-DD 형식 필요): {target_date}"
                }
        
        weather_service = WeatherService()
        result = weather_service.save_weather_to_db(
            store_seq=store_seq,
            target_date=target_date_obj,
            overwrite=overwrite
        )
        
        if result["success"]:
            return {
                "result": "OK",
                "message": result["message"],
                "inserted": result["inserted"],
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


# ============================================
# OpenWeatherMap API에서 직접 날씨 데이터 가져오기 (DB 저장 없이)
# ============================================
@router.get("/direct")
async def fetch_weather_direct(
    lat: float = Query(..., description="위도 (필수)"),
    lon: float = Query(..., description="경도 (필수)"),
    start_date: Optional[str] = Query(None, description="시작 날짜 (YYYY-MM-DD), 없으면 오늘 포함 8일치 모두 반환")
):
    """
    OpenWeatherMap API에서 직접 날씨 데이터 가져오기 (DB 저장 없이)
    
    - lat, lon을 직접 받아서 OpenWeatherMap API 호출 (store 테이블 조회 없음)
    - start_date가 없으면: 오늘 포함 8일치 모두 반환
    - start_date가 있으면: 해당 날짜부터 남은 날짜만 반환 (최대 8일)
    - 날짜 검증: 과거 날짜 불가, 최대 8일까지만 가능
    
    예시:
        - start_date 없음: 오늘부터 8일치 모두 반환
        - start_date=오늘+3일: 오늘+3일부터 5일치만 반환 (총 8일 중 남은 5일)
    """
    try:
        # 날짜 파싱
        start_date_obj = None
        if start_date:
            try:
                start_date_obj = datetime.strptime(start_date, "%Y-%m-%d")
            except ValueError:
                return {
                    "result": "Error",
                    "errorMsg": f"날짜 형식이 올바르지 않습니다. (YYYY-MM-DD 형식 필요): {start_date}"
                }
        
        # WeatherService를 사용하여 OpenWeatherMap API에서 직접 데이터 가져오기
        weather_service = WeatherService()
        forecast_list = weather_service.fetch_daily_forecast(
            lat=str(lat),
            lon=str(lon),
            start_date=start_date_obj
        )
        
        # 결과 포맷팅
        results = []
        for forecast in forecast_list:
            weather_datetime = forecast["weather_datetime"]
            if isinstance(weather_datetime, datetime):
                weather_datetime_str = weather_datetime.isoformat()
            else:
                weather_datetime_str = str(weather_datetime)
            
            results.append({
                'weather_datetime': weather_datetime_str,
                'weather_type': forecast["weather_type"],
                'weather_low': forecast["weather_low"],
                'weather_high': forecast["weather_high"],
                'icon_url': forecast["icon_url"]
            })
        
        return {"results": results}
        
    except ValueError as e:
        # 날짜 검증 오류
        return {
            "result": "Error",
            "errorMsg": str(e)
        }
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
# OpenWeatherMap API에서 특정 날짜의 날씨 데이터만 가져오기 (DB 저장 없이, 하루치만)
# ============================================
@router.get("/direct/single")
async def fetch_weather_direct_single(
    lat: float = Query(..., description="위도 (필수)"),
    lon: float = Query(..., description="경도 (필수)"),
    target_date: Optional[str] = Query(None, description="조회할 날짜 (YYYY-MM-DD), 없으면 오늘 날짜")
):
    """
    OpenWeatherMap API에서 특정 날짜의 날씨 데이터만 가져오기 (DB 저장 없이, 하루치만)
    
    - lat, lon을 직접 받아서 OpenWeatherMap API 호출 (store 테이블 조회 없음)
    - target_date가 없으면 오늘 날씨만 반환
    - target_date가 있으면 해당 날짜의 날씨만 반환 (오늘부터 최대 8일까지만 가능)
    - 날짜 검증: 과거 날짜 불가, 최대 8일까지만 가능
    """
    try:
        # 날짜 파싱
        target_date_obj = None
        if target_date:
            try:
                target_date_obj = datetime.strptime(target_date, "%Y-%m-%d")
            except ValueError:
                return {
                    "result": "Error",
                    "errorMsg": f"날짜 형식이 올바르지 않습니다. (YYYY-MM-DD 형식 필요): {target_date}"
                }
        
        # WeatherService를 사용하여 OpenWeatherMap API에서 특정 날짜의 날씨만 가져오기
        weather_service = WeatherService()
        forecast = weather_service.fetch_single_day_weather(
            lat=str(lat),
            lon=str(lon),
            target_date=target_date_obj
        )
        
        # 결과 포맷팅
        weather_datetime = forecast["weather_datetime"]
        if isinstance(weather_datetime, datetime):
            weather_datetime_str = weather_datetime.isoformat()
        else:
            weather_datetime_str = str(weather_datetime)
        
        result = {
            'weather_datetime': weather_datetime_str,
            'weather_type': forecast["weather_type"],
            'weather_low': forecast["weather_low"],
            'weather_high': forecast["weather_high"],
            'icon_url': forecast["icon_url"]
        }
        
        return {"result": result}
        
    except ValueError as e:
        # 날짜 검증 오류
        return {
            "result": "Error",
            "errorMsg": str(e)
        }
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
#
# 2026-01-18: OpenWeatherMap API 직접 조회 엔드포인트 추가
#   - GET /api/weather/direct 엔드포인트 추가 (DB 저장 없이 직접 조회)
#   - 날짜 검증 로직 추가 (백엔드 이중 검증)
#   - 8일치 예보 또는 특정 날짜 조회 지원
#   - store 테이블 조회와 OpenWeatherMap API 조회 완전 분리
#   - store_seq 대신 lat, lon 파라미터로 직접 받도록 변경
#
# 2026-01-15 김택권: OpenWeatherMap API 호출 버그 수정
#   - lat, lon이 None일 때 기본값(서울 좌표)을 사용하도록 수정
#   - None 값이 API URL에 포함되어 400 에러가 발생하던 문제 해결
#
# 2026-01-18: POST /api/weather/fetch-from-api 엔드포인트 확장
#   - target_date 파라미터 추가 (특정 날짜 저장 가능)
#   - 예약 날짜의 날씨를 저장할 수 있도록 기능 확장