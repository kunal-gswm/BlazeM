"""Configuration: URLs, selectors, headers, rate-limiting constants."""

# ─── Request Config ───────────────────────────────────────────────────────────

REQUEST_HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/131.0.0.0 Safari/537.36"
    ),
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9",
}


# ─── Output ───────────────────────────────────────────────────────────────────

import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(BASE_DIR, "data")
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "ipo_data.json")


# ─── Chittorgarh ─────────────────────────────────────────────────────────────

CHITTORGARH_CURRENT_IPOS_URL = (
    "https://www.chittorgarh.com/report/ipo-in-india-list-main-board-sme/82/mainboard/"
)
CHITTORGARH_TIMETABLE_URL = (
    "https://www.chittorgarh.com/report/ipo-list-by-time-table-and-lot-size/118/mainboard/"
)
CHITTORGARH_UPCOMING_URL = (
    "https://www.chittorgarh.com/report/upcoming-ipos-drhp-filed/158/mainboard/"
)
CHITTORGARH_BASE_URL = "https://www.chittorgarh.com"

# ─── InvestorGain (Chittorgarh's GMP source) ─────────────────────────────────

INVESTORGAIN_GMP_URL = "https://www.investorgain.com/report/live-ipo-gmp/331/ipo/"
INVESTORGAIN_BASE_URL = "https://www.investorgain.com"
