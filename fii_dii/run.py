import json
import requests
import os
import sys
from pathlib import Path

# Add project root to sys.path to allow importing 'core'
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from core.logger import setup_logging
from core.io import safe_save, DATA_DIR

logger = setup_logging(__name__)

OUTPUT_FILE = DATA_DIR / "fii_dii.json"


def fetch_fii_dii():
    logger.info("Starting NSE FII/DII Fast Scraper...")

    session = requests.Session()
    session.headers.update(
        {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
            "Accept": "*/*",
            "Accept-Language": "en-US,en;q=0.9",
            "Accept-Encoding": "gzip, deflate, br",
        }
    )

    try:
        # Step 1: Hit NSE homepage to generate valid session cookies
        logger.info("Negotiating session cookies with NSE...")
        session.get("https://www.nseindia.com", timeout=15)

        # Step 2: Fetch FII/DII data API
        logger.info("Fetching FII/DII JSON payload...")
        response = session.get(
            "https://www.nseindia.com/api/fiidiiTradeReact", timeout=15
        )

        if response.status_code == 200:
            data = response.json()
            
            # Cast strings to float
            for item in data:
                for key in ['buyValue', 'sellValue', 'netValue']:
                    if key in item and isinstance(item[key], str):
                        try:
                            item[key] = float(item[key])
                        except ValueError:
                            item[key] = None
                            
            # Read existing data to accumulate history
            existing_data = []
            if OUTPUT_FILE.exists():
                try:
                    with open(OUTPUT_FILE, 'r') as f:
                        existing_data = json.load(f).get("data", [])
                except Exception:
                    pass
            
            # Combine and deduplicate by date and category
            combined_dict = {}
            for row in existing_data + data:
                key = f"{row.get('date')}_{row.get('category')}"
                combined_dict[key] = row
                
            combined = list(combined_dict.values())
            
            # Sort by date descending (parse the 'dd-MMM-yyyy' format)
            from datetime import datetime
            def parse_date(date_str):
                try:
                    return datetime.strptime(date_str, "%d-%b-%Y")
                except ValueError:
                    return datetime.min

            combined.sort(key=lambda x: parse_date(x.get("date", "")), reverse=True)
            
            # Keep only the latest 90 unique dates (which is up to 180 records)
            unique_dates = []
            final_data = []
            for row in combined:
                d = row.get("date")
                if d not in unique_dates:
                    if len(unique_dates) >= 90:
                        continue
                    unique_dates.append(d)
                final_data.append(row)
            
            safe_save(
                data=final_data,
                pipeline_name="fii_dii",
                source_name="NSE API",
                file_path=OUTPUT_FILE,
                retention_threshold=0.05
            )
        else:
            logger.error(
                f"Failed to fetch data. NSE returned status code: {response.status_code}"
            )
            from core.io import update_health
            update_health("fii_dii", "failed")

    except Exception as e:
        logger.error(f"NSE Scraper encountered an error: {e}")
        from core.io import update_health
        update_health("fii_dii", "failed")


if __name__ == "__main__":
    fetch_fii_dii()
