"""Circuit Breakers & 10%+ Gainers/Losers scraper from NSE API."""

import os
import sys
import requests
from pathlib import Path

# Add project root to sys.path to allow importing 'core'
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from core.logger import setup_logging
from core.io import safe_save, update_health, DATA_DIR

logger = setup_logging(__name__)
OUTPUT_FILE = DATA_DIR / "circuit_breakers.json"


def fetch_circuit_breakers():
    logger.info("Fetching 10%+ Gainers (Upper Circuit) and Losers (Lower Circuit) from NSE...")
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Accept": "*/*",
        "Accept-Language": "en-US,en;q=0.9",
    }
    session = requests.Session()
    session.headers.update(headers)

    try:
        session.get("https://www.nseindia.com", timeout=15)

        upper_circuits = _fetch_movers(session, "gainers", min_change=10.0)
        lower_circuits = _fetch_movers(session, "loosers", max_change=-10.0)

        data = {
            "upper_circuit": upper_circuits,
            "lower_circuit": lower_circuits,
        }

        total_records = len(upper_circuits) + len(lower_circuits)
        safe_save(
            data=data,
            pipeline_name="circuit_breakers",
            source_name="NSE India",
            file_path=OUTPUT_FILE,
            retention_threshold=0.80,
        )
        logger.info(
            f"[circuit_breakers] ✅ Saved {len(upper_circuits)} upper circuits and {len(lower_circuits)} lower circuits to {OUTPUT_FILE}"
        )
        return data
    except Exception as e:
        logger.error(f"Error fetching circuit breakers: {e}")
        update_health("circuit_breakers", "failed")
        return {"upper_circuit": [], "lower_circuit": []}


def _fetch_movers(session: requests.Session, index_param: str, min_change: float = None, max_change: float = None) -> list[dict]:
    url = f"https://www.nseindia.com/api/live-analysis-variations?index={index_param}"
    try:
        res = session.get(url, timeout=15)
        res.raise_for_status()
        raw = res.json()
        
        seen_symbols = set()
        movers = []

        # Inspect all relevant categories returned by NSE variations API
        categories = ["allSec", "SecGtr20", "SecLwr20", "FOSec", "NIFTY", "NIFTYNEXT50"]
        for cat in categories:
            items = raw.get(cat, {}).get("data", []) if isinstance(raw.get(cat), dict) else []
            for item in items:
                sym = item.get("symbol")
                if not sym or sym in seen_symbols:
                    continue

                chg = item.get("perChange", 0) or 0
                if min_change is not None and chg < min_change:
                    continue
                if max_change is not None and chg > max_change:
                    continue

                seen_symbols.add(sym)
                movers.append(
                    {
                        "symbol": sym,
                        "name": item.get("companyName", sym),
                        "last_price": item.get("ltp"),
                        "prev_close": item.get("prev_price"),
                        "change": item.get("net_price"),
                        "change_pct": round(chg, 2),
                        "volume": item.get("trade_quantity", 0),
                        "turnover_cr": round((item.get("turnover", 0) or 0) / 100, 2),  # turnover is usually in lakhs
                    }
                )

        # Sort by absolute percentage change descending
        movers.sort(key=lambda x: abs(x["change_pct"]), reverse=True)
        return movers
    except Exception as e:
        logger.error(f"Error fetching movers for {index_param}: {e}")
        return []


if __name__ == "__main__":
    try:
        fetch_circuit_breakers()
    except Exception as e:
        logger.error(f"Circuit breakers pipeline failed: {e}")
        update_health("circuit_breakers", "failed")
