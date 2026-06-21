# Networking and Configuration Analysis

**Scope:** `scrapers/base.py` and `config.py`

## Findings: Severe Dead Code and Unused Dependencies

During the evolution of this scraper, the pure HTML source (`ipocentral.py`) was deleted. As a result, the active scrapers (`investorgain.py` and `chittorgarh.py`) now rely **exclusively** on Playwright (`fetch_html_js`) to render Javascript tables.

Because of this shift, massive chunks of the networking layer have silently become dead code that serve absolutely no purpose to the user or developer:

1. **Dead Constants (`config.py`)**
   - `REQUEST_TIMEOUT = 30`
   - `DELAY_BETWEEN_REQUESTS = 1`
   - `MAX_RETRIES = 3`
   *Why it's bloat:* These constants were only used by the `requests` library in the now-defunct `fetch_html` method. Playwright handles its own timeouts. These constants are polluting the configuration.

2. **Dead Methods (`scrapers/base.py`)**
   - `def _throttle(self):`
   - `def fetch_html(self, url):`
   *Why it's bloat:* These methods wrap the `requests` library with exponential backoff and throttling. Since no scraper uses `requests` anymore, this entire block of logic (~25 lines) is dead code.

3. **Dead Constructor State (`scrapers/base.py`)**
   - `self._session = requests.Session()`
   - `self._last_request_time = 0.0`
   *Why it's bloat:* Every time a scraper is initialized, it opens a persistent `requests.Session` connection pool that is completely ignored. 

4. **Unused Dependencies (`scrapers/base.py`)**
   - `import requests`
   - `import time`
   *Why it's bloat:* We can completely uninstall the `requests` library from the environment (if not needed elsewhere), dropping a dependency, and we can remove the `time` import since Playwright uses `page.wait_for_timeout()` natively.

## Actionable Recommendation
Delete `fetch_html`, `_throttle`, the constructor overrides, and the corresponding constants in `config.py`. This will reduce `base.py`'s complexity by over 50% and strip out a third-party dependency.
