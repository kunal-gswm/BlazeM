"""Watchlist router."""

from fastapi import APIRouter

router = APIRouter()


@router.get("/watchlist")
async def get_watchlist():
    """User's watchlisted events."""
    return {"data": [], "meta": {"source": "local", "fetched_at": None, "updated_at": None}}


@router.post("/watchlist")
async def add_to_watchlist():
    """Add event to watchlist."""
    return {"status": "added"}


@router.delete("/watchlist/{event_id}")
async def remove_from_watchlist(event_id: str):
    """Remove event from watchlist."""
    return {"status": "removed"}
