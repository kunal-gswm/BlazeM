"""CLI entry point for the IPO scraper."""

import argparse
import json
import logging
import os
import sys

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


def save_output(ipos: list[IPOData], sources: list[str]):
    """Save scraped data to JSON file."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    result = ScrapeResult.from_ipos(ipos, sources)
    json_str = result.to_json(indent=2)

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write(json_str)

    logging.info(f"✅ Saved {len(ipos)} IPOs to {OUTPUT_FILE}")


def main():
    parser = argparse.ArgumentParser(description="IPO Data Scraper — IPO Central, Chittorgarh, InvestorGain")
    parser.add_argument(
        "--source",
        choices=["ipocentral", "chittorgarh", "investorgain"],
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
        sources = ["investorgain", "ipocentral", "chittorgarh"]

    # Run
    ipos = run_scraper(args.source)

    if not ipos:
        logging.warning("⚠️  No IPOs scraped from any source")
        # Still save empty result so the file always exists
        save_output([], sources)
        return

    # Save
    save_output(ipos, sources)

    # Print summary (ASCII-safe for Windows console)
    try:
        print(f"\n{'-' * 60}")
        print(f"{'IPO Name':<35} {'GMP':>8} {'Price':>12}")
        print(f"{'-' * 60}")
        for ipo in ipos[:20]:  # Show top 20
            name = ipo.issue_name[:34]
            gmp = ipo.gmp[:8] if ipo.gmp else "-"
            price = ipo.price_band[:12] if ipo.price_band else "-"
            print(f"{name:<35} {gmp:>8} {price:>12}")
        if len(ipos) > 20:
            print(f"  ... and {len(ipos) - 20} more")
        print(f"{'-' * 60}")
    except UnicodeEncodeError:
        # Fallback for consoles that can't handle certain chars
        logging.info(f"Scraped {len(ipos)} IPOs (see JSON for details)")


if __name__ == "__main__":
    main()
