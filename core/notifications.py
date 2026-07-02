"""Handles IPO notification state tracking to prevent duplicates."""

import json
from pathlib import Path
import firebase_admin
from firebase_admin import credentials, messaging
from core.logger import setup_logging

logger = setup_logging(__name__)

NOTIFICATIONS_FILE = Path(__file__).resolve().parent.parent / "data" / "ipo_notifications.json"
SERVICE_ACCOUNT_FILE = Path(__file__).resolve().parent.parent / "service_account.json"

# Initialize Firebase Admin
try:
    if not firebase_admin._apps:
        if SERVICE_ACCOUNT_FILE.exists():
            cred = credentials.Certificate(str(SERVICE_ACCOUNT_FILE))
            firebase_admin.initialize_app(cred)
            logger.info("Firebase Admin initialized successfully.")
        else:
            logger.warning(f"Firebase Service Account file not found at {SERVICE_ACCOUNT_FILE}. Notifications will only be logged.")
except Exception as e:
    logger.error(f"Failed to initialize Firebase Admin: {e}")

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
    """Sends a real push notification via FCM to the 'all' topic."""
    logger.critical(f"🔔 NOTIFICATION TRIGGERED | {title} | {message}")
    
    if firebase_admin._apps:
        try:
            msg = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=message,
                ),
                topic='all',
            )
            response = messaging.send(msg)
            logger.info(f"Successfully sent FCM message: {response}")
        except Exception as e:
            logger.error(f"Failed to send FCM message: {e}")
    else:
        logger.warning("FCM not initialized. Push notification was not sent.")

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
