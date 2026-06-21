"""Chittorgarh scraper — current and upcoming mainboard IPO listing details."""

import logging
import re
from scrapers.base import BaseScraper
from models import IPOData
from config import (
    CHITTORGARH_CURRENT_IPOS_URL,
    CHITTORGARH_TIMETABLE_URL,
    CHITTORGARH_UPCOMING_URL,
    CHITTORGARH_BASE_URL,
)

logger = logging.getLogger(__name__)


class ChittorgarhScraper(BaseScraper):
    source_name = "chittorgarh"

    def scrape(self) -> list[IPOData]:
        """Scrape Chittorgarh for current and upcoming mainboard IPOs."""
        all_ipos: list[IPOData] = []
        seen_names: set[str] = set()

        # Scrape current IPOs
        current = self._scrape_page(CHITTORGARH_CURRENT_IPOS_URL, "current IPOs")
        for ipo in current:
            norm = self._normalize_name(ipo.issue_name)
            if norm not in seen_names:
                seen_names.add(norm)
                all_ipos.append(ipo)

        # Scrape timetable page (has lot size, dates)
        timetable = self._scrape_page(CHITTORGARH_TIMETABLE_URL, "timetable")
        for ipo in timetable:
            norm = self._normalize_name(ipo.issue_name)
            if norm not in seen_names:
                seen_names.add(norm)
                all_ipos.append(ipo)

        # Scrape upcoming IPOs
        upcoming = self._scrape_page(CHITTORGARH_UPCOMING_URL, "upcoming IPOs")
        for ipo in upcoming:
            norm = self._normalize_name(ipo.issue_name)
            if norm not in seen_names:
                seen_names.add(norm)
                all_ipos.append(ipo)

        logger.info(f"[chittorgarh] Total: {len(all_ipos)} IPOs")
        return all_ipos

    def _scrape_page(self, url: str, label: str) -> list[IPOData]:
        """Scrape a single Chittorgarh report page."""
        soup = self.fetch_html_js(url, wait_selector="table", timeout_ms=20000)
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

            # Get headers
            header_cells = thead.find_all(["th", "td"])
            headers = [self.clean_text(cell.get_text()).lower() for cell in header_cells]

            if not headers or len(headers) < 3:
                continue

            # Must have IPO/company name column
            if not any(kw in " ".join(headers) for kw in ["ipo", "company", "issuer", "name"]):
                continue

            col_map = self._map_columns(headers)
            if "name" not in col_map:
                continue

            # Parse rows from tbody or remaining trs
            tbody = table.find("tbody")
            rows = tbody.find_all("tr") if tbody else table.find_all("tr")[1:]

            for row in rows:
                cells = row.find_all("td")
                if len(cells) < 3:
                    continue

                try:
                    ipo = self._parse_row(cells, col_map)
                    if ipo and ipo.issue_name:
                        ipos.append(ipo)
                except Exception as e:
                    logger.debug(f"Skipping row: {e}")

        logger.info(f"[chittorgarh] {label}: {len(ipos)} IPOs")
        return ipos

    def _map_columns(self, headers: list[str]) -> dict:
        """Map Chittorgarh table headers to column indices."""
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
            elif "face" in h:
                col_map["face_value"] = i
        return col_map

    def _parse_row(self, cells, col_map: dict) -> IPOData | None:
        """Parse a Chittorgarh table row into IPOData."""

        def get_cell(key: str) -> str:
            idx = col_map.get(key)
            if idx is not None and idx < len(cells):
                return self.clean_text(cells[idx].get_text())
            return ""

        name = get_cell("name")
        if not name:
            return None

        # Clean name
        name = re.sub(r'\s*IPO.*$', '', name, flags=re.IGNORECASE).strip()
        name = re.sub(r'\([^)]*\)\s*$', '', name).strip()
        if not name:
            return None

        # Skip SME entries if exchange column indicates SME
        exchange = get_cell("exchange").lower()
        if "sme" in exchange:
            return None

        # Get detail URL
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
            face_value=get_cell("face_value"),
            lot_size=get_cell("lot"),
            issue_size=get_cell("size"),
            issue_open=get_cell("open"),
            issue_close=get_cell("close"),
            allotment_date=get_cell("allotment"),
            listing_date=get_cell("listing"),
            detail_url=detail_url,
        )

    @staticmethod
    def _normalize_name(name: str) -> str:
        """Normalize for dedup."""
        name = name.lower().strip()
        name = re.sub(r'\s*(ipo|limited|ltd|pvt)\.?\s*', ' ', name)
        name = re.sub(r'[^a-z0-9\s]', '', name)
        return " ".join(name.split())
