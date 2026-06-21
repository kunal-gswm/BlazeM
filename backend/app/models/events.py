from datetime import datetime
from enum import Enum
from pydantic import BaseModel

from .common import SourceMeta

class EntityType(str, Enum):
    IPO = "ipo"
    CORPORATE_ACTION = "corporate_action"
    BOND = "bond"
    NEWS = "news"
    EVENT = "event"

class EventStatus(str, Enum):
    UPCOMING = "upcoming"
    ACTIVE = "active"
    COMPLETED = "completed"
    CANCELLED = "cancelled"

class EventImportance(str, Enum):
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"

class TimelineEventModel(BaseModel):
    id: str
    event_type: str
    entity_type: EntityType
    entity_id: str
    title: str
    subtitle: str | None = None
    date: datetime
    status: EventStatus
    importance: EventImportance
    importance_score: int
    meta: SourceMeta

class TimelineResponse(BaseModel):
    data: list[TimelineEventModel]
