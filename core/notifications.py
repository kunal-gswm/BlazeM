"""Handles IPO notification state tracking to prevent duplicates."""

import json
from pathlib import Path
from core.logger import setup_logging

logger = setup_logging(__name__)

NOTIFICATIONS_FILE = Path(__file__).resolve().parent.parent / "data" / "ipo_notifications.json"

def _load_state() -> dict:
    if NOTIFICATIONS_FILE.exists():
        try:
            with open(NOTIFICATIONS_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.error(f"Failed to load notification state: {e}")
    return {}

def _save_state(state: dict):
    try:
        NOTIFICATIONS_FILE.parent.mkdir(parents=True, exist_ok=True)
        with open(NOTIFICATIONS_FILE, "w", encoding="utf-8") as f:
            json.dump(state, f, indent=2, ensure_ascii=False)
    except Exception as e:
        logger.error(f"Failed to save notification state: {e}")

def _trigger_alert(title: str, message: str):
    """Placeholder for inbuilt notification trigger."""
    # For "inbuilt" requirement, we log a critical alert which can be parsed by the runner
    logger.critical(f"🔔 NOTIFICATION TRIGGERED | {title} | {message}")
    
    # Example: If you have an inbuilt Github Action step to parse logs, or a local system notifier:
    # print(f"::notice title={title}::{message}") # GitHub Actions syntax

def check_and_trigger_notification(ipo_name: str, status: str):
    """Check state and trigger notification if not already sent."""
    if status not in ["Open", "Closed"]:
        return
        
    state = _load_state()
    ipo_key = ipo_name.lower().strip()
    
    if ipo_key not in state:
        state[ipo_key] = {"open_notified": False, "closed_notified": False}
        
    ipo_state = state[ipo_key]
    
    if status == "Open" and not ipo_state.get("open_notified"):
        _trigger_alert(
            title=f"IPO Open: {ipo_name}",
            message=f"The {ipo_name} IPO is now OPEN for subscription."
        )
        ipo_state["open_notified"] = True
        _save_state(state)
        
    elif status == "Closed" and not ipo_state.get("closed_notified"):
        _trigger_alert(
            title=f"IPO Closed: {ipo_name}",
            message=f"The {ipo_name} IPO has officially CLOSED."
        )
        ipo_state["closed_notified"] = True
        _save_state(state)
