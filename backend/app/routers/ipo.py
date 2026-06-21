"""IPO router."""

from fastapi import APIRouter, Depends
import asyncpg

from app.dependencies import get_db
from app.services.ipo_service import get_ipos
from app.models.ipo import IpoListResponse

router = APIRouter()


@router.get("/ipos", response_model=IpoListResponse)
async def list_ipos(conn: asyncpg.Connection = Depends(get_db)):
    """List IPOs with filters."""
    ipos = await get_ipos(conn)
    return IpoListResponse(data=ipos)


@router.get("/ipos/{ipo_id}")
async def get_ipo(ipo_id: str):
    """Single IPO with full detail."""
    return {"data": None, "meta": {"source": "stub", "fetched_at": None, "updated_at": None}}


@router.get("/ipos/{ipo_id}/gmp")
async def get_ipo_gmp(ipo_id: str):
    """GMP history for an IPO."""
    return {"data": [], "meta": {"source": "stub", "fetched_at": None, "updated_at": None}}
