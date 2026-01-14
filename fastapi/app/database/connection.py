"""
데이터베이스 연결 설정
Table Now 데이터베이스 연결을 위한 설정
"""

import pymysql


# TODO: 실제 데이터베이스 설정으로 변경 필요
DB_CONFIG = {
    'host': 'localhost',  # 데이터베이스 호스트
    'user': 'your_user',  # 데이터베이스 사용자
    'password': 'your_password',  # 데이터베이스 비밀번호
    'database': 'table_now_db',  # 데이터베이스 이름
    'charset': 'utf8mb4',
    'port': 3306  # MySQL 포트
}


def connect_db():
    """
    데이터베이스 연결
    
    Returns:
        pymysql.Connection: 데이터베이스 연결 객체
        
    Raises:
        pymysql.Error: 데이터베이스 연결 실패 시
    """
    try:
        conn = pymysql.connect(**DB_CONFIG)
        return conn
    except pymysql.Error as e:
        raise pymysql.Error(f"Database connection failed: {str(e)}") from e
