import os
import sys
import requests
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from core.logger import setup_logging
from core.io import safe_save, DATA_DIR

logger = setup_logging(__name__)
OUTPUT_FILE = DATA_DIR / "high_low.json"

def fetch_nse_52week(session, index_type):
    """Fetch 52-week high or low data. index_type should be 'high' or 'low'."""
    url = f"https://www.nseindia.com/api/live-analysis-52Week?index={index_type}"
    try:
        response = session.get(url, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        # We generally want dataLtpGreater20 (stocks above 20 rs) for meaningful results
        items = data.get("dataLtpGreater20", [])
        
        parsed_items = []
        for item in items:
            parsed_items.append({
                "symbol": item.get("symbol"),
                "companyName": item.get("comapnyName", item.get("symbol")),  # NSE has a typo in their API
                "lastPrice": item.get("ltp"),
                "previousClose": item.get("prevClose"),
                "change": item.get("change"),
                "pChange": item.get("pChange"),
                "value52Week": item.get("new52WHL"),
                "type": index_type.upper()
            })
            
        return parsed_items
    except Exception as e:
        logger.error(f"Error fetching {index_type} data: {e}")
        return []

def scrape_high_low():
    logger.info("Fetching 52-Week Highs and Lows from NSE...")
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': '*/*',
        'Accept-Language': 'en-US,en;q=0.9',
    }
    
    session = requests.Session()
    session.headers.update(headers)
    
    try:
        logger.info("Establishing session with NSE...")
        session.get("https://www.nseindia.com", timeout=10)
        
        highs = fetch_nse_52week(session, 'high')
        logger.info(f"Scraped {len(highs)} stocks hitting 52W High.")
        
        lows = fetch_nse_52week(session, 'low')
        logger.info(f"Scraped {len(lows)} stocks hitting 52W Low.")
        
        return {
            "highs": highs,
            "lows": lows
        }
    except Exception as e:
        logger.error(f"Error during high/low scraping: {e}")
        return {"highs": [], "lows": []}

def main():
    data = scrape_high_low()
    if data["highs"] or data["lows"]:
        safe_save(
            data=[data], # Wrapped in list for consistent format
            pipeline_name="high_low",
            source_name="nse_india",
            file_path=OUTPUT_FILE,
            retention_threshold=0.20
        )

if __name__ == "__main__":
    main()
