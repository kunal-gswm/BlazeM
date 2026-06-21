# Scrapers & Orchestration Analysis

**Scope:** `scrapers/investorgain.py`, `scrapers/chittorgarh.py`, `run.py`, and `merge.py`.

## Findings: Structural Overengineering and Boilerplate

1. **The Abstract Base Class (OOP Bloat)**
   - Both `InvestorGainScraper` and `ChittorgarhScraper` inherit from `BaseScraper`. 
   - *Why it's bloat:* Inheritance hierarchies make sense when you have 50 subclasses and deep polymorphic behaviors. For exactly 2 scrapers that simply download HTML and run a few BeautifulSoup commands, class inheritance is textbook Java-style overengineering. 
   - A suckless architecture would use simple functions (`scrape_investorgain()`) that call a standalone `fetch_html_js()` utility function.

2. **CLI Orchestration Bloat (`run.py`)**
   - `run.py` uses the standard library `argparse` to set up `--source` and `--verbose` arguments.
   - *Why it's bloat:* This script is designed to run automatically via GitHub Actions, which never passes these arguments. Even if run manually, a developer is highly unlikely to want to scrape just *one* half of an IPO dataset. Dropping `argparse` removes ~20 lines of parsing logic, meaning `main()` can just be 10 lines of direct execution.

3. **Dead Loop Overrides (`merge.py`)**
   - In `merge.py`, the `_fill_missing` function explicitly loops over a hardcoded list of fields: `["price_band", "face_value", "lot_size", ...]`.
   - *Why it's bloat:* We removed `face_value`. Furthermore, manually defining strings of object attributes is brittle. It would be cleaner to just iterate over `dataclasses.fields(target)`.

4. **Regex Bloat (`investorgain.py`)**
   - In `_parse_row`, there are multiple regex passes to clean up the IPO name (e.g. removing "U", removing "L@268", removing "IPO"). 
   - *Why it's bloat:* Since `normalize_name` exists in `merge.py` and handles standardizing names across sources, applying heavy regex to clean up trailing characters locally inside the scraper is redundant. `normalize_name` should act as the single source of truth for name normalization to prevent fragmented cleaning logic.

## Actionable Recommendation
1. Rip out the `BaseScraper` class inheritance. 
2. Flatten the directory: move `investorgain.py` and `chittorgarh.py` to the root `scraper/` folder and turn them into pure procedural functions.
3. Remove `argparse` from `run.py` for a pure, zero-argument script execution.
4. Clean up `_fill_missing` in `merge.py` to be dynamic rather than hardcoded.
