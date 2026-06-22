# Naming Conventions & Professional Practices

## Overview
A static analysis of the codebase was conducted using `flake8`. The review focused on PEP8 compliance, variable naming clarity, and idiomatic Python practices.

## 1. Naming Conventions Evaluation

### Variable & Function Naming
The repository mostly adheres to `snake_case` for variables and functions, which is excellent. However, there are a few inconsistencies:
- **Abbreviations:** `idx` is used in `bse.advanceDecline()` processing instead of `index_data` or `sector_data`. 
- **Ambiguous Variables:** In `transform.py`, `m`, `year_m`, and `norm` are used. These should be expanded to `match`, `year_match`, and `normalized_name` for clarity.
- **Constants:** Some constants inside functions should be hoisted to the top of the file as `UPPER_SNAKE_CASE`. For instance, the `SYMBOLS` dict in `global_indices/run.py` is correctly formatted, but similar dictionaries in the Chittorgarh scraper are dynamically generated inside functions.

### File & Directory Naming
Directory and file names are strictly lowercase and use `snake_case`, perfectly aligning with professional standards for Python project structures.

## 2. Professional Practices (PEP8 & Style)

The `flake8` report revealed several stylistic violations that degrade readability:

1. **Line Length (`E501`):** Over 25 instances where lines exceed the 79-character limit (some exceeding 120 characters). This occurs heavily in URL definitions, logging strings, and complex dictionary comprehensions.
2. **Blank Lines (`E302`, `E305`):** Standard Python practice dictates 2 blank lines before class/function definitions. The codebase frequently uses 1.
3. **Trailing Whitespace (`W293`):** Many lines contain invisible trailing spaces.
4. **Import Ordering (`E402`):** `scraper/run.py` and `scraper/transform.py` place standard imports after `sys.path.insert()`. While functionally necessary for local paths, `import json` and `import logging` should remain at the absolute top of the file.

## 3. Recommended Actions
1. Run `black` and `isort` across the entire repository to automatically resolve all PEP8 formatting, spacing, and line-length issues.
2. Standardize variable names to avoid cryptic one-letter abbreviations.
3. Add explicit return types and argument types (`-> list[dict]`, `url: str`) to all newer scrapers, matching the high standard set in `scraper/transform.py`.
