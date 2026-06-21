import asyncpg
from app.models.events import TimelineEventModel, EntityType, EventStatus, EventImportance
from app.models.common import SourceMeta, SourcePriority

async def get_timeline_events(conn: asyncpg.Connection) -> list[TimelineEventModel]:
    """
    Fetch all timeline events ordered by date ascending.
    """
    # In a real scenario we might filter by status or paginate.
    query = """
        SELECT 
            t.id, t.event_type, t.entity_type, t.entity_id, t.title, t.subtitle,
            t.date, t.status, t.importance, t.importance_score,
            s.id as source_id, s.priority as source_priority,
            t.created_at, t.fetched_at, t.updated_at
        FROM timeline_events t
        JOIN sources s ON t.source_id = s.id
        ORDER BY t.date ASC
    """
    
    records = await conn.fetch(query)
    
    events = []
    for r in records:
        meta = SourceMeta(
            source_id=r["source_id"],
            source_priority=SourcePriority(r["source_priority"]),
            created_at=r["created_at"],
            fetched_at=r["fetched_at"],
            updated_at=r["updated_at"]
        )
        
        event = TimelineEventModel(
            id=r["id"],
            event_type=r["event_type"],
            entity_type=EntityType(r["entity_type"]),
            entity_id=r["entity_id"],
            title=r["title"],
            subtitle=r["subtitle"],
            date=r["date"],
            status=EventStatus(r["status"]),
            importance=EventImportance(r["importance"]),
            importance_score=r["importance_score"],
            meta=meta
        )
        events.append(event)
        
    return events
