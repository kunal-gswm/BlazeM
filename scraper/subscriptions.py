"""Scraper for live IPO subscription ratios from Chittorgarh."""

import logging
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from core.utils import fetch_html_js, clean_text
from scraper.transform import normalize_name

logger = logging.getLogger(__name__)

SUBSCRIPTION_URL = "https://www.chittorgarh.com/report/ipo-subscription-status-live/21/mainboard/"


def scrape_subscriptions() -> dict[str, dict[str, str]]:
    """Scrape live IPO subscription ratios and return mapped by normalized company name."""
    logger.info("Fetching live IPO subscription status from Chittorgarh...")
    soup = fetch_html_js(
        SUBSCRIPTION_URL,
        source_name="chittorgarh_subs",
        wait_selector="table",
        timeout_ms=20000,
    )
    if not soup:
        logger.error("Failed to fetch Chittorgarh live subscription page")
        return {}

    table = soup.find("table")
    if not table:
        logger.error("No table found on Chittorgarh subscription page")
        return {}

    thead = table.find("thead") or table.find("tr")
    if not thead:
        return {}

    headers = [clean_text(cell.get_text()).lower() for cell in thead.find_all(["th", "td"])]
    col_map = _map_subs_columns(headers)
    if "name" not in col_map:
        logger.error("Could not locate company name column in subscription table")
        return {}

    tbody = table.find("tbody")
    rows = tbody.find_all("tr") if tbody else table.find_all("tr")[1:]

    subs_data = {}
    for row in rows:
        cells = row.find_all("td")
        if len(cells) < 4:
            continue

        def get_val(key: str) -> str:
            idx = col_map.get(key)
            if idx is not None and idx < len(cells):
                val = clean_text(cells[idx].get_text())
                return val if val != "-" else ""
            return ""

        raw_name = get_val("name")
        if not raw_name:
            continue

        # Clean name like "Knack Packaging Ltd. CT" -> "Knack Packaging"
        clean_name = re.sub(r"\s+CT\s*$", "", raw_name, flags=re.IGNORECASE).strip()
        norm_name = normalize_name(clean_name)

        qib = get_val("qib")
        nii = get_val("nii") or get_val("bnii") or get_val("snii")
        retail = get_val("retail")
        total = get_val("total")
        apps = get_val("applications")

        if total or qib or retail:
            subs_data[norm_name] = {
                "subscription_qib": f"{qib}x" if qib and not qib.endswith("x") else qib,
                "subscription_nii": f"{nii}x" if nii and not nii.endswith("x") else nii,
                "subscription_retail": f"{retail}x" if retail and not retail.endswith("x") else retail,
                "subscription_total": f"{total}x" if total and not total.endswith("x") else total,
                "subscription_applications": apps,
            }

    logger.info(f"[subscriptions] Scraped live subscription data for {len(subs_data)} IPOs")
    return subs_data


def _map_subs_columns(headers: list[str]) -> dict:
    col_map = {}
    for i, h in enumerate(headers):
        if any(kw in h for kw in ["company", "issuer", "name"]) and "name" not in col_map:
            col_map["name"] = i
        elif "qib" in h and "qib" not in col_map:
            col_map["qib"] = i
        elif "bnii" in h and "bnii" not in col_map:
            col_map["bnii"] = i
        elif "snii" in h and "snii" not in col_map:
            col_map["snii"] = i
        elif "nii" in h and "snii" not in h and "bnii" not in h and "nii" not in col_map:
            col_map["nii"] = i
        elif "retail" in h and "retail" not in col_map:
            col_map["retail"] = i
        elif "total" in h and "issue" not in h and "total" not in col_map:
            col_map["total"] = i
        elif "application" in h and "applications" not in col_map:
            col_map["applications"] = i
    return col_map


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    res = scrape_subscriptions()
    for k, v in list(res.items())[:5]:
        print(f"{k}: {v}")
