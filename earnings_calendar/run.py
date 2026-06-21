import json
import logging
from datetime import datetime, timedelta
from pathlib import Path
from bse import BSE

# Setup basic logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")

OUTPUT_DIR = Path("data")
OUTPUT_FILE = OUTPUT_DIR / "earnings_calendar.json"

def fetch_earnings_calendar():
    logging.info("Starting BSE Earnings Calendar Scraper...")
    
    # Initialize BSE wrapper
    with BSE(download_folder='./') as bse:
        logging.info("Fetching upcoming earnings/result calendar...")
        raw_calendar = bse.resultCalendar()
        
    all_earnings = []
    today = datetime.now().date()
    horizon = today + timedelta(days=14)
    
    for event in raw_calendar:
        date_str = event.get('meeting_date')
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
        date_str = item.get('meeting_date')
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
        "last_updated": datetime.utcnow().isoformat(),
        "total_events": len(data),
        "events": data
    }
    
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(output_payload, f, indent=2, ensure_ascii=False)
        
    logging.info(f"Successfully saved {len(data)} earnings events to {OUTPUT_FILE}")

if __name__ == "__main__":
    earnings_data = fetch_earnings_calendar()
    save_json(earnings_data)
