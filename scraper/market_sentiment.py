import os
import sys
import requests
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from core.logger import setup_logging
from core.io import safe_save, DATA_DIR

logger = setup_logging(__name__)
OUTPUT_FILE = DATA_DIR / "market_sentiment.json"

def get_mmi_label(score):
    if score < 30:
        return "Extreme Fear"
    elif score < 50:
        return "Fear"
    elif score < 70:
        return "Greed"
    else:
        return "Extreme Greed"

def scrape_market_sentiment():
    logger.info("Fetching Market Mood Index (MMI) from Tickertape...")
    
    api_url = "https://api.tickertape.in/mmi/now"
    
    try:
        response = requests.get(api_url, timeout=10)
        response.raise_for_status()
        
        data = response.json()
        
        if data.get("success"):
            indicator = data["data"]["indicator"]
            label = get_mmi_label(indicator)
            
            sentiment = {
                "score": round(indicator, 2),
                "label": label,
                "timestamp": data["data"]["date"]
            }
            
            logger.info(f"Successfully scraped MMI: {sentiment['score']} ({label})")
            return [sentiment] # Save as a list to maintain consistency with other endpoints
        else:
            logger.error("Tickertape API returned success: false")
            return []
            
    except Exception as e:
        logger.error(f"Error fetching Market Sentiment: {e}")
        return []

def main():
    sentiment_data = scrape_market_sentiment()
    if sentiment_data:
        safe_save(
            data=sentiment_data,
            pipeline_name="market_sentiment",
            source_name="tickertape",
            file_path=OUTPUT_FILE,
            retention_threshold=0.20
        )

if __name__ == "__main__":
    main()
