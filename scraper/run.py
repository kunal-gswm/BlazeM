"""CLI entry point for the IPO scraper."""

import os
import sys
from pathlib import Path

# Add project root to sys.path to allow importing 'core'
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from dataclasses import asdict
from core.logger import setup_logging
from core.io import safe_save, DATA_DIR
from scraper.models import IPOData
from scraper.investorgain import scrape_investorgain
from scraper.chittorgarh import scrape_chittorgarh
from scraper.transform import merge_ipo_data, filter_active_and_upcoming

OUTPUT_FILE = DATA_DIR / "ipo_data.json"

logger = setup_logging(__name__)

# save_output function removed, using core.io.safe_save

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

    data_dicts = [asdict(ipo) for ipo in all_ipos]
    
    safe_save(
        data=data_dicts,
        pipeline_name="ipos",
        source_name="investorgain, chittorgarh",
        file_path=OUTPUT_FILE,
        retention_threshold=0.20
    )


if __name__ == "__main__":
    main()
