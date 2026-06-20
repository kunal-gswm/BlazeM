"""Corporate actions router."""

from fastapi import APIRouter

router = APIRouter()


@router.get("/corporate-actions")
async def list_corporate_actions():
    """List corporate actions with type filter."""
    return {"data": [], "meta": {"source": "stub", "fetched_at": None, "updated_at": None}}


@router.get("/corporate-actions/{action_id}")
async def get_corporate_action(action_id: str):
    """Single corporate action detail."""
    return {"data": None, "meta": {"source": "stub", "fetched_at": None, "updated_at": None}}
