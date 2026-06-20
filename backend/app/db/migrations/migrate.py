"""
Simple SQL migration runner.

Reads numbered .sql files and executes them in order.
Tracks applied migrations in a _migrations table.
"""

import asyncio
import glob
import os

import asyncpg

from app.config import settings


async def run_migrations():
    conn = await asyncpg.connect(dsn=settings.database_url)

    try:
        # Create migrations tracking table
        await conn.execute("""
            CREATE TABLE IF NOT EXISTS _migrations (
                id SERIAL PRIMARY KEY,
                filename TEXT UNIQUE NOT NULL,
                applied_at TIMESTAMPTZ DEFAULT NOW()
            )
        """)

        # Get applied migrations
        applied = {
            row["filename"]
            for row in await conn.fetch("SELECT filename FROM _migrations")
        }

        # Find and run pending migrations
        migration_dir = os.path.dirname(__file__)
        sql_files = sorted(glob.glob(os.path.join(migration_dir, "*.sql")))

        for filepath in sql_files:
            filename = os.path.basename(filepath)
            if filename in applied:
                continue

            print(f"Applying migration: {filename}")
            with open(filepath, "r") as f:
                sql = f.read()

            if sql.strip():
                await conn.execute(sql)

            await conn.execute(
                "INSERT INTO _migrations (filename) VALUES ($1)", filename
            )
            print(f"  ✓ {filename}")

        print("All migrations applied.")

    finally:
        await conn.close()


if __name__ == "__main__":
    asyncio.run(run_migrations())
