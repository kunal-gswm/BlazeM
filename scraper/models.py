"""Unified IPO data model used across all scrapers."""

from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from typing import Optional
import json


@dataclass
class IPOData:
    """Represents a single IPO with all scraped fields."""

    issue_name: str
    ipo_type: str = "Mainboard"
    source: str = ""              # "ipocentral" | "chittorgarh" | "investorgain"
    price_band: str = ""          # "₹140 - ₹148"
    face_value: str = ""          # "₹10"
    lot_size: str = ""            # "101 Shares"
    issue_size: str = ""          # "₹8,750 Cr"
    issue_open: str = ""          # date string
    issue_close: str = ""         # date string
    allotment_date: str = ""
    listing_date: str = ""
    gmp: str = ""                 # "₹45"
    gmp_percent: str = ""         # "30.4%"
    detail_url: str = ""          # link to source page
    scraped_at: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

    def to_dict(self) -> dict:
        return asdict(self)

    @classmethod
    def from_dict(cls, data: dict) -> "IPOData":
        # Only pass fields that exist in the dataclass
        valid_fields = {f.name for f in cls.__dataclass_fields__.values()}
        filtered = {k: v for k, v in data.items() if k in valid_fields}
        return cls(**filtered)


@dataclass
class ScrapeResult:
    """Container for the full scrape output file."""

    last_updated: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    sources_scraped: list[str] = field(default_factory=list)
    ipo_count: int = 0
    ipos: list[dict] = field(default_factory=list)

    def to_json(self, indent: int = 2) -> str:
        return json.dumps(asdict(self), indent=indent, ensure_ascii=False)

    @classmethod
    def from_ipos(cls, ipos: list[IPOData], sources: list[str]) -> "ScrapeResult":
        return cls(
            sources_scraped=sources,
            ipo_count=len(ipos),
            ipos=[ipo.to_dict() for ipo in ipos],
        )
