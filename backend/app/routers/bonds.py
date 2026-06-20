"""Bonds router."""

from fastapi import APIRouter

router = APIRouter()


@router.get("/bonds")
async def list_bonds():
    """List retail bonds."""
    return {"data": [], "meta": {"source": "stub", "fetched_at": None, "updated_at": None}}


@router.get("/bonds/{bond_id}")
async def get_bond(bond_id: str):
    """Single bond detail."""
    return {"data": None, "meta": {"source": "stub", "fetched_at": None, "updated_at": None}}
