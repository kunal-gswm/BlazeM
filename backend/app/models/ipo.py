from datetime import date
from pydantic import BaseModel

from .common import SourceMeta
from .events import EventStatus

class IpoModel(BaseModel):
    id: str
    company_name: str
    symbol: str | None = None
    issue_price_min: float | None = None
    issue_price_max: float | None = None
    lot_size: int | None = None
    issue_size: float | None = None
    retail_quota: float | None = None
    latest_gmp: float | None = None
    status: EventStatus
    open_date: date | None = None
    close_date: date | None = None
    allotment_date: date | None = None
    listing_date: date | None = None
    meta: SourceMeta

class IpoListResponse(BaseModel):
    data: list[IpoModel]

class IpoDetailResponse(BaseModel):
    data: IpoModel
