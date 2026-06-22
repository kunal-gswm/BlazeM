# Line-by-Line Purpose & Bloat Analysis

## Overview
Every line of code should serve a direct purpose for the user (data extraction) or the developer (maintainability/debugging). This report identifies dead code, unused imports, deprecation warnings, and bloated logic across the repository.

## 1. Dead Code & Unused Imports

The static analysis flagged several unused imports that serve no purpose and consume memory/clutter the namespace:
- `corporate_actions/run.py` (Line 6): `from bse.constants import PURPOSE` is imported but never used.
- `scraper/models.py` (Line 5): `from typing import Any` is unused.
- `scraper/run.py` (Line 3): `import json` is unused because `models.py` handles the JSON serialization.

*Verdict: These lines must be deleted.*

## 2. Deprecation Warnings

In `market_breadth/run.py` and `global_indices/run.py`, the following warning is triggered during execution:
`DeprecationWarning: datetime.datetime.utcnow() is deprecated and scheduled for removal in a future version. Use timezone-aware objects to represent datetimes in UTC: datetime.datetime.now(datetime.UTC).`

*Verdict: The `datetime.utcnow()` calls must be modernized to prevent the scripts from failing in Python 3.12+.*

## 3. Logic Bloat & Unnecessary Computations

### `scraper/transform.py`
- Line 120: `import dataclasses` is imported in the middle of the file. It should be at the top.
- The `_parse_date` function has a very complex regex engine for parsing string dates. It could be significantly simplified using Python's `dateutil.parser`.

### `scraper/run.py`
- Lines 8-12: The `sys.stdout.reconfigure(encoding='utf-8')` block is wrapped in a bare `except Exception: pass`. While it solves a Windows console issue, catching a bare Exception is an anti-pattern. Furthermore, since the script relies on GitHub Actions (Ubuntu), this block is mostly dead code in production.

### `corporate_actions/run.py`
- Lines 33-60: There is a massive `if/elif` block to determine the "action_type" by checking `if 'dividend' in purpose_lower:`. This is repetitive. It can be streamlined using a mapping dictionary or regex, reducing 30 lines of code down to 5.

### `global_indices/run.py`
- The `yfinance` fallback logic uses an entire `try/except` block nested inside another `try/except`. This increases cyclomatic complexity. It should be abstracted into a helper function `_get_yfinance_price(symbol)`.

## 4. Recommended Actions
1. Delete all unused imports.
2. Fix `datetime.utcnow()` deprecation across all 6 pipelines.
3. Refactor the `if/elif` block in `corporate_actions` into a clean dict mapping.
4. Move inline imports (like `dataclasses`) to the top of files.
5. Remove bare `except Exception: pass` blocks and replace with specific exception handling or delete if unnecessary for production.
