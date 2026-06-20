"""IPO router."""

from fastapi import APIRouter

router = APIRouter()


@router.get("/ipos")
async def list_ipos():
    """List IPOs with filters."""
    return {"data": [], "meta": {"source": "stub", "fetched_at": None, "updated_at": None}}


@router.get("/ipos/{ipo_id}")
async def get_ipo(ipo_id: str):
    """Single IPO with full detail."""
    return {"data": None, "meta": {"source": "stub", "fetched_at": None, "updated_at": None}}


@router.get("/ipos/{ipo_id}/gmp")
async def get_ipo_gmp(ipo_id: str):
    """GMP history for an IPO."""
    return {"data": [], "meta": {"source": "stub", "fetched_at": None, "updated_at": None}}
