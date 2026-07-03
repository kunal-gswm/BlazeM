"""Commodities pipeline using Yahoo Finance."""

import os
import sys
import yfinance as yf
from pathlib import Path

# Add project root to sys.path to allow importing 'core'
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from core.logger import setup_logging
from core.io import safe_save, update_health, DATA_DIR

logger = setup_logging(__name__)

OUTPUT_FILE = DATA_DIR / "commodities.json"

SYMBOLS = {
    "GC=F": "Gold",
    "SI=F": "Silver",
    "CL=F": "Crude Oil (WTI)",
    "BZ=F": "Brent Crude",
    "NG=F": "Natural Gas",
    "HG=F": "Copper",
    "PL=F": "Platinum",
}


def fetch_commodities():
    logger.info("Fetching commodity prices from Yahoo Finance...")
    tickers = yf.Tickers(" ".join(SYMBOLS.keys()))

    data = []
    for symbol, name in SYMBOLS.items():
        try:
            info = tickers.tickers[symbol].fast_info
            current_price = info.last_price
            prev_close = info.previous_close

            if current_price and prev_close:
                change = current_price - prev_close
                change_pct = (change / prev_close) * 100

                data.append(
                    {
                        "symbol": symbol,
                        "name": name,
                        "price": round(current_price, 4 if current_price < 10 else 2),
                        "change": round(change, 4 if abs(change) < 1 else 2),
                        "change_pct": round(change_pct, 2),
                    }
                )
        except Exception as e:
            logger.error(f"Failed fast_info for {symbol}: {e}. Trying fallback...")
            try:
                hist = tickers.tickers[symbol].history(period="5d")
                if len(hist) >= 2:
                    current_price = hist["Close"].iloc[-1]
                    prev_close = hist["Close"].iloc[-2]
                    change = current_price - prev_close
                    change_pct = (change / prev_close) * 100

                    data.append(
                        {
                            "symbol": symbol,
                            "name": name,
                            "price": round(current_price, 4 if current_price < 10 else 2),
                            "change": round(change, 4 if abs(change) < 1 else 2),
                            "change_pct": round(change_pct, 2),
                        }
                    )
            except Exception as e2:
                logger.error(f"Fallback failed for {symbol}: {e2}")

    if data:
        safe_save(
            data=data,
            pipeline_name="commodities",
            source_name="Yahoo Finance",
            file_path=OUTPUT_FILE,
            retention_threshold=0.80,
        )
        logger.info(f"[commodities] ✅ Saved {len(data)} commodity records to {OUTPUT_FILE}")
    else:
        logger.error("Failed to fetch commodities data.")
        update_health("commodities", "failed")


if __name__ == "__main__":
    try:
        fetch_commodities()
    except Exception as e:
        logger.error(f"Commodities pipeline failed: {e}")
        update_health("commodities", "failed")
