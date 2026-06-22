"""Unified IPO data model used across all scrapers."""

from dataclasses import dataclass, asdict
from datetime import datetime
from typing import Any
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
    allotment_date: str = ""
    listing_date: str = ""
    gmp: str = ""  # "₹45"
    gmp_percent: str = ""  # "30.4%"
    detail_url: str = ""  # link to source page
    scraped_at: str = ""

    def __post_init__(self):
        if not self.scraped_at:
            self.scraped_at = datetime.now().isoformat(timespec="microseconds")


@dataclass
class ScrapeResult:
    """Container for the full scrape output file."""

    last_updated: str
    sources_scraped: list[str]
    ipo_count: int
    ipos: list[IPOData]

    def to_json(self, indent: int = 2) -> str:
        return json.dumps(asdict(self), indent=indent, ensure_ascii=False)

    @classmethod
    def from_ipos(cls, ipos: list[IPOData], sources: list[str]) -> "ScrapeResult":
        return cls(
            last_updated=datetime.now().isoformat(timespec="microseconds"),
            sources_scraped=sources,
            ipo_count=len(ipos),
            ipos=ipos,
        )
