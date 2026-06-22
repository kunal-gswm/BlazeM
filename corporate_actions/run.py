import json
import os
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from bse import BSE

# Add project root to sys.path to allow importing 'core'
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from core.logger import setup_logging
from core.io import safe_save, DATA_DIR

logger = setup_logging(__name__)

OUTPUT_FILE = DATA_DIR / "corporate_actions.json"


def fetch_corporate_actions():
    logger.info("Starting BSE Corporate Actions Scraper...")

    with BSE(download_folder="./") as bse:
        logger.info("Fetching all upcoming corporate actions...")
        raw_actions = bse.actions()

    all_actions = []
    today = datetime.now().date()
    horizon = today + timedelta(days=14)

    # Purpose mapping dictionary to avoid massive if/elif block
    action_map = {
        "dividend": "Dividend",
        "bonus": "Bonus",
        "split": "Split",
        "buy back": "Buyback",
        "buyback": "Buyback",
        "merger": "Merger",
        "amalgamation": "Merger",
        "demerger": "Demerger",
    }

    for action in raw_actions:
        purpose = action.get("Purpose", "")
        purpose_lower = purpose.lower()

        # Determine action type using mapping
        matched_type = next(
            (v for k, v in action_map.items() if k in purpose_lower), None
        )
        if not matched_type:
            continue

        action["action_type"] = matched_type
        action["dividend_amount"] = None

        if matched_type == "Dividend" and "-" in purpose:
            try:
                *str_lst, div_val = tuple(i.strip() for i in purpose.split("-"))
                action["dividend_amount"] = float(div_val)
            except Exception:
                pass

        # 14-Day Horizon Filter
        date_str = action.get("Ex_date") or action.get("RD_Date")
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
        date_str = item.get("Ex_date") or item.get("RD_Date") or "1970-01-01"
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
    safe_save(
        data=data,
        pipeline_name="corporate_actions",
        source_name="BSE API",
        file_path=OUTPUT_FILE,
        retention_threshold=0.50
    )


if __name__ == "__main__":
    try:
        actions = fetch_corporate_actions()
        save_json(actions)
    except Exception as e:
        logger.error(f"Corporate actions pipeline failed: {e}")
        from core.io import update_health
        update_health("corporate_actions", "failed")
