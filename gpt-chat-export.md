## 1) Stack

* Python 3.12, FastAPI, Jinja2 templates, plain CSS, minimal vanilla JS
* PostgreSQL, raw SQL via psycopg, Alembic migrations
* No ORM, no SQLAlchemy, no React, no TypeScript, no Redis, no queue workers

---

## 2) MVP features

### A. Dashboard

* today's events, next 7 days
* active / upcoming / recently listed IPOs
* upcoming dividends, bonuses, splits, rights issues
* watched items with recent changes
* relevant news

### B. IPO section

Per IPO: company name, category (mainboard/SME), issue size, price band, lot size, open date, close date, allotment date, listing date, GMP current + history, subscription status, source, timestamp.

### C. Corporate actions

Types: dividend, bonus, stock split, rights issue.
Per item: company, action type, ex-date, record date, value/ratio, announcement date, status (upcoming/active/completed).

### D. Bonds

Retail-accessible only. Per item: issuer, bond type, coupon/rate, open date, close date, maturity date, minimum investment, credit rating, status, source, timestamp.

### E. News

Only news that: mentions a tracked entity, changes an event date/status/GMP/terms, or materially affects the event.

### F. Search

Company name, keyword, category filter, status filter, date filter.

### G. Watchlist

Add, remove, reorder. Supports IPOs, companies, bonds, event items.

### H. Source attribution

Every displayed item: source name, source URL, fetched time, event time.

### I. Data freshness

Every record: last updated time, stale flag, failed-sync indicator.

### J. History

Retain history for GMP changes, status changes, date changes, event updates. Never overwrite past records.

---

## 3) Non-goals

Not in MVP: login, user accounts, multi-user, payments, alerts, email/Telegram/push notifications, portfolio tracking, P&L, trade journal, stock screeners, valuation models, recommendation engine, prediction engine, AI summaries, sentiment scores, charts beyond simple counts, broker integration, order placement, mobile app, React, TypeScript, ORM, SQLAlchemy, Redis, queue workers, microservices.

---

## 4) File tree

```text
finance-events-mvp/
├── README.md
├── pyproject.toml
├── .env.example
├── .gitignore
├── .editorconfig
├── docker-compose.yml
├── alembic.ini
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── core/
│   │   ├── settings.py
│   │   ├── logging.py
│   │   ├── constants.py
│   │   └── time.py
│   ├── db/
│   │   ├── connection.py
│   │   ├── transaction.py
│   │   └── schema.sql
│   ├── models/
│   │   ├── source.py
│   │   ├── ipo.py
│   │   ├── corporate_action.py
│   │   ├── bond.py
│   │   ├── news.py
│   │   └── watchlist.py
│   ├── schemas/
│   │   ├── common.py
│   │   ├── source.py
│   │   ├── ipo.py
│   │   ├── corporate_action.py
│   │   ├── bond.py
│   │   ├── news.py
│   │   └── watchlist.py
│   ├── services/
│   │   ├── source_client.py
│   │   ├── normalizer.py
│   │   ├── ingestion.py
│   │   ├── query_service.py
│   │   └── watchlist_service.py
│   ├── api/
│   │   ├── router.py
│   │   ├── health.py
│   │   ├── dashboard.py
│   │   ├── ipos.py
│   │   ├── corporate_actions.py
│   │   ├── bonds.py
│   │   ├── news.py
│   │   └── watchlist.py
│   ├── templates/
│   │   ├── base.html
│   │   ├── dashboard.html
│   │   ├── list.html
│   │   ├── detail.html
│   │   ├── watchlist.html
│   │   └── partials/
│   │       └── event_card.html
│   └── static/
│       ├── app.css
│       └── app.js
├── migrations/
│   ├── env.py
│   ├── script.py.mako
│   └── versions/
│       └── 0001_initial.py
├── scripts/
│   ├── seed_demo_data.py
│   └── sync_sources.py
└── tests/
    ├── conftest.py
    ├── test_models.py
    ├── test_normalizer.py
    ├── test_ingestion.py
    ├── test_routes.py
    ├── test_watchlist.py
    └── test_datetime_and_money.py
```

44 files. API routes contain no business logic. Services handle rules. Models hold structure. Templates render only.

---

## 5) Coding standards

**Money:** Decimal for all financial values. Never float. Store raw, format at presentation.
**Time:** Store UTC. Convert on render. Every event carries announcement time, event time, fetched time. ISO-8601 at API boundaries.
**Data integrity:** Ingestion is transactional. Syncs are idempotent. History is append-only. Current-state and historical rows stay separate.
**Source provenance:** Every record stores source metadata. Every UI item shows source. Unattributed records are rejected.
**Layering:** Routes → services → models → templates. No business logic in routes or templates.
**Validation:** Validate source payloads before normalization. Reject incomplete records. Never guess missing values.
**Error handling:** Fail closed. One broken source must not break the app. Surface stale data and sync failures explicitly.
**Logging:** Log fetch start/end, row counts, parse failures, sync failures. Never log secrets.
**Security:** No SQL concatenation. No unescaped output. No secrets in repo. No implicit trust of source data.

---

## 6) Finance-specific rules

1. **Provenance over prettiness.** If you cannot identify where a number came from, do not show it.
2. **Current state ≠ history.** A current GMP is not the same as GMP history. Keep them visibly separate.
3. **Event dates must be explicit.** Never hide or infer ex-date, record date, open/close date, listing date, maturity date.
4. **State must be modeled.** Every event has a status: upcoming, open, closed, listed, completed, changed, withdrawn.
5. **No recommendation language.** No buy/sell/best/safe/guaranteed. Informational only.
6. **No fake precision.** Do not pretend GMP or relevance is more exact than the source allows.
7. **Retail filter for bonds.** Only retail-relevant bonds. No institutional debt.
8. **Staleness must be visible.** Old data without a visible timestamp is misinformation.

---

## 7) Build phases

| Phase | Duration | Core work | Gate |
|-------|----------|-----------|------|
| 1. Scope lock | 4–7 days | Define every event type, inclusion/exclusion rule | Every feature has a yes/no definition. No "later maybe." |
| 2. Source selection | 4–8 days | Identify sources, check reliability, verify repeatability | Every category has a usable source. None depend on hope. |
| 3. Data model | 3–5 days | Canonical types, current vs history, status values, date fields, dedup rules | One schema handles all event types without hacks. |
| 4. App skeleton + UI | 6–10 days | Dashboard, list/detail pages, search, filters, watchlist, source/freshness display | App is readable, navigable. Every item type has a clear home. |
| 5. Ingestion | 6–10 days | Fetch, normalize, dedupe, write current+history, mark stale/failed | Repeated syncs don't corrupt records or lose history. |
| 6. Testing | 4–7 days | Edge cases, stale data, missing fields, dupes, date/money precision, security | App behaves predictably with messy/missing/delayed data. |
| 7. Release freeze | 2–4 days | Remove unstable features, fix defects only, freeze scope | Nothing outside MVP is present. |

**Total: 4–7 weeks.**

---

## 8) Review checkpoints

1. **Scope freeze:** Every feature is in or out. No vague future items survive.
2. **Source approval:** Each data type has a defensible source. None sourced by hope.
3. **Data model:** Canonical entities, history rules, timestamps, dedup all reviewed.
4. **Terminology:** All user-facing labels match financial meaning.
5. **Freshness/failure:** Stale and failed data is clearly visible.
6. **News relevance:** Only event-changing news appears. No generic headlines.
7. **Security:** No injection, secret exposure, or "it's only for me" shortcuts.
8. **Release candidate:** Full end-to-end pass. Only MVP items remain.

---

## 9) Acceptance criteria

MVP is done only when all are true:

* IPOs display with source and timestamps
* Corporate actions display with event dates
* Bonds show only retail-relevant items
* News shows only relevant items
* Watchlist works
* Search and filters work
* GMP history is preserved
* Sync failure does not break the app
* Stale data is visibly marked
* No out-of-scope features exist

---

## 10) Known weaknesses in this spec

### Source conflicts are undefined
If Source A and Source B disagree, the app needs a hierarchy: official wins, then latest verified timestamp, then flag for manual review.

### News relevance is partly judgment
"Relevant news" is clean at PRD level but messy in practice. Some news is clearly relevant, some is contextual, some matters only because of timing. Treat the filter as iterative, not deterministic.

### Normalization is the core problem
Same company with different spellings, same event with different dates from different sources, partial updates, stale overwrites, duplicate entries, source conflicts. This is where the project can rot. Do not treat it as a phase—it is the heart of the system.

### Bond scope is still ambiguous
"Retail-accessible" needs specifics: listed bonds? NCDs? Primary issues only? SGBs? Define exactly which bond types are in MVP.

### Data truth takes more time than UI
Choosing sources, checking stability, defining the schema, verifying history rules, making data trustworthy, and testing ugly cases—this is the real time sink, not building screens.

### Legal and practical source constraints
Pages may be dynamic, data may be behind JS, scraping may break, reuse may be limited. Do not assume source feasibility before checking.

---

## 11) Practical corrections

**A. Reduce file plan.** Do not start with 40+ files if pain has not appeared. One app package, one db layer, one ingestion layer, one query layer, one templates folder, one test folder. Split when it hurts.

**B. Source selection is gate zero.** No coding until every source is named, every field is mapped, every conflict rule is defined.

**C. Source conflict policy is mandatory.** Official disclosure wins. Newer verified timestamp wins. Unresolvable conflicts get flagged.

**D. Define stale-data behavior precisely.** After how long, by event type, what badge appears, whether stale data can still be shown, whether it stays on dashboard.

**E. Narrow bond scope hard.** Say exactly which bond types are in MVP.

**F. Current view ≠ history view.** If mixed, the product lies by omission.

**G. Put manual review earlier.** Bad source logic discovered late is expensive.

---

## 12) Assumptions

1. One developer, AI writes most code
2. Single-user MVP, information-only
3. Core: IPOs, GMP, bonds, corporate actions, relevant news
4. No login, no public scale at MVP
5. Raw SQL, no ORM
6. Must survive partial source failure and stale data

**Do not ask AI to finalize what only source research can settle. Use AI to draft. Use yourself to decide.**
