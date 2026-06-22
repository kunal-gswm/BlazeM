"""InvestorGain scraper — primary source for GMP + IPO details in a single table."""

import logging
import re
from scraper.models import IPOData
from core.config import INVESTORGAIN_GMP_URL, INVESTORGAIN_BASE_URL
from core.utils import fetch_html_js, clean_text

logger = logging.getLogger(__name__)

def parse_gmp(gmp_str: str) -> float | None:
    if not gmp_str:
        return None
    clean = re.sub(r'[^\d.]', '', gmp_str)
    try:
        return float(clean) if clean else None
    except ValueError:
        return None


def scrape_investorgain() -> list[IPOData]:
    """Scrape the InvestorGain live GMP table for mainboard IPOs."""
    soup = fetch_html_js(
        INVESTORGAIN_GMP_URL,
        source_name="investorgain",
        wait_selector="table",
        timeout_ms=10000,
    )
    if not soup:
        logger.error("Failed to fetch InvestorGain GMP page")
        return []

    ipos = []

    tables = soup.find_all("table", class_=re.compile(r"table"))
    if not tables:
        tables = soup.find_all("table")

    for table in tables:
        thead = table.find("thead")
        if not thead:
            continue

        headers = []
        for th in thead.find_all("th"):
            headers.append(clean_text(th.get_text()))

        if not headers:
            continue

        header_lower = [h.lower() for h in headers]
        has_ipo_col = any(
            kw in " ".join(header_lower) for kw in ["ipo", "company", "name", "issue"]
        )
        if not has_ipo_col:
            continue

        col_map = _map_columns(headers)
        if col_map.get("name") is None:
            continue

        tbody = table.find("tbody")
        if not tbody:
            continue

        for tr in tbody.find_all("tr"):
            tds = tr.find_all("td")
            if len(tds) < 3:
                continue

            try:
                ipo = _parse_row(tds, col_map)
                if ipo and ipo.issue_name:
                    ipos.append(ipo)
            except Exception as e:
                logger.debug(f"Skipping row: {e}")

    logger.info(f"[investorgain] Scraped {len(ipos)} IPOs")
    return ipos


def _map_columns(headers: list[str]) -> dict:
    col_map = {}
    for i, h in enumerate(headers):
        hl = h.lower()
        if any(kw in hl for kw in ["ipo", "company", "name"]) and "name" not in col_map:
            col_map["name"] = i
        elif (
            "price" in hl
            and "est" not in hl
            and "list" not in hl
            and "price" not in col_map
        ):
            col_map["price"] = i
        elif "gmp" in hl and "%" not in hl and "gmp" not in col_map:
            col_map["gmp"] = i
        elif "%" in hl or "gmp%" in hl.replace(" ", ""):
            col_map["gmp_pct"] = i
        elif "est" in hl and ("list" in hl or "price" in hl):
            col_map["est_listing"] = i
        elif "size" in hl:
            col_map["size"] = i
        elif "lot" in hl:
            col_map["lot"] = i
        elif "open" in hl:
            col_map["open"] = i
        elif "close" in hl:
            col_map["close"] = i
        elif "boa" in hl or "allot" in hl:
            col_map["allotment"] = i
        elif "list" in hl and "est" not in hl:
            col_map["listing"] = i
    return col_map


def _parse_row(tds, col_map: dict) -> IPOData | None:
    def get_cell(key: str) -> str:
        idx = col_map.get(key)
        if idx is not None and idx < len(tds):
            return clean_text(tds[idx].get_text())
        return ""

    name = get_cell("name")
    if not name:
        return None

    name_clean = re.sub(r"\s*IPO.*$", "", name, flags=re.IGNORECASE).strip()
    name_clean = re.sub(r"\s*[UOLC]$", "", name_clean).strip()
    name_clean = re.sub(r"\s*L@[\d.]+\s*\([^)]*\)\s*$", "", name_clean).strip()
    if not name_clean:
        name_clean = name

    raw_gmp = get_cell("gmp")
    gmp_clean = _clean_gmp(raw_gmp)
    gmp_pct = _extract_gmp_pct(raw_gmp)

    def clean_date(val: str) -> str:
        if not val:
            return ""
        return re.sub(r"GMP:?\s*[\d.]+.*$", "", val, flags=re.IGNORECASE).strip()

    detail_url = ""
    name_idx = col_map.get("name")
    if name_idx is not None and name_idx < len(tds):
        link = tds[name_idx].find("a")
        if link and link.get("href"):
            href = link["href"]
            if href.startswith("/"):
                detail_url = INVESTORGAIN_BASE_URL + href
            elif href.startswith("http"):
                detail_url = href

    return IPOData(
        issue_name=name_clean,
        ipo_type="Mainboard",
        source="investorgain",
        price_band=get_cell("price"),
        gmp=parse_gmp(gmp_clean),
        gmp_percent=gmp_pct or get_cell("gmp_pct"),
        issue_size=get_cell("size"),
        lot_size=get_cell("lot"),
        issue_open=clean_date(get_cell("open")),
        issue_close=clean_date(get_cell("close")),
        allotment_date=clean_date(get_cell("allotment")),
        listing_date=clean_date(get_cell("listing")),
        detail_url=detail_url,
    )


def _clean_gmp(raw: str) -> str:
    if not raw:
        return ""
    m = re.match(r"(₹[\d.]+)", raw)
    if m:
        return m.group(1)
    if "₹--" in raw:
        return "₹0"
    return raw.split("(")[0].strip() if "(" in raw else raw


def _extract_gmp_pct(raw: str) -> str:
    if not raw:
        return ""
    m = re.search(r"\((\d+\.?\d*%)\)", raw)
    return m.group(1) if m else ""
