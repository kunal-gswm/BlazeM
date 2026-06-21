import json
import logging
from datetime import datetime, timedelta
from pathlib import Path
from bse import BSE
from bse.constants import PURPOSE

# Setup basic logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")

OUTPUT_DIR = Path("data")
OUTPUT_FILE = OUTPUT_DIR / "corporate_actions.json"

def fetch_corporate_actions():
    logging.info("Starting BSE Corporate Actions Scraper...")
    
    # Initialize BSE wrapper
    # download_folder is required by the library internally for some reports
    with BSE(download_folder='./') as bse:
        logging.info("Fetching all upcoming corporate actions...")
        # Since BSE backend seems to ignore purpose_code filtering sometimes, we just pull all and filter locally
        raw_actions = bse.actions()
        
    all_actions = []
    today = datetime.now().date()
    horizon = today + timedelta(days=14)
    
    for action in raw_actions:
        purpose = action.get('Purpose', '')
        purpose_lower = purpose.lower()
        
        # Deduce action type
        if 'dividend' in purpose_lower:
            action['action_type'] = "Dividend"
            # Try to parse dividend amount
            if '-' in purpose:
                try:
                    *str_lst, div_val = tuple(i.strip() for i in purpose.split('-'))
                    action['dividend_amount'] = float(div_val)
                except Exception:
                    action['dividend_amount'] = None
            else:
                action['dividend_amount'] = None
        elif 'bonus' in purpose_lower:
            action['action_type'] = "Bonus"
            action['dividend_amount'] = None
        elif 'split' in purpose_lower:
            action['action_type'] = "Split"
            action['dividend_amount'] = None
        elif 'buy back' in purpose_lower or 'buyback' in purpose_lower:
            action['action_type'] = "Buyback"
            action['dividend_amount'] = None
        elif 'merger' in purpose_lower or 'amalgamation' in purpose_lower:
            action['action_type'] = "Merger"
            action['dividend_amount'] = None
        elif 'demerger' in purpose_lower:
            action['action_type'] = "Demerger"
            action['dividend_amount'] = None
        else:
            continue # We only want Bonus, Split, Dividend, Buyback, and Mergers
            
        # 14-Day Horizon Filter
        date_str = action.get('Ex_date') or action.get('RD_Date')
        if not date_str:
            continue
            
        try:
            event_date = datetime.strptime(date_str, "%d %b %Y").date()
        except ValueError:
            continue
            
        if today <= event_date <= horizon:
            all_actions.append(action)

    # Sort by Ex-Date (if available), fallback to Record Date
    def sort_key(item):
        date_str = item.get('Ex_date') or item.get('RD_Date') or "1970-01-01"
        try:
            return datetime.strptime(date_str, "%d %b %Y")
        except ValueError:
            return datetime.min

    all_actions.sort(key=sort_key, reverse=True)
    
    # Deduplicate just in case BSE returns the same action
    seen = set()
    unique_actions = []
    for action in all_actions:
        # Create a unique key based on Scrip name and Purpose
        key = f"{action.get('short_name', '')}_{action.get('Purpose', '')}"
        if key not in seen:
            seen.add(key)
            unique_actions.append(action)

    return unique_actions

def save_json(data: list):
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    output_payload = {
        "last_updated": datetime.utcnow().isoformat(),
        "total_actions": len(data),
        "actions": data
    }
    
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(output_payload, f, indent=2, ensure_ascii=False)
        
    logging.info(f"Successfully saved {len(data)} actions to {OUTPUT_FILE}")

if __name__ == "__main__":
    actions = fetch_corporate_actions()
    save_json(actions)
