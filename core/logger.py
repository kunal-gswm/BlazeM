"""Core logging setup for all pipelines."""

import logging
import sys


def setup_logging(name: str) -> logging.Logger:
    """Initialize standard logging format for all scrapers."""
    # Force stdout to UTF-8 for Windows consoles to support symbols ()
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        datefmt="%H:%M:%S",
    )
    logging.getLogger("urllib3").setLevel(logging.WARNING)
    return logging.getLogger(name)
