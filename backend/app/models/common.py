"""
Common models shared across all endpoints.

SourceMeta, pagination, error envelope.
"""

from datetime import datetime
from enum import Enum

from pydantic import BaseModel


class SourcePriority(int, Enum):
    """Source priority levels."""
    OFFICIAL = 1
    SECONDARY = 2
    UNOFFICIAL = 3


class SourceMeta(BaseModel):
    """Provenance metadata attached to every response."""
    source: str
    source_priority: int = SourcePriority.SECONDARY
    fetched_at: datetime
    updated_at: datetime


class PaginationMeta(BaseModel):
    """Pagination info for list endpoints."""
    page: int = 1
    page_size: int = 20
    total_count: int = 0
    has_next: bool = False


class ErrorResponse(BaseModel):
    """Standard error envelope."""
    code: str
    message: str
    details: str | None = None


class EventType(str, Enum):
    """All possible event types."""
    IPO_OPEN = "ipo_open"
    IPO_CLOSE = "ipo_close"
    IPO_ALLOTMENT = "ipo_allotment"
    IPO_LISTING = "ipo_listing"
    DIVIDEND_EX = "dividend_ex"
    DIVIDEND_RECORD = "dividend_record"
    DIVIDEND_PAYMENT = "dividend_payment"
    BONUS_EX = "bonus_ex"
    BONUS_RECORD = "bonus_record"
    SPLIT_EX = "split_ex"
    SPLIT_RECORD = "split_record"
    RIGHTS_OPEN = "rights_open"
    RIGHTS_CLOSE = "rights_close"
    BOND_OPEN = "bond_open"
    BOND_CLOSE = "bond_close"
    NEWS_PUBLISHED = "news_published"


class EntityType(str, Enum):
    """Entity types that generate events."""
    IPO = "ipo"
    DIVIDEND = "dividend"
    BONUS = "bonus"
    SPLIT = "split"
    RIGHTS = "rights"
    BOND = "bond"
    NEWS = "news"


class EventStatus(str, Enum):
    """Current status of an event."""
    UPCOMING = "upcoming"
    ACTIVE = "active"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class EventImportance(str, Enum):
    """Importance level for dashboard ranking."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class TimelineEvent(BaseModel):
    """Normalized event model. Everything becomes a TimelineEvent."""
    id: str
    event_type: EventType
    entity_type: EntityType
    entity_id: str
    title: str
    subtitle: str | None = None
    date: datetime
    status: EventStatus
    importance: EventImportance
    meta: SourceMeta
