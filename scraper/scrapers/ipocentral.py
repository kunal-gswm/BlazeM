"""IPO Central scraper — GMP page + individual IPO detail pages."""

import logging
import re
from scrapers.base import BaseScraper
from models import IPOData
from config import (
    IPOCENTRAL_GMP_URL,
    IPOCENTRAL_IPO_LIST_URL,
    IPOCENTRAL_BASE_URL,
)

logger = logging.getLogger(__name__)


class IPOCentralScraper(BaseScraper):
    source_name = "ipocentral"

    def scrape(self) -> list[IPOData]:
        """Scrape IPO Central for GMP data and IPO details."""
        ipos: list[IPOData] = []

        # Step 1: Scrape the GMP table
        gmp_ipos = self._scrape_gmp_page()
        ipos.extend(gmp_ipos)

        # Step 2: Scrape the IPO list page for additional details
        list_ipos = self._scrape_ipo_list()

        # Merge list data into GMP data where names match
        gmp_names = {self._normalize_name(ipo.issue_name) for ipo in ipos}
        for ipo in list_ipos:
            norm = self._normalize_name(ipo.issue_name)
            if norm not in gmp_names:
                ipos.append(ipo)

        # Step 3: Enrich with detail pages (face value, lot size, etc.)
        self._enrich_from_detail_pages(ipos)

        logger.info(f"[ipocentral] Total: {len(ipos)} IPOs")
        return ipos

    def _scrape_gmp_page(self) -> list[IPOData]:
        """Scrape the GMP discussion page for the GMP table."""
        soup = self.fetch_html(IPOCENTRAL_GMP_URL)
        if not soup:
            logger.error("Failed to fetch IPO Central GMP page")
            return []

        ipos = []

        # Look for tables in the main content area (skip navigation)
        content = soup.find("div", class_=re.compile(r"entry-content|post-content|article"))
        if not content:
            # Fallback to body
            content = soup

        tables = content.find_all("table")
        for table in tables:
            rows = table.find_all("tr")
            if len(rows) < 2:
                continue

            # Check header row
            header_row = rows[0]
            headers = [self.clean_text(cell.get_text()) for cell in header_row.find_all(["th", "td"])]
            header_lower = [h.lower() for h in headers]

            # Must look like a GMP table
            if not any("ipo" in h or "name" in h for h in header_lower):
                continue

            # Map columns
            col_map = {}
            for i, h in enumerate(header_lower):
                if any(kw in h for kw in ["ipo", "name", "company"]) and "name" not in col_map:
                    col_map["name"] = i
                elif "price" in h and "price" not in col_map:
                    col_map["price"] = i
                elif "gmp" in h and "%" not in h and "gmp" not in col_map:
                    col_map["gmp"] = i
                elif "%" in h:
                    col_map["gmp_pct"] = i

            if "name" not in col_map:
                continue

            # Parse data rows
            for row in rows[1:]:
                cells = row.find_all(["th", "td"])
                if len(cells) < 2:
                    continue

                name_idx = col_map.get("name", 0)
                if name_idx >= len(cells):
                    continue

                name_cell = cells[name_idx]
                name = self.clean_text(name_cell.get_text())
                if not name:
                    continue

                # Clean name
                # Clean name: remove "IPO" suffix and trailing parentheses (like dates)
                name = re.sub(r'\s*IPO.*$', '', name, flags=re.IGNORECASE).strip()
                name = re.sub(r'\([^)]*\)\s*$', '', name).strip()

                # Get detail URL
                detail_url = ""
                link = name_cell.find("a")
                if link and link.get("href"):
                    href = link["href"]
                    if href.startswith("/"):
                        detail_url = IPOCENTRAL_BASE_URL + href
                    elif href.startswith("http"):
                        detail_url = href

                def get_cell(key):
                    idx = col_map.get(key)
                    if idx is not None and idx < len(cells):
                        return self.clean_text(cells[idx].get_text())
                    return ""

                ipos.append(IPOData(
                    issue_name=name,
                    source="ipocentral",
                    price_band=get_cell("price"),
                    gmp=get_cell("gmp"),
                    gmp_percent=get_cell("gmp_pct"),
                    detail_url=detail_url,
                ))

        logger.info(f"[ipocentral] GMP page: {len(ipos)} IPOs")
        return ipos

    def _scrape_ipo_list(self) -> list[IPOData]:
        """Scrape the yearly IPO list page."""
        soup = self.fetch_html(IPOCENTRAL_IPO_LIST_URL)
        if not soup:
            return []

        ipos = []
        content = soup.find("div", class_=re.compile(r"entry-content|post-content|article"))
        if not content:
            content = soup

        tables = content.find_all("table")
        for table in tables:
            rows = table.find_all("tr")
            if len(rows) < 2:
                continue

            headers = [self.clean_text(cell.get_text()).lower() for cell in rows[0].find_all(["th", "td"])]

            # Map columns from the IPO list table
            col_map = {}
            for i, h in enumerate(headers):
                if any(kw in h for kw in ["ipo", "name", "company", "issue"]) and "name" not in col_map:
                    col_map["name"] = i
                elif "open" in h:
                    col_map["open"] = i
                elif "close" in h:
                    col_map["close"] = i
                elif "price" in h or "band" in h:
                    col_map["price"] = i
                elif "size" in h:
                    col_map["size"] = i
                elif "lot" in h:
                    col_map["lot"] = i
                elif "list" in h:
                    col_map["listing"] = i
                elif "allot" in h:
                    col_map["allotment"] = i

            if "name" not in col_map:
                continue

            for row in rows[1:]:
                cells = row.find_all(["th", "td"])
                if len(cells) < 2:
                    continue

                name_idx = col_map.get("name", 0)
                if name_idx >= len(cells):
                    continue

                name = self.clean_text(cells[name_idx].get_text())
                # Clean name: remove "IPO" suffix and trailing parentheses (like dates)
                name = re.sub(r'\s*IPO.*$', '', name, flags=re.IGNORECASE).strip()
                name = re.sub(r'\([^)]*\)\s*$', '', name).strip()
                if not name:
                    continue

                detail_url = ""
                link = cells[name_idx].find("a")
                if link and link.get("href"):
                    href = link["href"]
                    if href.startswith("/"):
                        detail_url = IPOCENTRAL_BASE_URL + href
                    elif href.startswith("http"):
                        detail_url = href

                def get_cell(key):
                    idx = col_map.get(key)
                    if idx is not None and idx < len(cells):
                        return self.clean_text(cells[idx].get_text())
                    return ""

                ipos.append(IPOData(
                    issue_name=name,
                    source="ipocentral",
                    price_band=get_cell("price"),
                    issue_size=get_cell("size"),
                    lot_size=get_cell("lot"),
                    issue_open=get_cell("open"),
                    issue_close=get_cell("close"),
                    allotment_date=get_cell("allotment"),
                    listing_date=get_cell("listing"),
                    detail_url=detail_url,
                ))

        logger.info(f"[ipocentral] IPO list: {len(ipos)} IPOs")
        return ipos

    def _enrich_from_detail_pages(self, ipos: list[IPOData]):
        """Visit individual IPO detail pages to fill in missing fields like face value."""
        for ipo in ipos:
            if not ipo.detail_url:
                continue

            # Only fetch if we're missing key fields
            if ipo.face_value and ipo.lot_size and ipo.issue_size:
                continue

            soup = self.fetch_html(ipo.detail_url)
            if not soup:
                continue

            content = soup.find("div", class_=re.compile(r"entry-content|post-content|article"))
            if not content:
                content = soup

            # Look for key-value pairs in tables on the detail page
            for table in content.find_all("table"):
                for row in table.find_all("tr"):
                    cells = row.find_all(["th", "td"])
                    if len(cells) < 2:
                        continue

                    label = self.clean_text(cells[0].get_text()).lower()
                    value = self.clean_text(cells[1].get_text())

                    if not value:
                        continue

                    if "face value" in label and not ipo.face_value:
                        ipo.face_value = value
                    elif "lot size" in label and not ipo.lot_size:
                        ipo.lot_size = value
                    elif "issue size" in label and not ipo.issue_size:
                        ipo.issue_size = value
                    elif "price band" in label and not ipo.price_band:
                        ipo.price_band = value
                    elif ("open" in label and "date" in label) and not ipo.issue_open:
                        ipo.issue_open = value
                    elif ("close" in label and "date" in label) and not ipo.issue_close:
                        ipo.issue_close = value
                    elif "allotment" in label and not ipo.allotment_date:
                        ipo.allotment_date = value
                    elif "listing" in label and "date" in label and not ipo.listing_date:
                        ipo.listing_date = value

            logger.debug(f"[ipocentral] Enriched: {ipo.issue_name}")

    @staticmethod
    def _normalize_name(name: str) -> str:
        """Normalize IPO name for dedup matching."""
        name = name.lower().strip()
        name = re.sub(r'\s*(ipo|limited|ltd|pvt)\.?\s*', ' ', name)
        name = re.sub(r'[^a-z0-9\s]', '', name)
        return " ".join(name.split())
