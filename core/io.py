"""Core I/O utilities for safely saving data, standardizing metadata, and monitoring health."""
import json
import os
import shutil
from datetime import datetime, timezone, timedelta
from pathlib import Path
from typing import Any, Dict

from core.logger import setup_logging

logger = setup_logging(__name__)

ROOT_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT_DIR / "data"
ARCHIVE_DIR = DATA_DIR / "archive"
HEALTH_FILE = DATA_DIR / "health.json"

DATA_DIR.mkdir(parents=True, exist_ok=True)
ARCHIVE_DIR.mkdir(parents=True, exist_ok=True)

def _convert_empty_strings(obj: Any) -> Any:
    """Recursively convert empty strings to None."""
    if isinstance(obj, dict):
        return {k: _convert_empty_strings(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [_convert_empty_strings(item) for item in obj]
    elif isinstance(obj, str) and obj.strip() == "":
        return None
    return obj

def update_health(pipeline: str, status: str):
    """Update the centralized health.json file."""
    health_data = {}
    if HEALTH_FILE.exists():
        try:
            with open(HEALTH_FILE, "r", encoding="utf-8") as f:
                health_data = json.load(f)
        except Exception:
            pass

    if pipeline not in health_data:
        health_data[pipeline] = {}
        
    health_data[pipeline]["status"] = status
    health_data[pipeline]["updated_at"] = datetime.now(timezone.utc).isoformat() + "Z"

    with open(HEALTH_FILE, "w", encoding="utf-8") as f:
        json.dump(health_data, f, indent=2)

def _archive_previous_file(file_path: Path):
    """Move the existing file to the archive directory and clean up old archives."""
    if not file_path.exists():
        return
        
    timestamp_str = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
    archive_name = f"{file_path.stem}_{timestamp_str}{file_path.suffix}"
    archive_path = ARCHIVE_DIR / archive_name
    
    shutil.copy2(file_path, archive_path)
    
    # Cleanup archives older than 7 days
    cutoff = datetime.now(timezone.utc) - timedelta(days=7)
    for archive in ARCHIVE_DIR.glob(f"{file_path.stem}_*{file_path.suffix}"):
        try:
            mtime = datetime.fromtimestamp(archive.stat().st_mtime, tz=timezone.utc)
            if mtime < cutoff:
                archive.unlink()
        except Exception as e:
            logger.warning(f"Failed to delete old archive {archive}: {e}")

def safe_save(
    data: list, 
    pipeline_name: str, 
    source_name: str, 
    file_path: Path, 
    retention_threshold: float
) -> bool:
    """
    Safely saves data preventing excessive data loss.
    Wraps payload in standardized metadata.
    """
    new_count = len(data)
    
    # 1. Load previous to check threshold
    if file_path.exists():
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                prev_payload = json.load(f)
                prev_count = prev_payload.get("metadata", {}).get("record_count", len(prev_payload.get("data", [])))
                
                # Check threshold
                if prev_count > 0:
                    retention = new_count / prev_count
                    if retention < retention_threshold:
                        logger.error(
                            f"[{pipeline_name}] DATA LOSS PROTECTION TRIGGERED. "
                            f"New count ({new_count}) is < {retention_threshold*100}% of previous ({prev_count}). Aborting."
                        )
                        update_health(pipeline_name, "failed")
                        return False
        except Exception as e:
            logger.warning(f"[{pipeline_name}] Failed to read previous file for count checking: {e}")

    # 2. Archive previous file
    _archive_previous_file(file_path)

    # 3. Clean empty strings
    cleaned_data = _convert_empty_strings(data)

    # 4. Standardize Payload
    payload = {
        "metadata": {
            "source": source_name,
            "last_updated": datetime.now(timezone.utc).isoformat() + "Z",
            "status": "healthy",
            "record_count": new_count
        },
        "data": cleaned_data
    }

    # 5. Write to Disk
    try:
        file_path.parent.mkdir(parents=True, exist_ok=True)
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(payload, f, indent=2, ensure_ascii=False)
        
        logger.info(f"[{pipeline_name}] \u2705 Saved {new_count} records to {file_path}")
        update_health(pipeline_name, "healthy")
        return True
    except Exception as e:
        logger.error(f"[{pipeline_name}] Failed to save JSON: {e}")
        update_health(pipeline_name, "failed")
        return False
