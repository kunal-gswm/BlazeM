"""Utility functions for scraping operations."""

import logging
from typing import Optional
from bs4 import BeautifulSoup

from config import REQUEST_HEADERS

logger = logging.getLogger(__name__)


def fetch_html_js(url: str, source_name: str, wait_selector: str = "table", timeout_ms: int = 15000) -> Optional[BeautifulSoup]:
    """Fetch a JS-rendered page using Playwright and return parsed BeautifulSoup."""
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        logger.error("playwright not installed. Run: pip install playwright && playwright install chromium")
        return None

    logger.info(f"[{source_name}] Playwright GET {url}")
    try:
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=True)
            context = browser.new_context(
                user_agent=REQUEST_HEADERS["User-Agent"],
                viewport={"width": 1920, "height": 1080},
            )
            page = context.new_page()
            page.goto(url, wait_until="domcontentloaded", timeout=30000)

            # Wait for the key content to render
            try:
                page.wait_for_selector(wait_selector, timeout=timeout_ms)
            except Exception:
                logger.warning(f"[{source_name}] Selector '{wait_selector}' not found, using page as-is")

            # Small extra wait for any lazy-loaded content
            page.wait_for_timeout(2000)

            html = page.content()
            browser.close()
            return BeautifulSoup(html, "lxml")
    except Exception as e:
        logger.error(f"[{source_name}] Playwright failed: {e}")
        return None


def clean_text(text: Optional[str]) -> str:
    """Strip whitespace and normalize."""
    if not text:
        return ""
    return " ".join(text.strip().split())
