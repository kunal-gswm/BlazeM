# Architecture & Separation of Concerns Analysis

## Overview
The BlazeM repository currently consists of 6 core data pipelines:
1. `scraper` (IPO Scraper)
2. `corporate_actions`
3. `earnings_calendar`
4. `fii_dii`
5. `market_breadth`
6. `global_indices`

## 1. Separation of Concerns (SoC) Evaluation

### The Ideal Pattern (Found in `scraper`)
The original `scraper` pipeline elegantly follows the **Single Responsibility Principle (SRP)**:
- **Data Models:** `models.py` (Defines the schema `IPOData`)
- **Extraction:** `investorgain.py` and `chittorgarh.py` (Focus purely on fetching HTML and extracting lists of models)
- **Transformation:** `transform.py` (Focuses purely on deduplication and merging)
- **Utilities:** `utils.py` (Playwright wrapper and text cleaners)
- **Configuration:** `config.py` (URLs, CSS Selectors, Headers)
- **Controller:** `run.py` (Orchestrates the flow and handles I/O)

### The Anti-Pattern (Found in Newer Pipelines)
The newer pipelines (`corporate_actions`, `earnings_calendar`, `fii_dii`, `market_breadth`, `global_indices`) currently violate SRP by combining all concerns into a single `run.py` file. 

**Issues in Newer Pipelines:**
- **I/O Mixed with Logic:** Fetching data via `requests` or `BseIndiaApi`, formatting JSON, sorting logic, and writing to the disk are all tangled within a single `fetch_x()` function.
- **Hardcoded Settings:** URLs, Headers, and File Paths are hardcoded inside the functions rather than extracted to a config file.
- **No Domain Models:** Unlike `IPOData`, the new pipelines use raw dictionaries, increasing the risk of schema drifts and KeyError exceptions.

## 2. Reusability Analysis
There are several duplicated concerns across the repo that should be abstracted into a shared core directory:
1. **Logging Setup:** Every `run.py` file redeclares `logging.basicConfig(...)`.
2. **Path Resolution:** Every file redeclares `OUTPUT_DIR = Path("data")`.
3. **Session Headers:** The `User-Agent` string is hardcoded redundantly in `fii_dii/run.py`, `global_indices/run.py`, and `scraper/config.py`.

## 3. Recommended Actions
1. **Create a `core` directory** at the root to hold shared utilities (Logging, File I/O wrappers, Shared Request Sessions with randomized headers).
2. **Refactor the newer pipelines** to separate their Domain Models, Fetch Logic, and CLI Orchestration.
3. **Standardize JSON Output Structure** across all pipelines (e.g., ensuring `last_updated` uses the exact same ISO8601 UTC format).
