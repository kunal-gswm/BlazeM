"""Events / Timeline router."""

from fastapi import APIRouter

router = APIRouter()


@router.get("/events/timeline")
async def get_timeline():
    """Chronological event timeline."""
    return {"data": [], "meta": {"source": "stub", "fetched_at": None, "updated_at": None}}


@router.get("/events/{event_id}/timeline")
async def get_event_timeline(event_id: str):
    """Timeline for a specific event."""
    return {"data": [], "meta": {"source": "stub", "fetched_at": None, "updated_at": None}}
