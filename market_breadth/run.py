import json
import os
import sys
from bse import BSE
from pathlib import Path
from datetime import datetime, timezone

# Add project root to sys.path to allow importing 'core'
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from core.logger import setup_logging

logger = setup_logging(__name__)

OUTPUT_DIR = Path("data")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


def fetch_breadth():
    logger.info("Fetching Market Breadth from BSE API...")
    with BSE("./") as bse:
        data = bse.advanceDecline()

    if data:
        out_file = OUTPUT_DIR / "market_breadth.json"
        payload = {
            "last_updated": datetime.now(timezone.utc).isoformat() + "Z",
            "breadth": data,
        }
        with open(out_file, "w") as f:
            json.dump(payload, f, indent=2)
        logger.info(f"Successfully saved market breadth to {out_file}")
    else:
        logger.error("Failed to fetch market breadth data.")


if __name__ == "__main__":
    fetch_breadth()
