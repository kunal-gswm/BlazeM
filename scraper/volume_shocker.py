"""Volume Shocker (unusual volume breakouts) scraper from NSE API."""

import os
import sys
import requests
from pathlib import Path

# Add project root to sys.path to allow importing 'core'
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from core.logger import setup_logging
from core.io import safe_save, update_health, DATA_DIR

logger = setup_logging(__name__)
OUTPUT_FILE = DATA_DIR / "volume_shocker.json"


def fetch_volume_shockers():
    logger.info("Fetching Volume Shockers from NSE API...")
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Accept": "*/*",
        "Accept-Language": "en-US,en;q=0.9",
    }
    session = requests.Session()
    session.headers.update(headers)

    try:
        session.get("https://www.nseindia.com", timeout=15)
        url = "https://www.nseindia.com/api/live-analysis-volume-gainers"
        response = session.get(url, timeout=15)
        response.raise_for_status()
        raw = response.json()
        items = raw.get("data", [])

        shockers = []
        for item in items:
            vol = item.get("volume", 0)
            if vol < 10000:  # Filter out extremely illiquid penny stocks
                continue

            w1_chg = item.get("week1volChange", 0) or 0
            w2_chg = item.get("week2volChange", 0) or 0

            shockers.append(
                {
                    "symbol": item.get("symbol"),
                    "name": item.get("companyName", item.get("symbol")),
                    "last_price": item.get("ltp"),
                    "change_pct": item.get("pChange"),
                    "volume": vol,
                    "turnover_cr": round((item.get("turnover", 0) or 0) / 100, 2),  # turnover is in lakhs usually
                    "vol_change_1wk_pct": round(w1_chg, 2),
                    "vol_change_2wk_pct": round(w2_chg, 2),
                }
            )

        # Sort by highest 1-week volume change multiple
        shockers.sort(key=lambda x: x["vol_change_1wk_pct"], reverse=True)
        top_shockers = shockers[:50]

        safe_save(
            data=top_shockers,
            pipeline_name="volume_shocker",
            source_name="NSE India",
            file_path=OUTPUT_FILE,
            retention_threshold=0.80,
        )
        logger.info(f"[volume_shocker] ✅ Saved {len(top_shockers)} records to {OUTPUT_FILE}")
        return top_shockers
    except Exception as e:
        logger.error(f"Error fetching volume shockers: {e}")
        update_health("volume_shocker", "failed")
        return []


if __name__ == "__main__":
    try:
        fetch_volume_shockers()
    except Exception as e:
        logger.error(f"Volume shockers pipeline failed: {e}")
        update_health("volume_shocker", "failed")
