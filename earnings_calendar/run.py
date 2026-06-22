import json
import os
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from bse import BSE

# Add project root to sys.path to allow importing 'core'
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from core.logger import setup_logging
from core.io import safe_save

logger = setup_logging(__name__)

OUTPUT_DIR = Path("data")
OUTPUT_FILE = OUTPUT_DIR / "earnings_calendar.json"


def fetch_earnings_calendar():
    logger.info("Starting BSE Earnings Calendar Scraper...")

    # Initialize BSE wrapper
    with BSE(download_folder="./") as bse:
        logger.info("Fetching upcoming earnings/result calendar...")
        raw_calendar = bse.resultCalendar()

    all_earnings = []
    today = datetime.now().date()
    horizon = today + timedelta(days=14)

    for event in raw_calendar:
        date_str = event.get("meeting_date")
        if not date_str:
            continue

        try:
            event_date = datetime.strptime(date_str, "%d %b %Y").date()
        except ValueError:
            continue

        # 14-Day Horizon Filter
        if today <= event_date <= horizon:
            all_earnings.append(event)

    # Sort by meeting date chronologically (soonest first)
    def sort_key(item):
        date_str = item.get("meeting_date")
        try:
            return datetime.strptime(date_str, "%d %b %Y")
        except ValueError:
            return datetime.max

    all_earnings.sort(key=sort_key)

    # Deduplicate in case of duplicate API entries
    seen = set()
    unique_earnings = []
    for event in all_earnings:
        key = f"{event.get('short_name', '')}_{event.get('meeting_date', '')}"
        if key not in seen:
            seen.add(key)
            unique_earnings.append(event)

    return unique_earnings


def save_json(data: list):
    safe_save(
        data=data,
        pipeline_name="earnings_calendar",
        source_name="BSE API",
        file_path=OUTPUT_FILE,
        retention_threshold=0.50
    )


if __name__ == "__main__":
    try:
        earnings_data = fetch_earnings_calendar()
        save_json(earnings_data)
    except Exception as e:
        logger.error(f"Earnings calendar pipeline failed: {e}")
        from core.io import update_health
        update_health("earnings_calendar", "failed")
