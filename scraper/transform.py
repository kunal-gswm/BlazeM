"""Cross-source deduplication and merge logic.

Priority: InvestorGain (GMP) > IPO Central (face value, detail) > Chittorgarh (listing details).
"""

import logging
import re
from models import IPOData

logger = logging.getLogger(__name__)


from datetime import datetime, timedelta

def normalize_name(name: str) -> str:
    """Normalize company name for fuzzy matching across sources."""
    name = name.lower().strip()
    
    # Remove any trailing parenthetical info e.g. "(Coming soon)", "(24 - 29 Jun)"
    name = re.sub(r'\([^)]*\)\s*$', '', name)
    
    # Remove common suffixes
    name = re.sub(r'\s*(ipo|limited|ltd|pvt|private|public|solutions|technologies|industries)\.?\s*', ' ', name)
    # Remove special chars
    name = re.sub(r'[^a-z0-9\s]', '', name)
    # Collapse whitespace
    return " ".join(name.split())


def _parse_date(date_str: str) -> datetime | None:
    """Extract datetime from strings like '6-Jul', '23 - 25 Jun', '08-May-2026'."""
    if not date_str:
        return None
    
    # Extract something like '29', 'Jun' (or 'June')
    m = re.search(r'(\d{1,2})[-\s]+([A-Za-z]{3,})', date_str)
    if not m:
        return None
    
    day = int(m.group(1))
    month_str = m.group(2)[:3].capitalize()
    
    # Try finding year
    year_m = re.search(r'\b(202\d)\b', date_str)
    year = int(year_m.group(1)) if year_m else datetime.now().year
    
    try:
        return datetime.strptime(f'{day} {month_str} {year}', '%d %b %Y')
    except ValueError:
        return None

def filter_active_and_upcoming(ipos: list[IPOData]) -> list[IPOData]:
    """Filter to keep only Open and Upcoming IPOs (within 1 month)."""
    filtered = []
    now = datetime.now()
    yesterday = now - timedelta(days=1)
    one_month_ahead = now + timedelta(days=31)

    for ipo in ipos:
        # Try to parse close date first, then open date
        dt_close = _parse_date(ipo.issue_close)
        dt_open = _parse_date(ipo.issue_open)

        # If no dates are given (e.g. "Coming soon"), discard.
        if not dt_close and not dt_open:
            continue

        # If we have a close date, and it's strictly in the past, it's CLOSED.
        if dt_close and dt_close < yesterday:
            continue
            
        # If no close date, but open date is in the past, it's CLOSED.
        if not dt_close and dt_open and dt_open < yesterday:
            continue

        # If it opens too far in the future (> 1 month), skip.
        if dt_open and dt_open > one_month_ahead:
            continue

        # Keep open and properly dated upcoming IPOs
        filtered.append(ipo)

    logger.info(f"Filtered {len(ipos)} down to {len(filtered)} Open/Upcoming IPOs")
    return filtered


def merge_ipo_data(
    investorgain_ipos: list[IPOData],
    chittorgarh_ipos: list[IPOData],
) -> list[IPOData]:
    """Merge IPO data from all sources into a deduplicated list.

    Strategy:
    - Pass 1 & 2: Use InvestorGain and Chittorgarh to build the base list, as they are explicitly filtered for Mainboard IPOs.
    """
    merged: dict[str, IPOData] = {}

    # Pass 1: InvestorGain as base
    for ipo in investorgain_ipos:
        key = normalize_name(ipo.issue_name)
        if key and key not in merged:
            merged[key] = ipo

    # Pass 2: Chittorgarh — add missing mainboard IPOs and fill gaps
    for ipo in chittorgarh_ipos:
        key = normalize_name(ipo.issue_name)
        if not key:
            continue

        if key in merged:
            _fill_missing(merged[key], ipo)
        else:
            merged[key] = ipo

    result = list(merged.values())
    logger.info(f"Merged: {len(result)} unique IPOs")
    return result


import dataclasses

def _fill_missing(target: IPOData, source: IPOData):
    """Fill empty fields in target from source. Never overwrite existing data."""
    for field in dataclasses.fields(target):
        target_val = getattr(target, field.name, "")
        source_val = getattr(source, field.name, "")
        if not target_val and source_val:
            setattr(target, field.name, source_val)
