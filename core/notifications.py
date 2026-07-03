"""Handles IPO notification state tracking to prevent duplicates."""

import json
from pathlib import Path
try:
    import firebase_admin
    from firebase_admin import credentials, messaging
    HAS_FIREBASE = True
except ImportError:
    firebase_admin = None
    credentials = None
    messaging = None
    HAS_FIREBASE = False
from core.logger import setup_logging

logger = setup_logging(__name__)

NOTIFICATIONS_FILE = Path(__file__).resolve().parent.parent / "data" / "ipo_notifications.json"
SERVICE_ACCOUNT_FILE = Path(__file__).resolve().parent.parent / "service_account.json"

# Initialize Firebase Admin
try:
    if HAS_FIREBASE and not firebase_admin._apps:
        if SERVICE_ACCOUNT_FILE.exists():
            cred = credentials.Certificate(str(SERVICE_ACCOUNT_FILE))
            firebase_admin.initialize_app(cred)
            logger.info("Firebase Admin initialized successfully.")
        else:
            logger.warning(f"Firebase Service Account file not found at {SERVICE_ACCOUNT_FILE}. Notifications will only be logged.")
    elif not HAS_FIREBASE:
        logger.warning("firebase_admin library not installed. Push notifications will only be logged.")
except Exception as e:
    logger.error(f"Failed to initialize Firebase Admin: {e}")

def _load_state(file_path: Path) -> dict:
    if file_path.exists():
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.error(f"Failed to load notification state from {file_path.name}: {e}")
    return {}

def _save_state(state: dict, file_path: Path):
    try:
        file_path.parent.mkdir(parents=True, exist_ok=True)
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(state, f, indent=2, ensure_ascii=False)
    except Exception as e:
        logger.error(f"Failed to save notification state to {file_path.name}: {e}")

def _trigger_alert(title: str, message: str):
    """Sends a real push notification via FCM to the 'all' topic."""
    logger.critical(f"🔔 NOTIFICATION TRIGGERED | {title} | {message}")
    
    if HAS_FIREBASE and firebase_admin and firebase_admin._apps:
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
        logger.warning("FCM not initialized or library not available. Push notification was not sent.")

def check_and_trigger_notification(ipo_name: str, status: str):
    """Check state and trigger notification if not already sent."""
    if status not in ["Open", "Closed"]:
        return
        
    state = _load_state(NOTIFICATIONS_FILE)
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
        _save_state(state, NOTIFICATIONS_FILE)
        
    elif status == "Closed" and not ipo_state.get("closed_notified"):
        _trigger_alert(
            title=f"IPO Closed: {ipo_name}",
            message=f"The {ipo_name} IPO has officially CLOSED."
        )
        ipo_state["closed_notified"] = True
        _save_state(state, NOTIFICATIONS_FILE)

# FII Notifications
FII_NOTIFICATIONS_FILE = Path(__file__).resolve().parent.parent / "data" / "fii_notifications.json"

def check_and_trigger_fii_alert(date: str, net_value: float):
    state = _load_state(FII_NOTIFICATIONS_FILE)
    if date in state:
        return # Already processed this date
        
    if net_value <= -5000:
        _trigger_alert(
            title="Whale Alert: FII Selloff",
            message=f"FIIs have sold a massive ₹{abs(net_value):,.2f} Crores in today's session."
        )
    elif net_value >= 5000:
        _trigger_alert(
            title="Whale Alert: FII Buying",
            message=f"FIIs have purchased a massive ₹{net_value:,.2f} Crores in today's session!"
        )
        
    state[date] = {"net_value": net_value}
    _save_state(state, FII_NOTIFICATIONS_FILE)

# Market Breadth Notifications
BREADTH_NOTIFICATIONS_FILE = Path(__file__).resolve().parent.parent / "data" / "breadth_notifications.json"

def check_and_trigger_breadth_alert(date: str, state_type: str):
    """state_type is either 'fear' or 'greed'"""
    state = _load_state(BREADTH_NOTIFICATIONS_FILE)
    if date in state and state[date] == state_type:
        return # Already notified for this state today
        
    if state_type == "fear":
        _trigger_alert(
            title="Market Sentiment: Extreme Fear",
            message="Advances have plummeted below 10%. The market is heavily oversold."
        )
    elif state_type == "greed":
        _trigger_alert(
            title="Market Sentiment: Extreme Greed",
            message="Advances have surged above 90%. The market is heavily overbought."
        )
        
    state[date] = state_type
    _save_state(state, BREADTH_NOTIFICATIONS_FILE)

# Corporate Actions Notifications
CORP_NOTIFICATIONS_FILE = Path(__file__).resolve().parent.parent / "data" / "corp_notifications.json"

def check_and_trigger_corp_action_alert(company: str, action_type: str, ex_date: str):
    """Fired exactly 1 day before the ex-date."""
    state = _load_state(CORP_NOTIFICATIONS_FILE)
    key = f"{company}_{action_type}_{ex_date}"
    if key in state:
        return
        
    _trigger_alert(
        title=f"Action Required: {company} {action_type}",
        message=f"{company} goes ex-{action_type.lower()} tomorrow ({ex_date}). Buy today to be eligible."
    )
    
    state[key] = True
    _save_state(state, CORP_NOTIFICATIONS_FILE)
