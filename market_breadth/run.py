import json
import os
import sys
from bse import BSE
from pathlib import Path
from datetime import datetime, timezone

# Add project root to sys.path to allow importing 'core'
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from core.logger import setup_logging
from core.io import safe_save

logger = setup_logging(__name__)

OUTPUT_DIR = Path("data")
OUTPUT_FILE = OUTPUT_DIR / "market_breadth.json"


def fetch_breadth():
    logger.info("Fetching Market Breadth from BSE API...")
    with BSE("./") as bse:
        data = bse.advanceDecline()

    if data:
        safe_save(
            data=data,
            pipeline_name="market_breadth",
            source_name="BSE API",
            file_path=OUTPUT_FILE,
            retention_threshold=0.90
        )
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
