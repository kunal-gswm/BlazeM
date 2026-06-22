import os
import sys
import json
import requests
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from core.logger import setup_logging
from core.io import safe_save, DATA_DIR

logger = setup_logging(__name__)
OUTPUT_FILE = DATA_DIR / "sector_performance.json"

SECTOR_INDICES = [
    "NIFTY BANK",
    "NIFTY AUTO",
    "NIFTY FINANCIAL SERVICES",
    "NIFTY FMCG",
    "NIFTY IT",
    "NIFTY MEDIA",
    "NIFTY METAL",
    "NIFTY PHARMA",
    "NIFTY PSU BANK",
    "NIFTY REALTY",
    "NIFTY PVT BANK"
]

def scrape_sector_performance():
    logger.info("Fetching sector performance from NSE...")
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': '*/*',
        'Accept-Language': 'en-US,en;q=0.9',
    }
    
    session = requests.Session()
    session.headers.update(headers)
    
    try:
        # Step 1: Hit base URL to get cookies
        logger.info("Establishing session with NSE...")
        session.get("https://www.nseindia.com", timeout=10)
        
        # Step 2: Hit allIndices API
        api_url = "https://www.nseindia.com/api/allIndices"
        logger.info(f"Fetching data from {api_url}")
        
        response = session.get(api_url, timeout=10)
        response.raise_for_status()
        
        data = response.json()
        all_indices = data.get("data", [])
        
        sectors = []
        for index in all_indices:
            if index.get("indexSymbol") in SECTOR_INDICES:
                sectors.append({
                    "symbol": index.get("indexSymbol"),
                    "lastPrice": index.get("last"),
                    "percentChange": index.get("percentChange"),
                    "change": index.get("variation"),
                    "status": "up" if float(index.get("percentChange", 0)) > 0 else "down" if float(index.get("percentChange", 0)) < 0 else "flat"
                })
        
        # Sort by percent change descending
        sectors.sort(key=lambda x: float(x.get("percentChange", 0)), reverse=True)
        
        if not sectors:
            logger.warning("No sector data parsed!")
            return []
            
        logger.info(f"Successfully scraped {len(sectors)} sector indices.")
        return sectors
        
    except Exception as e:
        logger.error(f"Error fetching NSE sector performance: {e}")
        return []

def main():
    sectors = scrape_sector_performance()
    if sectors:
        safe_save(
            data=sectors,
            pipeline_name="sector_performance",
            source_name="nse_india",
            file_path=OUTPUT_FILE,
            retention_threshold=0.20
        )

if __name__ == "__main__":
    main()
