"""
Database connection module for MindMirror.

Provides an asyncpg connection pool for Postgres operations.
Falls back gracefully if DATABASE_URL is not set (in-memory JSON mode).
"""

import os
import asyncpg
from typing import Optional

_pool: Optional[asyncpg.Pool] = None


def get_database_url() -> Optional[str]:
    """Return DATABASE_URL from environment, or None if not configured."""
    return os.environ.get("DATABASE_URL")


async def init_db() -> Optional[asyncpg.Pool]:
    """
    Initialize the asyncpg connection pool.
    Returns the pool if successful, None if DATABASE_URL is not set or connection fails.
    """
    global _pool
    db_url = get_database_url()

    if not db_url:
        print("[INFO] DATABASE_URL not set — running in JSON-file fallback mode")
        return None

    try:
        _pool = await asyncpg.create_pool(
            dsn=db_url,
            min_size=2,
            max_size=10,
            command_timeout=30,
        )
        # Quick connectivity check
        async with _pool.acquire() as conn:
            version = await conn.fetchval("SELECT version()")
            print(f"[OK] Connected to Postgres: {version[:60]}...")
        return _pool
    except Exception as e:
        print(f"[ERROR] Failed to connect to Postgres: {e}")
        print("[INFO] Falling back to JSON-file mode")
        _pool = None
        return None


async def close_db():
    """Close the connection pool."""
    global _pool
    if _pool:
        await _pool.close()
        _pool = None
        print("[OK] Database connection pool closed")


def get_pool() -> Optional[asyncpg.Pool]:
    """Return the current pool (may be None if not connected)."""
    return _pool
