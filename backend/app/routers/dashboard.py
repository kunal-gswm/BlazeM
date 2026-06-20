"""Dashboard router."""

from fastapi import APIRouter

router = APIRouter()


@router.get("/dashboard")
async def get_dashboard():
    """Aggregated upcoming events across all types."""
    return {"data": [], "meta": {"source": "stub", "fetched_at": None, "updated_at": None}}
