"""CLI entry point for the IPO scraper."""

import argparse
import json
import logging
import os
import sys

# Force stdout to UTF-8 for Windows consoles to support the Rupee symbol (₹)
try:
    sys.stdout.reconfigure(encoding='utf-8')
except Exception:
    pass

# Add scraper dir to path so imports work when run from any cwd
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from config import OUTPUT_DIR, OUTPUT_FILE
from models import IPOData, ScrapeResult
from scrapers.investorgain import InvestorGainScraper
from scrapers.chittorgarh import ChittorgarhScraper
from merge import merge_ipo_data, filter_active_and_upcoming


def setup_logging(verbose: bool = False):
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format="%(asctime)s [%(levelname)s] %(message)s",
        datefmt="%H:%M:%S",
    )
    # Suppress verbose third-party logs
    logging.getLogger("urllib3").setLevel(logging.WARNING)


def run_scraper(source: str | None = None) -> list[IPOData]:
    """Run all scrapers (or a specific one) and merge results."""
    logging.info("🚀 IPO Scraper starting...")

    investorgain_ipos = []
    chittorgarh_ipos = []

    # 1. InvestorGain
    if source is None or source == "investorgain":
        logging.info("─── Scraping InvestorGain ───")
        try:
            investorgain_ipos = InvestorGainScraper().scrape()
        except Exception as e:
            logging.error(f"InvestorGain scraper failed: {e}")

    # 2. Chittorgarh
    if source is None or source == "chittorgarh":
        logging.info("─── Scraping Chittorgarh ───")
        try:
            chittorgarh_ipos = ChittorgarhScraper().scrape()
        except Exception as e:
            logging.error(f"Chittorgarh scraper failed: {e}")

    # Merge all sources
    if source:
        # Single source mode — no merge needed
        all_ipos = investorgain_ipos + chittorgarh_ipos
    else:
        all_ipos = merge_ipo_data(investorgain_ipos, chittorgarh_ipos)

    # Filter for only Open and Upcoming
    all_ipos = filter_active_and_upcoming(all_ipos)

    return all_ipos


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
    parser = argparse.ArgumentParser(description="IPO Data Scraper — Chittorgarh, InvestorGain")
    parser.add_argument(
        "--source",
        choices=["chittorgarh", "investorgain"],
        default=None,
        help="Scrape a single source (default: all)",
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Enable debug logging",
    )
    args = parser.parse_args()

    setup_logging(args.verbose)
    logging.info("🚀 IPO Scraper starting...")

    # Determine which sources we're scraping
    if args.source:
        sources = [args.source]
    else:
        sources = ["investorgain", "chittorgarh"]

    # Run
    ipos = run_scraper(args.source)

    if not ipos:
        logging.warning("⚠️  No IPOs scraped from any source")
        json_str = save_output([], sources)
        print(json_str)
        return

    # Save and output raw JSON API response
    json_str = save_output(ipos, sources)
    print(json_str)


if __name__ == "__main__":
    main()
