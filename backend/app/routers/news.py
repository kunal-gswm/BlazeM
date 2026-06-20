"""News router."""

from fastapi import APIRouter

router = APIRouter()


@router.get("/news")
async def list_news():
    """News items, optionally filtered by event."""
    return {"data": [], "meta": {"source": "stub", "fetched_at": None, "updated_at": None}}


@router.get("/news/{news_id}")
async def get_news(news_id: str):
    """Single news item."""
    return {"data": None, "meta": {"source": "stub", "fetched_at": None, "updated_at": None}}
