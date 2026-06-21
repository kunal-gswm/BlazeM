"""Base scraper with HTTP and Playwright helpers."""

import abc
import logging
import time
from typing import Optional

import requests
from bs4 import BeautifulSoup

from config import REQUEST_HEADERS, REQUEST_TIMEOUT, DELAY_BETWEEN_REQUESTS, MAX_RETRIES
from models import IPOData

logger = logging.getLogger(__name__)


class BaseScraper(abc.ABC):
    """Abstract base for all IPO scrapers."""

    source_name: str = "base"

    def __init__(self):
        self._session = requests.Session()
        self._session.headers.update(REQUEST_HEADERS)
        self._last_request_time = 0.0

    # ── HTTP (static pages) ──────────────────────────────────────────────────

    def _throttle(self):
        """Enforce delay between requests."""
        elapsed = time.time() - self._last_request_time
        if elapsed < DELAY_BETWEEN_REQUESTS:
            time.sleep(DELAY_BETWEEN_REQUESTS - elapsed)
        self._last_request_time = time.time()

    def fetch_html(self, url: str) -> Optional[BeautifulSoup]:
        """Fetch a page with requests and return parsed BeautifulSoup."""
        for attempt in range(1, MAX_RETRIES + 1):
            try:
                self._throttle()
                logger.info(f"[{self.source_name}] GET {url} (attempt {attempt})")
                resp = self._session.get(url, timeout=REQUEST_TIMEOUT)
                resp.raise_for_status()
                return BeautifulSoup(resp.text, "lxml")
            except requests.RequestException as e:
                logger.warning(f"[{self.source_name}] Request failed: {e}")
                if attempt == MAX_RETRIES:
                    logger.error(f"[{self.source_name}] All {MAX_RETRIES} attempts failed for {url}")
                    return None
                time.sleep(2 ** attempt)  # exponential backoff
        return None

    # ── Playwright (JS-rendered pages) ───────────────────────────────────────

    def fetch_html_js(self, url: str, wait_selector: str = "table", timeout_ms: int = 15000) -> Optional[BeautifulSoup]:
        """Fetch a JS-rendered page using Playwright and return parsed BeautifulSoup."""
        try:
            from playwright.sync_api import sync_playwright
        except ImportError:
            logger.error("playwright not installed. Run: pip install playwright && playwright install chromium")
            return None

        logger.info(f"[{self.source_name}] Playwright GET {url}")
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
                    logger.warning(f"[{self.source_name}] Selector '{wait_selector}' not found, using page as-is")

                # Small extra wait for any lazy-loaded content
                page.wait_for_timeout(2000)

                html = page.content()
                browser.close()
                return BeautifulSoup(html, "lxml")
        except Exception as e:
            logger.error(f"[{self.source_name}] Playwright failed: {e}")
            return None

    # ── Utilities ────────────────────────────────────────────────────────────

    @staticmethod
    def clean_text(text: Optional[str]) -> str:
        """Strip whitespace and normalize."""
        if not text:
            return ""
        return " ".join(text.strip().split())

    # ── Abstract interface ───────────────────────────────────────────────────

    @abc.abstractmethod
    def scrape(self) -> list[IPOData]:
        """Run the full scrape and return a list of IPOData."""
        ...
