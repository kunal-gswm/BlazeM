# Blamics

Event-first market events tracking application.

## Structure

```
backend/    → FastAPI + asyncpg + PostgreSQL
mobile/     → Flutter + Riverpod + Dio + sqflite
docs/       → Architecture documentation
```

## Backend

```bash
cd backend
pip install -r requirements.txt
cp .env.example .env
# Start PostgreSQL, create database
python -m app.db.migrations.migrate
uvicorn app.main:app --reload
```

## Mobile

```bash
cd mobile
flutter pub get
flutter run
```

## Architecture

- **No ORM** — raw SQL via asyncpg
- **No auth** — single user
- **No repositories** — router → service → SQL
- **Feature-first** Flutter with models/services/providers/screens per feature
- **Event-first** — everything becomes a TimelineEvent
- **Source attribution** — every record carries source, priority, timestamps
- **Stale-while-revalidate** — cached data shown with freshness indicators
