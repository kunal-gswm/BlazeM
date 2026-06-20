"""Search router."""

from fastapi import APIRouter, Query

router = APIRouter()


@router.get("/search")
async def search(q: str = Query(..., min_length=1)):
    """Cross-entity full-text search."""
    return {"data": [], "meta": {"source": "stub", "fetched_at": None, "updated_at": None}}
