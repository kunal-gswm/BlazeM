"""Chittorgarh scraper — current and upcoming mainboard IPO listing details."""

import logging
import re
from models import IPOData
from merge import normalize_name
from config import (
    CHITTORGARH_CURRENT_IPOS_URL,
    CHITTORGARH_TIMETABLE_URL,
    CHITTORGARH_UPCOMING_URL,
    CHITTORGARH_BASE_URL,
)
from utils import fetch_html_js, clean_text

logger = logging.getLogger(__name__)


def scrape_chittorgarh() -> list[IPOData]:
    """Scrape Chittorgarh for current and upcoming mainboard IPOs."""
    all_ipos: list[IPOData] = []
    seen_names: set[str] = set()

    current = _scrape_page(CHITTORGARH_CURRENT_IPOS_URL, "current IPOs")
    for ipo in current:
        norm = normalize_name(ipo.issue_name)
        if norm not in seen_names:
            seen_names.add(norm)
            all_ipos.append(ipo)

    timetable = _scrape_page(CHITTORGARH_TIMETABLE_URL, "timetable")
    for ipo in timetable:
        norm = normalize_name(ipo.issue_name)
        if norm not in seen_names:
            seen_names.add(norm)
            all_ipos.append(ipo)

    upcoming = _scrape_page(CHITTORGARH_UPCOMING_URL, "upcoming IPOs")
    for ipo in upcoming:
        norm = normalize_name(ipo.issue_name)
        if norm not in seen_names:
            seen_names.add(norm)
            all_ipos.append(ipo)

    logger.info(f"[chittorgarh] Total: {len(all_ipos)} IPOs")
    return all_ipos


def _scrape_page(url: str, label: str) -> list[IPOData]:
    soup = fetch_html_js(url, source_name="chittorgarh", wait_selector="table", timeout_ms=20000)
    if not soup:
        logger.error(f"Failed to fetch Chittorgarh {label}")
        return []

    ipos = []
    tables = soup.find_all("table", class_=re.compile(r"table"))
    if not tables:
        tables = soup.find_all("table")

    for table in tables:
        thead = table.find("thead") or table.find("tr")
        if not thead:
            continue

        header_cells = thead.find_all(["th", "td"])
        headers = [clean_text(cell.get_text()).lower() for cell in header_cells]

        if not headers or len(headers) < 3:
            continue

        if not any(kw in " ".join(headers) for kw in ["ipo", "company", "issuer", "name"]):
            continue

        col_map = _map_columns(headers)
        if "name" not in col_map:
            continue

        tbody = table.find("tbody")
        rows = tbody.find_all("tr") if tbody else table.find_all("tr")[1:]

        for row in rows:
            cells = row.find_all("td")
            if len(cells) < 3:
                continue

            try:
                ipo = _parse_row(cells, col_map)
                if ipo and ipo.issue_name:
                    ipos.append(ipo)
            except Exception as e:
                logger.debug(f"Skipping row: {e}")

    logger.info(f"[chittorgarh] {label}: {len(ipos)} IPOs")
    return ipos


def _map_columns(headers: list[str]) -> dict:
    col_map = {}
    for i, h in enumerate(headers):
        if any(kw in h for kw in ["ipo", "company", "issuer", "name"]) and "name" not in col_map:
            col_map["name"] = i
        elif "open" in h and "open" not in col_map:
            col_map["open"] = i
        elif "close" in h and "close" not in col_map:
            col_map["close"] = i
        elif ("price" in h or "band" in h) and "price" not in col_map:
            col_map["price"] = i
        elif "size" in h and "lot" not in h and "size" not in col_map:
            col_map["size"] = i
        elif "lot" in h and "lot" not in col_map:
            col_map["lot"] = i
        elif "list" in h and "listing" not in col_map:
            col_map["listing"] = i
        elif ("allot" in h or "boa" in h) and "allotment" not in col_map:
            col_map["allotment"] = i
        elif "exchange" in h:
            col_map["exchange"] = i
    return col_map


def _parse_row(cells, col_map: dict) -> IPOData | None:
    def get_cell(key: str) -> str:
        idx = col_map.get(key)
        if idx is not None and idx < len(cells):
            return clean_text(cells[idx].get_text())
        return ""

    name = get_cell("name")
    if not name:
        return None

    name = re.sub(r'\s*IPO.*$', '', name, flags=re.IGNORECASE).strip()
    name = re.sub(r'\([^)]*\)\s*$', '', name).strip()
    if not name:
        return None

    exchange = get_cell("exchange").lower()
    if "sme" in exchange:
        return None

    detail_url = ""
    name_idx = col_map.get("name")
    if name_idx is not None and name_idx < len(cells):
        link = cells[name_idx].find("a")
        if link and link.get("href"):
            href = link["href"]
            if href.startswith("/"):
                detail_url = CHITTORGARH_BASE_URL + href
            elif href.startswith("http"):
                detail_url = href

    return IPOData(
        issue_name=name,
        ipo_type="Mainboard",
        source="chittorgarh",
        price_band=get_cell("price"),
        lot_size=get_cell("lot"),
        issue_size=get_cell("size"),
        issue_open=get_cell("open"),
        issue_close=get_cell("close"),
        allotment_date=get_cell("allotment"),
        listing_date=get_cell("listing"),
        detail_url=detail_url,
    )
