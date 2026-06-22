import json
import logging
from bse import BSE
from pathlib import Path
from datetime import datetime

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")

OUTPUT_DIR = Path("data")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

def fetch_breadth():
    logging.info("Fetching Market Breadth from BSE API...")
    with BSE("./") as bse:
        data = bse.advanceDecline()
        
    if data:
        out_file = OUTPUT_DIR / "market_breadth.json"
        payload = {
            "last_updated": datetime.utcnow().isoformat() + "Z",
            "breadth": data
        }
        with open(out_file, "w") as f:
            json.dump(payload, f, indent=2)
        logging.info(f"Successfully saved market breadth to {out_file}")
    else:
        logging.error("Failed to fetch market breadth data.")

if __name__ == "__main__":
    fetch_breadth()
