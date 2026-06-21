"""InvestorGain scraper — primary source for GMP + IPO details in a single table."""

import logging
import re
from scrapers.base import BaseScraper
from models import IPOData
from config import INVESTORGAIN_GMP_URL, INVESTORGAIN_BASE_URL

logger = logging.getLogger(__name__)


class InvestorGainScraper(BaseScraper):
    source_name = "investorgain"

    def scrape(self) -> list[IPOData]:
        """Scrape the InvestorGain live GMP table for mainboard IPOs."""
        soup = self.fetch_html_js(
            INVESTORGAIN_GMP_URL,
            wait_selector="table.table",
            timeout_ms=20000,
        )
        if not soup:
            logger.error("Failed to fetch InvestorGain GMP page")
            return []

        ipos = []

        # Find all tables — the GMP data is in a responsive table
        tables = soup.find_all("table", class_=re.compile(r"table"))
        if not tables:
            # Fallback: try any table
            tables = soup.find_all("table")

        for table in tables:
            thead = table.find("thead")
            if not thead:
                continue

            # Get column headers
            headers = []
            for th in thead.find_all("th"):
                headers.append(self.clean_text(th.get_text()))

            if not headers:
                continue

            # Check if this looks like a GMP table (must have IPO name-ish column)
            header_lower = [h.lower() for h in headers]
            has_ipo_col = any(
                kw in " ".join(header_lower)
                for kw in ["ipo", "company", "name", "issue"]
            )
            if not has_ipo_col:
                continue

            # Map column indices
            col_map = self._map_columns(headers)
            if col_map.get("name") is None:
                continue

            # Parse rows
            tbody = table.find("tbody")
            if not tbody:
                continue

            for tr in tbody.find_all("tr"):
                tds = tr.find_all("td")
                if len(tds) < 3:
                    continue

                try:
                    ipo = self._parse_row(tds, col_map)
                    if ipo and ipo.issue_name:
                        ipos.append(ipo)
                except Exception as e:
                    logger.debug(f"Skipping row: {e}")

        logger.info(f"[investorgain] Scraped {len(ipos)} IPOs")
        return ipos

    def _map_columns(self, headers: list[str]) -> dict:
        """Map header names to column indices."""
        col_map = {}
        for i, h in enumerate(headers):
            hl = h.lower()
            if any(kw in hl for kw in ["ipo", "company", "name"]) and "name" not in col_map:
                col_map["name"] = i
            elif "price" in hl and "est" not in hl and "list" not in hl and "price" not in col_map:
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

    def _parse_row(self, tds, col_map: dict) -> IPOData | None:
        """Parse a single table row into IPOData."""

        def get_cell(key: str) -> str:
            idx = col_map.get(key)
            if idx is not None and idx < len(tds):
                return self.clean_text(tds[idx].get_text())
            return ""

        name = get_cell("name")
        if not name:
            return None

        # Clean IPO name:
        # 1. Remove status badges: trailing single chars like U(upcoming), O(open), L(listed), C(closed)
        # 2. Remove listing price info: "L@268 (39.58%)"
        # 3. Remove "IPO" suffix
        name_clean = re.sub(r'\s*IPO.*$', '', name, flags=re.IGNORECASE).strip()
        # Remove trailing status badges (single uppercase letter at end)
        name_clean = re.sub(r'\s*[UOLC]$', '', name_clean).strip()
        # Remove "L@price (%)" pattern
        name_clean = re.sub(r'\s*L@[\d.]+\s*\([^)]*\)\s*$', '', name_clean).strip()
        if not name_clean:
            name_clean = name

        # Clean GMP: extract just the amount, e.g. "₹4 (3.54%)4 ↓ / 4 ↑" -> "₹4"
        raw_gmp = get_cell("gmp")
        gmp_clean = self._clean_gmp(raw_gmp)
        gmp_pct = self._extract_gmp_pct(raw_gmp)

        # Clean date fields: remove GMP overlay text like "19-JunGMP: 3"
        def clean_date(val: str) -> str:
            if not val:
                return ""
            val = re.sub(r'GMP:?\s*[\d.]+.*$', '', val, flags=re.IGNORECASE).strip()
            return val

        # Get detail URL if the name cell has a link
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
            gmp=gmp_clean,
            gmp_percent=gmp_pct or get_cell("gmp_pct"),
            issue_size=get_cell("size"),
            lot_size=get_cell("lot"),
            issue_open=clean_date(get_cell("open")),
            issue_close=clean_date(get_cell("close")),
            allotment_date=clean_date(get_cell("allotment")),
            listing_date=clean_date(get_cell("listing")),
            detail_url=detail_url,
        )

    @staticmethod
    def _clean_gmp(raw: str) -> str:
        """Extract clean GMP amount from messy cell text.

        Examples:
          '₹4 (3.54%)4 ↓ / 4 ↑' -> '₹4'
          '₹-- (0.00%)0 ↓ / 0 ↑' -> '₹0'
          '₹66.5 (34.64%)24 ↓ / 71 ↑' -> '₹66.5'
        """
        if not raw:
            return ""
        # Try to match ₹<amount>
        m = re.match(r'(₹[\d.]+)', raw)
        if m:
            return m.group(1)
        # Handle ₹-- case
        if '₹--' in raw:
            return '₹0'
        return raw.split('(')[0].strip() if '(' in raw else raw

    @staticmethod
    def _extract_gmp_pct(raw: str) -> str:
        """Extract GMP percentage from the combined cell.

        Example: '₹4 (3.54%)4 ↓ / 4 ↑' -> '3.54%'
        """
        if not raw:
            return ""
        m = re.search(r'\((\d+\.?\d*%)\)', raw)
        return m.group(1) if m else ""
