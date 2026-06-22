import json
import os
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from bse import BSE

# Add project root to sys.path to allow importing 'core'
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from core.logger import setup_logging

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
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    output_payload = {
        "last_updated": datetime.now(timezone.utc).isoformat() + "Z",
        "total_results": len(data),
        "earnings": data,
    }

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(output_payload, f, indent=2, ensure_ascii=False)

    logger.info(f"Successfully saved {len(data)} earnings events to {OUTPUT_FILE}")


if __name__ == "__main__":
    earnings_data = fetch_earnings_calendar()
    save_json(earnings_data)
