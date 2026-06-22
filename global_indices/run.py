import json
import logging
import yfinance as yf
from pathlib import Path
from datetime import datetime

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")

OUTPUT_DIR = Path("data")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

SYMBOLS = {
    "^GSPC": "S&P 500",
    "^DJI": "Dow Jones Industrial Average",
    "^IXIC": "NASDAQ Composite",
    "^VIX": "CBOE Volatility Index",
    "^NSEI": "Nifty 50",
    "^BSESN": "BSE Sensex"
}

def fetch_indices():
    logging.info("Fetching global indices and VIX from Yahoo Finance...")
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
                
                data.append({
                    "symbol": symbol,
                    "name": name,
                    "price": round(current_price, 2),
                    "change": round(change, 2),
                    "change_pct": round(change_pct, 2)
                })
        except Exception as e:
            logging.error(f"Failed to fetch {symbol} using fast_info. Trying fallback... {e}")
            try:
                # Fallback to history
                hist = tickers.tickers[symbol].history(period="5d")
                if len(hist) >= 2:
                    current_price = hist['Close'].iloc[-1]
                    prev_close = hist['Close'].iloc[-2]
                    change = current_price - prev_close
                    change_pct = (change / prev_close) * 100
                    
                    data.append({
                        "symbol": symbol,
                        "name": name,
                        "price": round(current_price, 2),
                        "change": round(change, 2),
                        "change_pct": round(change_pct, 2)
                    })
            except Exception as e2:
                logging.error(f"Fallback also failed for {symbol}: {e2}")

    if data:
        out_file = OUTPUT_DIR / "global_indices.json"
        payload = {
            "last_updated": datetime.utcnow().isoformat() + "Z",
            "indices": data
        }
        with open(out_file, "w") as f:
            json.dump(payload, f, indent=2)
        logging.info(f"Successfully saved global indices to {out_file}")

if __name__ == "__main__":
    fetch_indices()
