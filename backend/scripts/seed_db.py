import asyncio
import json
import asyncpg
from datetime import datetime

DATABASE_URL = "postgresql://blamics:blamics@localhost:5432/blamics"
SEED_FILE = "e:/BlazeM/mobile/assets/data/seed_data.json"

async def main():
    print(f"Connecting to {DATABASE_URL}...")
    try:
        conn = await asyncpg.connect(DATABASE_URL)
    except Exception as e:
        print(f"Failed to connect: {e}")
        return

    print("Loading seed data...")
    try:
        with open(SEED_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception as e:
        print(f"Failed to load seed file: {e}")
        return

    print("Inserting sources...")
    for s in data["sources"]:
        await conn.execute("""
            INSERT INTO sources (id, name, priority, website, is_active)
            VALUES ($1, $2, $3, $4, $5)
            ON CONFLICT (id) DO UPDATE SET
                name = EXCLUDED.name,
                priority = EXCLUDED.priority,
                website = EXCLUDED.website,
                is_active = EXCLUDED.is_active
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
            ON CONFLICT (id) DO UPDATE SET
                company_name = EXCLUDED.company_name,
                symbol = EXCLUDED.symbol,
                issue_price_min = EXCLUDED.issue_price_min,
                issue_price_max = EXCLUDED.issue_price_max,
                lot_size = EXCLUDED.lot_size,
                issue_size = EXCLUDED.issue_size,
                retail_quota = EXCLUDED.retail_quota,
                status = EXCLUDED.status,
                open_date = EXCLUDED.open_date,
                close_date = EXCLUDED.close_date,
                allotment_date = EXCLUDED.allotment_date,
                listing_date = EXCLUDED.listing_date,
                source_id = EXCLUDED.source_id,
                fetched_at = EXCLUDED.fetched_at,
                updated_at = EXCLUDED.updated_at
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
            ON CONFLICT (id) DO UPDATE SET
                company_name = EXCLUDED.company_name,
                symbol = EXCLUDED.symbol,
                action_type = EXCLUDED.action_type,
                ratio = EXCLUDED.ratio,
                record_date = EXCLUDED.record_date,
                ex_date = EXCLUDED.ex_date,
                payment_date = EXCLUDED.payment_date,
                status = EXCLUDED.status,
                source_id = EXCLUDED.source_id,
                fetched_at = EXCLUDED.fetched_at,
                updated_at = EXCLUDED.updated_at
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
            ON CONFLICT (id) DO UPDATE SET
                event_type = EXCLUDED.event_type,
                entity_type = EXCLUDED.entity_type,
                entity_id = EXCLUDED.entity_id,
                title = EXCLUDED.title,
                subtitle = EXCLUDED.subtitle,
                date = EXCLUDED.date,
                status = EXCLUDED.status,
                importance = EXCLUDED.importance,
                importance_score = EXCLUDED.importance_score,
                source_id = EXCLUDED.source_id,
                fetched_at = EXCLUDED.fetched_at,
                updated_at = EXCLUDED.updated_at
        """, ev["id"], ev["event_type"], ev["entity_type"], ev["entity_id"], ev["title"], ev.get("subtitle"),
           datetime.fromisoformat(ev["date"]), ev["status"], ev["importance"], ev["importance_score"],
           meta["source_id"], datetime.fromisoformat(meta["created_at"]),
           datetime.fromisoformat(meta["fetched_at"]), datetime.fromisoformat(meta["updated_at"]) if meta.get("updated_at") else None)

    print("Seeding complete.")
    await conn.close()

if __name__ == "__main__":
    asyncio.run(main())
