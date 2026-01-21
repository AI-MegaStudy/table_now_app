#!/usr/bin/env python3
"""
현재 DB 데이터를 seed 파일 형식으로 추출하는 스크립트
"""

import pymysql
from datetime import datetime
import sys

# DB 연결 정보
DB_CONFIG = {
    'host': 'cheng80.myqnapcloud.com',
    'user': 'team0101',
    'password': 'qwer1234',
    'database': 'table_now_db',
    'charset': 'utf8mb4',
    'port': 13306
}

OUTPUT_FILE = 'table_now_db_current_data.sql'
TABLES = ['customer', 'store', 'store_table', 'menu', 'option', 'weather', 'reserve', 'pay', 'device_token', 'password_reset_auth']

def escape_sql_value(value):
    if value is None:
        return 'NULL'
    elif isinstance(value, (int, float)):
        return str(value)
    elif isinstance(value, bool):
        return '1' if value else '0'
    elif isinstance(value, datetime):
        return f"'{value.strftime('%Y-%m-%d %H:%M:%S')}'"
    else:
        # f-string 내부에서 백슬래시를 직접 사용할 수 없으므로 변수에 먼저 할당
        escaped = str(value).replace('\\', '\\\\').replace("'", "\\'")
        return f"'{escaped}'"

def get_table_columns(conn, table_name):
    cursor = conn.cursor()
    cursor.execute(f"SHOW COLUMNS FROM `{table_name}`")
    columns = [row[0] for row in cursor.fetchall()]
    cursor.close()
    return columns

def generate_on_duplicate_update(columns):
    updates = [f"`{col}` = VALUES(`{col}`)" for col in columns]
    return "ON DUPLICATE KEY UPDATE " + ", ".join(updates)

def export_table_data(conn, table_name, output_file):
    try:
        cursor = conn.cursor()
        cursor.execute(f"SHOW TABLES LIKE '{table_name}'")
        if not cursor.fetchone():
            print(f"⚠️  테이블 '{table_name}' 건너뜀")
            cursor.close()
            return
        
        columns = get_table_columns(conn, table_name)
        if not columns:
            cursor.close()
            return
        
        column_list = ", ".join([f"`{col}`" for col in columns])
        cursor.execute(f"SELECT * FROM `{table_name}` ORDER BY 1")
        rows = cursor.fetchall()
        
        if not rows:
            print(f"ℹ️  '{table_name}' 데이터 없음")
            cursor.close()
            return
        
        output_file.write(f"\n-- {table_name} 테이블 데이터\n")
        output_file.write(f"INSERT INTO `{table_name}` ({column_list})\nVALUES\n")
        
        value_rows = []
        for row in rows:
            values = [escape_sql_value(val) for val in row]
            value_rows.append(f"  ({', '.join(values)})")
        
        output_file.write(",\n".join(value_rows))
        output_file.write(f"\n{generate_on_duplicate_update(columns)};\n")
        
        print(f"✅ '{table_name}': {len(rows)}개 행 추출")
        cursor.close()
    except Exception as e:
        print(f"❌ '{table_name}' 오류: {str(e)}")

def main():
    print("=" * 60)
    print("현재 DB 데이터 추출 시작")
    print("=" * 60)
    
    try:
        conn = pymysql.connect(**DB_CONFIG)
        print(f"✅ DB 연결 성공\n")
        
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            f.write("-- ===========================================================\n")
            f.write("-- 현재 DB 데이터 추출 (자동 생성)\n")
            f.write(f"-- 생성일: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write("-- ===========================================================\n\n")
            f.write("USE `table_now_db`;\n\n")
            f.write("START TRANSACTION;\n\n")
            f.write("SET FOREIGN_KEY_CHECKS = 0;\n\n")
            
            for table in TABLES:
                export_table_data(conn, table, f)
            
            f.write("\nSET FOREIGN_KEY_CHECKS = 1;\n\n")
            f.write("COMMIT;\n")
        
        conn.close()
        print(f"\n✅ 추출 완료: {OUTPUT_FILE}")
    except Exception as e:
        print(f"❌ 오류: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()