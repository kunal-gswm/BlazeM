"""
FastAPI dependencies.

Shared across routers. Currently: DB pool access.
"""

from app.db.pool import get_pool


async def get_db():
    """Yield an asyncpg connection from the pool."""
    pool = get_pool()
    async with pool.acquire() as conn:
        yield conn
