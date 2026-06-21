import asyncpg
from app.models.ipo import IpoModel
from app.models.events import EventStatus
from app.models.common import SourceMeta, SourcePriority

async def get_ipos(conn: asyncpg.Connection) -> list[IpoModel]:
    """
    Fetch all IPOs.
    """
    query = """
        SELECT 
            i.id, i.company_name, i.symbol, i.issue_price_min, i.issue_price_max,
            i.lot_size, i.issue_size, i.retail_quota, i.status,
            i.open_date, i.close_date, i.allotment_date, i.listing_date,
            s.id as source_id, s.priority as source_priority,
            i.created_at, i.fetched_at, i.updated_at
        FROM ipos i
        JOIN sources s ON i.source_id = s.id
        ORDER BY COALESCE(i.open_date, i.created_at::date) DESC
    """
    
    records = await conn.fetch(query)
    
    ipos = []
    for r in records:
        meta = SourceMeta(
            source_id=r["source_id"],
            source_priority=SourcePriority(r["source_priority"]),
            created_at=r["created_at"],
            fetched_at=r["fetched_at"],
            updated_at=r["updated_at"]
        )
        
        ipo = IpoModel(
            id=r["id"],
            company_name=r["company_name"],
            symbol=r["symbol"],
            issue_price_min=r["issue_price_min"],
            issue_price_max=r["issue_price_max"],
            lot_size=r["lot_size"],
            issue_size=r["issue_size"],
            retail_quota=r["retail_quota"],
            status=EventStatus(r["status"]),
            open_date=r["open_date"],
            close_date=r["close_date"],
            allotment_date=r["allotment_date"],
            listing_date=r["listing_date"],
            meta=meta
        )
        ipos.append(ipo)
        
    return ipos
