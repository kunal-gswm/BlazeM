"""
asyncpg connection pool lifecycle.

No ORM. No SQLAlchemy. Raw asyncpg.
"""

import asyncpg
from app.config import settings

_pool: asyncpg.Pool | None = None


async def create_pool() -> asyncpg.Pool:
    """Create the connection pool. Called during app lifespan startup."""
    global _pool
    try:
        _pool = await asyncpg.create_pool(
            dsn=settings.database_url,
            min_size=settings.db_min_pool_size,
            max_size=settings.db_max_pool_size,
        )
        # Test connection aggressively
        async with _pool.acquire() as conn:
            await conn.execute("SELECT 1")
    except Exception as e:
        raise RuntimeError(f"FATAL: Database connection failed on startup: {e}")
        
    return _pool


def get_pool() -> asyncpg.Pool:
    """Get the current pool. Raises if not initialized."""
    if _pool is None:
        raise RuntimeError("Database pool not initialized. Call create_pool() first.")
    return _pool


async def close_pool() -> None:
    """Close the pool. Called during app lifespan shutdown."""
    global _pool
    if _pool is not None:
        await _pool.close()
        _pool = None
