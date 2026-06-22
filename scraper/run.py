"""CLI entry point for the IPO scraper."""

import os
import sys
from pathlib import Path

# Add project root to sys.path to allow importing 'core'
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from core.logger import setup_logging
from scraper.models import IPOData, ScrapeResult
from scraper.investorgain import scrape_investorgain
from scraper.chittorgarh import scrape_chittorgarh
from scraper.transform import merge_ipo_data, filter_active_and_upcoming

OUTPUT_DIR = Path(os.path.dirname(os.path.abspath(__file__))) / "data"
OUTPUT_FILE = OUTPUT_DIR / "ipo_data.json"

logger = setup_logging(__name__)


def save_output(ipos: list[IPOData], sources: list[str]) -> str:
    """Save scraped data to JSON file and return the JSON string."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    result = ScrapeResult.from_ipos(ipos, sources)
    json_str = result.to_json(indent=2)
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write(json_str)
    logger.info(f"✅ Saved {len(ipos)} IPOs to {OUTPUT_FILE}")
    return json_str


def main():
    logger.info("🚀 IPO Scraper starting...")

    investorgain_ipos = []
    chittorgarh_ipos = []

    logger.info("─── Scraping InvestorGain ───")
    try:
        investorgain_ipos = scrape_investorgain()
    except Exception as e:
        logger.error(f"InvestorGain scraper failed: {e}")

    logger.info("─── Scraping Chittorgarh ───")
    try:
        chittorgarh_ipos = scrape_chittorgarh()
    except Exception as e:
        logger.error(f"Chittorgarh scraper failed: {e}")

    all_ipos = merge_ipo_data(investorgain_ipos, chittorgarh_ipos)
    all_ipos = filter_active_and_upcoming(all_ipos)

    sources = ["investorgain", "chittorgarh"]

    if not all_ipos:
        logger.warning("⚠️  No IPOs scraped from any source")
        json_str = save_output([], sources)
        print(json_str)
        return

    json_str = save_output(all_ipos, sources)
    print(json_str)


if __name__ == "__main__":
    main()
