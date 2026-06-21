"""Cross-source deduplication and merge logic.

Priority: InvestorGain (GMP) > IPO Central (face value, detail) > Chittorgarh (listing details).
"""

import logging
import re
from models import IPOData

logger = logging.getLogger(__name__)


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


def merge_ipo_data(
    investorgain_ipos: list[IPOData],
    ipocentral_ipos: list[IPOData],
    chittorgarh_ipos: list[IPOData],
) -> list[IPOData]:
    """Merge IPO data from all sources into a deduplicated list.

    Strategy:
    - Start with InvestorGain as the base (best GMP data)
    - Fill missing fields from IPO Central (best for face value, detail pages)
    - Fill remaining gaps from Chittorgarh
    - Add any IPOs that only appear in secondary sources
    """
    # Build merged dict keyed by normalized name
    merged: dict[str, IPOData] = {}

    # Pass 1: InvestorGain as base
    for ipo in investorgain_ipos:
        key = normalize_name(ipo.issue_name)
        if key and key not in merged:
            merged[key] = ipo

    # Pass 2: IPO Central — fill gaps
    for ipo in ipocentral_ipos:
        key = normalize_name(ipo.issue_name)
        if not key:
            continue

        if key in merged:
            _fill_missing(merged[key], ipo)
        else:
            merged[key] = ipo

    # Pass 3: Chittorgarh — fill remaining gaps
    for ipo in chittorgarh_ipos:
        key = normalize_name(ipo.issue_name)
        if not key:
            continue

        if key in merged:
            _fill_missing(merged[key], ipo)
        else:
            merged[key] = ipo

    result = list(merged.values())
    logger.info(f"Merged: {len(result)} unique IPOs from {len(investorgain_ipos)} + {len(ipocentral_ipos)} + {len(chittorgarh_ipos)}")
    return result


def _fill_missing(target: IPOData, source: IPOData):
    """Fill empty fields in target from source. Never overwrite existing data."""
    fields_to_fill = [
        "price_band", "face_value", "lot_size", "issue_size",
        "issue_open", "issue_close", "allotment_date", "listing_date",
        "gmp", "gmp_percent",
    ]
    for field in fields_to_fill:
        target_val = getattr(target, field, "")
        source_val = getattr(source, field, "")
        if not target_val and source_val:
            setattr(target, field, source_val)

    # Append detail URL if target doesn't have one
    if not target.detail_url and source.detail_url:
        target.detail_url = source.detail_url
