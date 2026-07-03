"""Currency exchange rates pipeline using Yahoo Finance."""

import os
import sys
import yfinance as yf
from pathlib import Path

# Add project root to sys.path to allow importing 'core'
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from core.logger import setup_logging
from core.io import safe_save, update_health, DATA_DIR

logger = setup_logging(__name__)

OUTPUT_FILE = DATA_DIR / "currency.json"

SYMBOLS = {
    "INR=X": "USD / INR",
    "EURINR=X": "EUR / INR",
    "GBPINR=X": "GBP / INR",
    "JPYINR=X": "JPY / INR",
    "EURUSD=X": "EUR / USD",
}


def fetch_currency():
    logger.info("Fetching currency exchange rates from Yahoo Finance...")
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
                        "rate": round(current_price, 4),
                        "change": round(change, 4),
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
                            "rate": round(current_price, 4),
                            "change": round(change, 4),
                            "change_pct": round(change_pct, 2),
                        }
                    )
            except Exception as e2:
                logger.error(f"Fallback failed for {symbol}: {e2}")

    if data:
        safe_save(
            data=data,
            pipeline_name="currency",
            source_name="Yahoo Finance",
            file_path=OUTPUT_FILE,
            retention_threshold=0.80,
        )
        logger.info(f"[currency] ✅ Saved {len(data)} currency records to {OUTPUT_FILE}")
    else:
        logger.error("Failed to fetch currency data.")
        update_health("currency", "failed")


if __name__ == "__main__":
    try:
        fetch_currency()
    except Exception as e:
        logger.error(f"Currency pipeline failed: {e}")
        update_health("currency", "failed")
