import json
import os
import sys
from pathlib import Path
from datetime import datetime, timezone

# Add project root to sys.path to allow importing 'core'
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from bse import BSE
from core.logger import setup_logging
from core.io import safe_save, DATA_DIR

logger = setup_logging(__name__)

OUTPUT_FILE = DATA_DIR / "market_breadth.json"


def fetch_breadth():
    logger.info("Fetching Market Breadth from BSE API...")
    with BSE("./") as bse:
        data = bse.advanceDecline()

    if data:
        # Format strings to numbers
        for item in data:
            for key in ["Advance", "Advance_PER", "Decline", "Decline_PER", "Unchange", "Unchange_PER", "TOTAL", "UP", "DN", "UC"]:
                if key in item and item[key] is not None:
                    try:
                        # Convert to float, then if it's a whole number and not a PER field, to int
                        val = float(item[key])
                        if val.is_integer() and not key.endswith("_PER"):
                            val = int(val)
                        item[key] = val
                    except ValueError:
                        pass
        
        safe_save(
            data=data,
            pipeline_name="market_breadth",
            source_name="BSE API",
            file_path=OUTPUT_FILE,
            retention_threshold=0.90
        )
        
        # --- NOTIFICATIONS: Check for Extreme Fear/Greed ---
        try:
            advances = sum(item.get("Advance", 0) for item in data if isinstance(item.get("Advance"), (int, float)))
            declines = sum(item.get("Decline", 0) for item in data if isinstance(item.get("Decline"), (int, float)))
            total = advances + declines
            if total > 0:
                adv_ratio = advances / total
                today_str = datetime.now().strftime("%Y-%m-%d")
                
                from core.notifications import check_and_trigger_breadth_alert
                if adv_ratio <= 0.10:
                    check_and_trigger_breadth_alert(today_str, "fear")
                elif adv_ratio >= 0.90:
                    check_and_trigger_breadth_alert(today_str, "greed")
        except Exception as e:
            logger.error(f"Failed to trigger breadth alert: {e}")
    else:
        logger.error("Failed to fetch market breadth data.")
        from core.io import update_health
        update_health("market_breadth", "failed")


if __name__ == "__main__":
    try:
        fetch_breadth()
    except Exception as e:
        logger.error(f"Market breadth pipeline failed: {e}")
        from core.io import update_health
        update_health("market_breadth", "failed")
