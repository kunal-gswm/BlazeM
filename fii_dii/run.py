import json
import logging
import requests
from pathlib import Path

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")

OUTPUT_DIR = Path("data")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

def fetch_fii_dii():
    logging.info("Starting NSE FII/DII Fast Scraper...")
    
    session = requests.Session()
    session.headers.update({
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
        'Accept': '*/*',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br'
    })

    try:
        # Step 1: Hit NSE homepage to generate valid session cookies
        logging.info("Negotiating session cookies with NSE...")
        session.get('https://www.nseindia.com', timeout=15)
        
        # Step 2: Fetch FII/DII data API
        logging.info("Fetching FII/DII JSON payload...")
        response = session.get('https://www.nseindia.com/api/fiidiiTradeReact', timeout=15)
        
        if response.status_code == 200:
            data = response.json()
            out_file = OUTPUT_DIR / "fii_dii.json"
            with open(out_file, "w") as f:
                json.dump(data, f, indent=2)
            logging.info(f"Successfully saved FII/DII data to {out_file}")
        else:
            logging.error(f"Failed to fetch data. NSE returned status code: {response.status_code}")
            
    except Exception as e:
        logging.error(f"NSE Scraper encountered an error: {e}")

if __name__ == "__main__":
    fetch_fii_dii()
