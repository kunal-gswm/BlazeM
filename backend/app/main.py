"""
Blamics Backend — FastAPI application factory.

Single monolith. No microservices. No auth.
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.db.pool import create_pool, close_pool
from app.routers import (
    dashboard,
    ipo,
    corporate_actions,
    bonds,
    news,
    watchlist,
    search,
    events,
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage application lifecycle: DB pool up/down."""
    await create_pool()
    yield
    await close_pool()


def create_app() -> FastAPI:
    app = FastAPI(
        title="Blamics API",
        version="0.1.0",
        lifespan=lifespan,
    )

    # CORS — restrict to local network and emulators
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[
            "http://localhost",
            "http://127.0.0.1",
            "http://10.0.2.2",
            "http://10.0.3.2",
            "http://localhost:8000",
        ],
        allow_methods=["*"],
        allow_headers=["*"],
    )

    @app.get("/health", tags=["system"])
    async def health_check():
        from app.db.pool import get_pool
        db_ok = False
        try:
            pool = get_pool()
            async with pool.acquire() as conn:
                await conn.execute("SELECT 1")
            db_ok = True
        except Exception:
            pass
        
        return {"status": "ok", "database": db_ok}

    # Register routers
    prefix = "/api"
    app.include_router(dashboard.router, prefix=prefix, tags=["dashboard"])
    app.include_router(ipo.router, prefix=prefix, tags=["ipo"])
    app.include_router(corporate_actions.router, prefix=prefix, tags=["corporate-actions"])
    app.include_router(bonds.router, prefix=prefix, tags=["bonds"])
    app.include_router(news.router, prefix=prefix, tags=["news"])
    app.include_router(watchlist.router, prefix=prefix, tags=["watchlist"])
    app.include_router(search.router, prefix=prefix, tags=["search"])
    app.include_router(events.router, prefix=prefix, tags=["events"])

    return app


app = create_app()
