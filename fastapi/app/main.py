"""
Table Now FastAPI 메인 애플리케이션
기본 구조만 포함하며, 엔드포인트는 나중에 추가할 수 있도록 설계
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# 데이터베이스 연결 (필요시 주석 해제)
# from app.database.connection import connect_db

app = FastAPI(
    title="Table Now API",
    description="Table Now 애플리케이션을 위한 REST API",
    version="1.0.0"
)

# CORS 설정 (Flutter 앱과 통신을 위해 필요)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 개발 환경용, 프로덕션에서는 특정 도메인으로 제한
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================
# 라우터 등록
# ============================================
# 엔드포인트를 추가할 때 아래와 같이 라우터를 등록하세요:
#
# from app.api import example_router
# app.include_router(example_router.router, prefix="/api/example", tags=["example"])

# 예시: 기본 라우터 구조
# app.include_router(users.router, prefix="/api/users", tags=["users"])
# app.include_router(auth.router, prefix="/api/auth", tags=["auth"])


@app.get("/")
async def root():
    """루트 엔드포인트 - API 정보 반환"""
    return {
        "message": "Table Now API",
        "status": "running",
        "version": "1.0.0",
        "endpoints": {
            "health": "/health",
            "docs": "/docs",
            "redoc": "/redoc"
        }
    }


@app.get("/health")
async def health_check():
    """헬스 체크 엔드포인트"""
    # 데이터베이스 연결이 필요할 때 주석 해제
    # try:
    #     conn = connect_db()
    #     conn.close()
    #     return {"status": "healthy", "database": "connected"}
    # except Exception as e:
    #     return {"status": "unhealthy", "error": str(e)}
    
    return {
        "status": "healthy",
        "message": "API is running"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
