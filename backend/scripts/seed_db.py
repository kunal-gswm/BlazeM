import asyncio
import json
import asyncpg
from datetime import datetime

DATABASE_URL = "postgresql://blamics:blamics@localhost:5432/blamics"
SCHEMA_FILE = "e:/BlazeM/backend/app/db/migrations/001_initial.sql"
SEED_FILE = "e:/BlazeM/mobile/assets/data/seed_data.json"

async def main():
    print(f"Connecting to {DATABASE_URL}...")
    try:
        conn = await asyncpg.connect(DATABASE_URL)
    except Exception as e:
        print(f"Failed to connect: {e}")
        return

    print("Dropping existing tables and recreating schema...")
    with open(SCHEMA_FILE, "r", encoding="utf-8") as f:
        schema_sql = f.read()

    # Drop tables to be safe (ignoring errors if they don't exist)
    await conn.execute("""
        DROP TABLE IF EXISTS event_field_history CASCADE;
        DROP TABLE IF EXISTS timeline_events CASCADE;
        DROP TABLE IF EXISTS gmp_history CASCADE;
        DROP TABLE IF EXISTS news CASCADE;
        DROP TABLE IF EXISTS bonds CASCADE;
        DROP TABLE IF EXISTS corporate_actions CASCADE;
        DROP TABLE IF EXISTS ipos CASCADE;
        DROP TABLE IF EXISTS sources CASCADE;
        
        DROP TYPE IF EXISTS relevance_reason CASCADE;
        DROP TYPE IF EXISTS bond_status CASCADE;
        DROP TYPE IF EXISTS action_type CASCADE;
        DROP TYPE IF EXISTS event_importance CASCADE;
        DROP TYPE IF EXISTS event_status CASCADE;
        DROP TYPE IF EXISTS entity_type_enum CASCADE;
        DROP TYPE IF EXISTS event_type_enum CASCADE;
        DROP TYPE IF EXISTS source_priority_level CASCADE;
    """)

    await conn.execute(schema_sql)
    print("Schema created.")

    print("Loading seed data...")
    with open(SEED_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    print("Inserting sources...")
    for s in data["sources"]:
        await conn.execute("""
            INSERT INTO sources (id, name, priority, website, is_active)
            VALUES ($1, $2, $3, $4, $5)
        """, s["id"], s["name"], s["priority"], s.get("website"), s.get("is_active", True))

    print("Inserting IPOs...")
    for ipo in data["ipos"]:
        meta = ipo["meta"]
        await conn.execute("""
            INSERT INTO ipos (
                id, company_name, symbol, issue_price_min, issue_price_max,
                lot_size, issue_size, retail_quota, status,
                open_date, close_date, allotment_date, listing_date,
                source_id, created_at, fetched_at, updated_at
            ) VALUES (
                $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17
            )
        """, ipo["id"], ipo["company_name"], ipo["symbol"], ipo["issue_price_min"], ipo["issue_price_max"],
           ipo["lot_size"], ipo["issue_size"], ipo["retail_quota"], ipo["status"],
           datetime.fromisoformat(ipo["open_date"]).date() if ipo.get("open_date") else None,
           datetime.fromisoformat(ipo["close_date"]).date() if ipo.get("close_date") else None,
           datetime.fromisoformat(ipo["allotment_date"]).date() if ipo.get("allotment_date") else None,
           datetime.fromisoformat(ipo["listing_date"]).date() if ipo.get("listing_date") else None,
           meta["source_id"], datetime.fromisoformat(meta["created_at"]),
           datetime.fromisoformat(meta["fetched_at"]), datetime.fromisoformat(meta["updated_at"]) if meta.get("updated_at") else None)

    print("Inserting corporate actions...")
    for ca in data["corporate_actions"]:
        meta = ca["meta"]
        await conn.execute("""
            INSERT INTO corporate_actions (
                id, company_name, symbol, action_type, ratio,
                record_date, ex_date, payment_date, status,
                source_id, created_at, fetched_at, updated_at
            ) VALUES (
                $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13
            )
        """, ca["id"], ca["company_name"], ca["symbol"], ca["action_type"], ca["ratio"],
           datetime.fromisoformat(ca["record_date"]).date() if ca.get("record_date") else None,
           datetime.fromisoformat(ca["ex_date"]).date() if ca.get("ex_date") else None,
           datetime.fromisoformat(ca["payment_date"]).date() if ca.get("payment_date") else None,
           ca["status"], meta["source_id"], datetime.fromisoformat(meta["created_at"]),
           datetime.fromisoformat(meta["fetched_at"]), datetime.fromisoformat(meta["updated_at"]) if meta.get("updated_at") else None)

    print("Inserting timeline events...")
    for ev in data["timeline_events"]:
        meta = ev["meta"]
        await conn.execute("""
            INSERT INTO timeline_events (
                id, event_type, entity_type, entity_id, title, subtitle,
                date, status, importance, importance_score,
                source_id, created_at, fetched_at, updated_at
            ) VALUES (
                $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14
            )
        """, ev["id"], ev["event_type"], ev["entity_type"], ev["entity_id"], ev["title"], ev.get("subtitle"),
           datetime.fromisoformat(ev["date"]), ev["status"], ev["importance"], ev["importance_score"],
           meta["source_id"], datetime.fromisoformat(meta["created_at"]),
           datetime.fromisoformat(meta["fetched_at"]), datetime.fromisoformat(meta["updated_at"]) if meta.get("updated_at") else None)

    print("Seeding complete.")
    await conn.close()

if __name__ == "__main__":
    asyncio.run(main())
