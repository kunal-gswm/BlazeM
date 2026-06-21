"""CLI entry point for the IPO scraper."""

import json
import logging
import os
import sys

# Force stdout to UTF-8 for Windows consoles to support the Rupee symbol (₹)
try:
    sys.stdout.reconfigure(encoding='utf-8')
except Exception:
    pass

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from config import OUTPUT_DIR, OUTPUT_FILE
from models import IPOData, ScrapeResult
from investorgain import scrape_investorgain
from chittorgarh import scrape_chittorgarh
from transform import merge_ipo_data, filter_active_and_upcoming

def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        datefmt="%H:%M:%S",
    )
    logging.getLogger("urllib3").setLevel(logging.WARNING)

def save_output(ipos: list[IPOData], sources: list[str]) -> str:
    """Save scraped data to JSON file and return the JSON string."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    result = ScrapeResult.from_ipos(ipos, sources)
    json_str = result.to_json(indent=2)
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write(json_str)
    logging.info(f"✅ Saved {len(ipos)} IPOs to {OUTPUT_FILE}")
    return json_str

def main():
    setup_logging()
    logging.info("🚀 IPO Scraper starting...")

    investorgain_ipos = []
    chittorgarh_ipos = []

    logging.info("─── Scraping InvestorGain ───")
    try:
        investorgain_ipos = scrape_investorgain()
    except Exception as e:
        logging.error(f"InvestorGain scraper failed: {e}")

    logging.info("─── Scraping Chittorgarh ───")
    try:
        chittorgarh_ipos = scrape_chittorgarh()
    except Exception as e:
        logging.error(f"Chittorgarh scraper failed: {e}")

    all_ipos = merge_ipo_data(investorgain_ipos, chittorgarh_ipos)
    all_ipos = filter_active_and_upcoming(all_ipos)

    sources = ["investorgain", "chittorgarh"]
    
    if not all_ipos:
        logging.warning("⚠️  No IPOs scraped from any source")
        json_str = save_output([], sources)
        print(json_str)
        return

    json_str = save_output(all_ipos, sources)
    print(json_str)

if __name__ == "__main__":
    main()
