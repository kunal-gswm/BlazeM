# BlazeM

BlazeM is a market-intelligence project that combines automated data pipelines with a Flutter client app.
It continuously collects Indian market datasets, publishes versioned JSON outputs in this repository, and powers a mobile dashboard experience from the same data source.

## What this repository contains

- **Python data pipelines** for scraping and normalizing market data
- **Centralized JSON data store** under `/data`
- **GitHub Actions automation** for scheduled live and end-of-day updates
- **Flutter app (`blamics_app/`)** that reads repository-hosted JSON and presents analytics dashboards

## Key capabilities

- IPO tracking (active/upcoming issues, subscription metrics)
- FII/DII flow monitoring
- Corporate actions and earnings calendar tracking
- Market breadth and sentiment snapshots
- Global indices benchmarks
- Live scanners for sectors, 52-week high/low, commodities, currency, volume shockers, and 10%+ circuit breakers
- Health/status reporting per pipeline (`data/health.json`)
- Optional Firebase push notification triggers for selected events

## Repository structure

```text
BlazeM/
├── core/                  # Shared I/O, logging, config, notifications
├── data/                  # Canonical JSON outputs consumed by the app
├── scraper/               # IPO + live market scrapers
├── fii_dii/               # FII/DII pipeline
├── corporate_actions/     # Corporate actions pipeline
├── earnings_calendar/     # Earnings calendar pipeline
├── global_indices/        # Global indices pipeline
├── market_breadth/        # Market breadth pipeline
├── blamics_app/           # Flutter client application
└── .github/workflows/     # Scheduled automation + release workflows
```

## Data pipeline architecture

Each pipeline writes through `core.io.safe_save`, which provides:

- standardized payload format (`metadata` + `data`)
- retention-threshold protection against unexpected data drops
- automatic archival of previous snapshots in `data/archive/`
- centralized health status updates in `data/health.json`

### Output format (canonical)

```json
{
  "metadata": {
    "source": "...",
    "last_updated": "2026-01-01T00:00:00Z",
    "status": "healthy",
    "record_count": 123
  },
  "data": []
}
```

## Automation workflows

- **Live Data Pipelines (10 Min)**: runs every 10 minutes during market hours (Mon–Fri), updates live datasets
- **Daily Data Pipelines (EOD)**: runs hourly in the configured EOD window, updates daily datasets
- **Release Automation**: on `v*` tags, builds `blamics_app` release APK and publishes GitHub release artifacts

## Local setup

### 1) Python pipelines

#### Prerequisites

- Python 3.11+
- pip

#### Install dependencies

```bash
pip install -r requirements.txt
playwright install chromium
```

#### Run pipelines manually

From repository root:

```bash
python fii_dii/run.py
python corporate_actions/run.py
python earnings_calendar/run.py
python global_indices/run.py
python market_breadth/run.py

python scraper/run.py
python scraper/sector_performance.py
python scraper/market_sentiment.py
python scraper/high_low.py
python scraper/commodities.py
python scraper/currency.py
python scraper/volume_shocker.py
python scraper/circuit_breakers.py
```

### 2) Flutter app (`blamics_app/`)

#### Prerequisites

- Flutter 3.19.x (stable recommended)
- Dart SDK compatible with project constraints

#### Install and run

```bash
cd blamics_app
flutter pub get
flutter run
```

#### Build Android APK

```bash
cd blamics_app
flutter build apk --release
```

## Firebase notifications (optional)

Server-side notification hooks are available in `core/notifications.py`.
To enable FCM sends from pipelines, place a Firebase service account file at:

- `service_account.json` (repository root)

This file is gitignored by default.

## Data source notes

The project aggregates data from multiple public market sources/APIs (e.g., BSE, NSE, Yahoo Finance, and IPO information sites) through source-specific pipeline modules.

## Disclaimer

This project is intended for informational and educational use. It is **not** financial advice.
Always verify critical market information with official exchange or issuer sources before making investment decisions.
