# Blamics

A professional, event-first market tracking application focusing on information density and actionable timelines.

## Architecture
- **Mobile**: Flutter, Riverpod, Dio
- **Backend**: FastAPI (Python 3.12)
- **Database**: PostgreSQL (Raw SQL via asyncpg, no ORM)

---

## Local Development Setup

To verify the endpoints locally and connect the Flutter application, you must run PostgreSQL and the FastAPI server.

### 1. Run PostgreSQL
You need a PostgreSQL database named `blamics` running on port 5432 with user `blamics` and password `blamics`.

Using Docker:
```bash
docker run --name blamics-db -e POSTGRES_USER=blamics -e POSTGRES_PASSWORD=blamics -e POSTGRES_DB=blamics -p 5432:5432 -d postgres:15-alpine
```

### 2. Apply Schema & Seed Data
Once the database is running, apply the schema and insert the realistic seed data. Our seed script uses `ON CONFLICT DO UPDATE` so it is safe to run multiple times without duplicating rows.

```bash
cd backend
python scripts/seed_db.py
```
*(Ensure you have installed the backend requirements: `pip install -r requirements.txt`)*

### 3. Start the FastAPI Backend
Start the backend server on `0.0.0.0` so it can be accessed by physical devices or emulators on your network.

```bash
cd backend
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### 4. Verify Endpoints
You can now hit the following endpoints locally to verify the data ingestion logic:
- **Health Check**: `http://localhost:8000/health` (Should return `{"status": "ok", "database": true}`)
- **Timeline Events**: `http://localhost:8000/api/v1/events/timeline` (Ordered by date and importance)
- **IPOs**: `http://localhost:8000/api/v1/ipos` (Joined with the latest GMP)

### 5. Connect the Flutter Application
By default, the Flutter app's `ApiService` points to `http://10.0.2.2:8000/api/v1` which routes to the localhost of your machine *only* when running inside an Android Emulator.

**Testing on a Physical Device:**
If you are testing on a real physical iPhone or Android device, `10.0.2.2` will not work.
1. Find your computer's local IP address (e.g., `192.168.1.5`).
2. Open `mobile/lib/core/services/api_service.dart`.
3. Change the `baseUrl` to `http://192.168.1.5:8000/api/v1`.
4. Run `flutter run`.

If the connection fails (or you turn off your Wi-Fi), the Riverpod providers will smoothly catch the `DioException` and query the local `CacheService`, displaying a prominent orange **Offline • Showing cached data** banner at the top of the UI.
