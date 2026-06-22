import json
import os
import sys
import yfinance as yf
from pathlib import Path
from datetime import datetime, timezone

# Add project root to sys.path to allow importing 'core'
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from core.logger import setup_logging
from core.io import safe_save

logger = setup_logging(__name__)

OUTPUT_DIR = Path("data")
OUTPUT_FILE = OUTPUT_DIR / "global_indices.json"

SYMBOLS = {
    "^GSPC": "S&P 500",
    "^DJI": "Dow Jones Industrial Average",
    "^IXIC": "NASDAQ Composite",
    "^VIX": "CBOE Volatility Index",
    "^NSEI": "Nifty 50",
    "^BSESN": "BSE Sensex",
}


def fetch_indices():
    logger.info("Fetching global indices and VIX from Yahoo Finance...")
    tickers = yf.Tickers(" ".join(SYMBOLS.keys()))

    data = []
    for symbol, name in SYMBOLS.items():
        try:
            info = tickers.tickers[symbol].fast_info

            # fast_info is much faster and doesn't rely on the heavy 'info' dict which gets rate-limited easily
            current_price = info.last_price
            prev_close = info.previous_close

            if current_price and prev_close:
                change = current_price - prev_close
                change_pct = (change / prev_close) * 100

                data.append(
                    {
                        "symbol": symbol,
                        "name": name,
                        "price": round(current_price, 2),
                        "change": round(change, 2),
                        "change_pct": round(change_pct, 2),
                    }
                )
        except Exception as e:
            logger.error(
                f"Failed to fetch {symbol} using fast_info. Trying fallback... {e}"
            )
            try:
                # Fallback to history
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
                            "price": round(current_price, 2),
                            "change": round(change, 2),
                            "change_pct": round(change_pct, 2),
                        }
                    )
            except Exception as e2:
                logger.error(f"Fallback also failed for {symbol}: {e2}")

    if data:
        safe_save(
            data=data,
            pipeline_name="global_indices",
            source_name="Yahoo Finance",
            file_path=OUTPUT_FILE,
            retention_threshold=0.90
        )
    else:
        logger.error("Failed to fetch global indices data.")
        from core.io import update_health
        update_health("global_indices", "failed")


if __name__ == "__main__":
    try:
        fetch_indices()
    except Exception as e:
        logger.error(f"Global indices pipeline failed: {e}")
        from core.io import update_health
        update_health("global_indices", "failed")
