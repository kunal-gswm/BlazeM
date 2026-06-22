"""Unified IPO data model used across all scrapers."""

from dataclasses import dataclass, asdict, field
from datetime import datetime, timezone
import json


@dataclass
class IPOData:
    """Represents a single IPO with all scraped fields."""

    issue_name: str
    ipo_type: str = ""
    source: str = ""  # "ipocentral" | "chittorgarh" | "investorgain"
    price_band: str = ""  # "₹140 - ₹148"
    lot_size: str = ""  # "101 Shares"
    issue_size: str = ""  # "₹8,750 Cr"
    issue_open: str = ""  # date string
    issue_close: str = ""  # date string
    allotment_date: str | None = None
    listing_date: str | None = None

    gmp: float | None = None
    gmp_percent: str | None = None

    detail_url: str | None = None
    scraped_at: str = field(
        default_factory=lambda: datetime.now(timezone.utc).isoformat() + "Z"
    )
