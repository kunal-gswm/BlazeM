"""Events / Timeline router."""

from fastapi import APIRouter, Depends
import asyncpg

from app.dependencies import get_db
from app.services.timeline_service import get_timeline_events
from app.models.events import TimelineResponse

router = APIRouter()


@router.get("/events/timeline", response_model=TimelineResponse)
async def get_timeline(conn: asyncpg.Connection = Depends(get_db)):
    """Unified timeline of all events."""
    events = await get_timeline_events(conn)
    return TimelineResponse(data=events)


@router.get("/events/{event_id}/timeline")
async def get_event_timeline(event_id: str):
    """Timeline for a specific event."""
    return {"data": [], "meta": {"source": "stub", "fetched_at": None, "updated_at": None}}
