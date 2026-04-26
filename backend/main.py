import uuid
import json
import os
from datetime import datetime, timezone
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional

try:
    from models import JournalEntry, InsightModel, Correlation, EntryRequest, ErrorModel, ErrorDetail
except ModuleNotFoundError:
    from backend.models import JournalEntry, InsightModel, Correlation, EntryRequest, ErrorModel, ErrorDetail

try:
    from db import init_db, close_db, get_pool
except ModuleNotFoundError:
    from backend.db import init_db, close_db, get_pool


# ---------------------------------------------------------------------------
# Application Lifespan (startup / shutdown)
# ---------------------------------------------------------------------------
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initialize DB pool on startup, close on shutdown."""
    pool = await init_db()
    data_service._pool = pool
    if pool:
        print("[OK] Backend running in DATABASE mode (Postgres)")
    else:
        print("[OK] Backend running in JSON-FILE mode (in-memory)")
    yield
    await close_db()


app = FastAPI(title="MindMirror API Orchestration", lifespan=lifespan)

# CORS — allow Flutter frontend to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------------------------------------------------------------------------
# Data Service: Dual-mode — Postgres DB or in-memory JSON fallback
# ---------------------------------------------------------------------------
class DataService:
    """
    Dual-mode data store:
    - If a Postgres pool is available (DATABASE_URL set), reads/writes to the DB.
    - Otherwise, falls back to loading analytics JSON files into memory.
    """

    def __init__(self):
        self._entries: List[dict] = []
        self._insight: Optional[dict] = None
        self._pool = None  # Set during lifespan startup
        self._load_json_fallback()

    @property
    def use_db(self) -> bool:
        return self._pool is not None

    # -------------------------------------------------------------------
    # JSON Fallback Loader
    # -------------------------------------------------------------------
    def _load_json_fallback(self):
        """Load synthetic data and insight from the analytics directory."""
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

        entries_path = os.path.join(base_dir, "analytics", "synthetic_data.json")
        if os.path.exists(entries_path):
            with open(entries_path, "r") as f:
                data = json.load(f)
                self._entries = data.get("data", [])
            print(f"[OK] Loaded {len(self._entries)} journal entries from {entries_path}")
        else:
            print(f"[WARN] No synthetic data found at {entries_path}, using empty dataset")

        insight_path = os.path.join(base_dir, "analytics", "current_insight.json")
        if os.path.exists(insight_path):
            with open(insight_path, "r") as f:
                self._insight = json.load(f)
            print(f"[OK] Loaded insight from {insight_path}")
        else:
            print(f"[WARN] No insight found at {insight_path}, using fallback")

    # -------------------------------------------------------------------
    # GET ENTRIES
    # -------------------------------------------------------------------
    async def get_entries(self, limit: int = 10, offset: int = 0) -> dict:
        """Return paginated entries sorted by created_at descending."""
        if self.use_db:
            return await self._get_entries_db(limit, offset)
        return self._get_entries_json(limit, offset)

    async def _get_entries_db(self, limit: int, offset: int) -> dict:
        """Fetch entries from Postgres."""
        async with self._pool.acquire() as conn:
            rows = await conn.fetch(
                """
                SELECT id, user_id, raw_text, sentiment_score, tags, triggers, created_at
                FROM journal_entries
                ORDER BY created_at DESC
                LIMIT $1 OFFSET $2
                """,
                limit,
                offset,
            )
            total = await conn.fetchval("SELECT COUNT(*) FROM journal_entries")

        entries = [self._row_to_entry(row) for row in rows]
        return {
            "data": entries,
            "meta": {
                "total": total,
                "has_more": (offset + limit) < total,
            },
        }

    def _get_entries_json(self, limit: int, offset: int) -> dict:
        """Fetch entries from in-memory JSON list."""
        sorted_entries = sorted(
            self._entries,
            key=lambda e: e.get("created_at", ""),
            reverse=True,
        )
        total = len(sorted_entries)
        page = sorted_entries[offset: offset + limit]
        return {
            "data": page,
            "meta": {
                "total": total,
                "has_more": (offset + limit) < total,
            },
        }

    # -------------------------------------------------------------------
    # ADD ENTRY
    # -------------------------------------------------------------------
    async def add_entry(self, raw_text: str) -> dict:
        """
        Create a new entry with real sentiment extraction via Google Gemini,
        then persist to DB (or in-memory list as fallback).
        """
        # --- LLM Extraction (unchanged) ---
        sentiment, tags, triggers = self._extract_sentiment(raw_text)

        if self.use_db:
            return await self._add_entry_db(raw_text, sentiment, tags, triggers)
        return self._add_entry_json(raw_text, sentiment, tags, triggers)

    def _extract_sentiment(self, raw_text: str) -> tuple:
        """Run Gemini LLM extraction. Returns (score, tags, triggers)."""
        from google import genai
        import instructor
        from pydantic import BaseModel as PydanticBaseModel, Field

        class SentimentExtraction(PydanticBaseModel):
            sentiment_score: float = Field(..., description="Sentiment score from -1.0 (very negative) to 1.0 (very positive)")
            tags: List[str] = Field(..., description="List of emotion or situational tags (e.g., 'tired', 'gym', 'stressed')")
            triggers: List[str] = Field(..., description="List of specific triggers causing the emotion (e.g., 'lack of sleep', 'academic pressure')")

        api_key = os.environ.get("GOOGLE_API_KEY", "")
        genai_client = genai.Client(api_key=api_key)
        client = instructor.from_genai(genai_client)

        try:
            print(f"Calling Gemini for extraction on text: {raw_text}")
            extracted = client.chat.completions.create(
                model="gemini-1.5-flash",
                response_model=SentimentExtraction,
                messages=[
                    {"role": "system", "content": "You are an AI that analyzes journal entries. Extract the sentiment score (-1.0 to 1.0), situational/emotional tags, and root triggers for the emotions."},
                    {"role": "user", "content": raw_text}
                ],
                max_retries=3
            )
            sentiment = max(-1.0, min(1.0, extracted.sentiment_score))
            return sentiment, list(set(extracted.tags)), list(set(extracted.triggers))
        except Exception as e:
            print(f"[ERROR] Gemini extraction failed: {e}")
            return 0.0, ["general"], []

    async def _add_entry_db(self, raw_text: str, sentiment: float, tags: list, triggers: list) -> dict:
        """Insert entry into Postgres and return the inserted row."""
        user_id = "4e3c9a57-9629-46d4-ae8e-50921bfce626"  # Default synthetic user

        async with self._pool.acquire() as conn:
            row = await conn.fetchrow(
                """
                INSERT INTO journal_entries (user_id, raw_text, sentiment_score, tags, triggers)
                VALUES ($1, $2, $3, $4::jsonb, $5::jsonb)
                RETURNING id, user_id, raw_text, sentiment_score, tags, triggers, created_at
                """,
                uuid.UUID(user_id),
                raw_text,
                round(sentiment, 2),
                json.dumps(tags),
                json.dumps(triggers),
            )
        return self._row_to_entry(row)

    def _add_entry_json(self, raw_text: str, sentiment: float, tags: list, triggers: list) -> dict:
        """Add entry to in-memory list (JSON fallback)."""
        entry = {
            "id": str(uuid.uuid4()),
            "user_id": self._entries[0]["user_id"] if self._entries else "user-123",
            "raw_text": raw_text,
            "sentiment_score": round(sentiment, 2),
            "tags": tags,
            "triggers": triggers,
            "created_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        }
        self._entries.insert(0, entry)
        return entry

    # -------------------------------------------------------------------
    # GET INSIGHT
    # -------------------------------------------------------------------
    async def get_current_insight(self) -> dict:
        """Return the latest insight."""
        if self.use_db:
            return await self._get_insight_db()
        return self._get_insight_json()

    async def _get_insight_db(self) -> dict:
        """Fetch the latest insight from Postgres."""
        async with self._pool.acquire() as conn:
            row = await conn.fetchrow(
                """
                SELECT id, user_id, summary, correlations, suggested_action, generated_at
                FROM insights
                ORDER BY generated_at DESC
                LIMIT 1
                """
            )
        if row:
            return self._row_to_insight(row)
        # If no insights in DB, return fallback
        return self._get_insight_json()

    def _get_insight_json(self) -> dict:
        """Return the pre-computed insight from JSON or a hardcoded fallback."""
        if self._insight:
            return self._insight
        return {
            "id": str(uuid.uuid4()),
            "user_id": "user-123",
            "summary": "Your mood consistently drops on days with less than 6 hours of sleep.",
            "correlations": [
                {
                    "trigger": "lack of sleep",
                    "impact": "negative",
                    "confidence_score": 0.85,
                }
            ],
            "suggested_action": "Consider adjusting your evening routine tonight to prioritize rest.",
            "generated_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        }

    # -------------------------------------------------------------------
    # Row Converters (asyncpg Record → dict matching JSON contract)
    # -------------------------------------------------------------------
    @staticmethod
    def _row_to_entry(row) -> dict:
        """Convert an asyncpg Record to a journal entry dict."""
        created_at = row["created_at"]
        if hasattr(created_at, "isoformat"):
            created_at_str = created_at.isoformat().replace("+00:00", "Z")
        else:
            created_at_str = str(created_at)

        # tags/triggers come back as Python lists from asyncpg's jsonb handling
        tags = row["tags"]
        triggers = row["triggers"]
        if isinstance(tags, str):
            tags = json.loads(tags)
        if isinstance(triggers, str):
            triggers = json.loads(triggers)

        return {
            "id": str(row["id"]),
            "user_id": str(row["user_id"]),
            "raw_text": row["raw_text"],
            "sentiment_score": float(row["sentiment_score"]),
            "tags": tags,
            "triggers": triggers,
            "created_at": created_at_str,
        }

    @staticmethod
    def _row_to_insight(row) -> dict:
        """Convert an asyncpg Record to an insight dict."""
        generated_at = row["generated_at"]
        if hasattr(generated_at, "isoformat"):
            generated_at_str = generated_at.isoformat().replace("+00:00", "Z")
        else:
            generated_at_str = str(generated_at)

        correlations = row["correlations"]
        if isinstance(correlations, str):
            correlations = json.loads(correlations)

        return {
            "id": str(row["id"]),
            "user_id": str(row["user_id"]),
            "summary": row["summary"],
            "correlations": correlations,
            "suggested_action": row["suggested_action"],
            "generated_at": generated_at_str,
        }


# Initialize the data service at module level
data_service = DataService()


# ---------------------------------------------------------------------------
# API Endpoints
# ---------------------------------------------------------------------------
@app.post("/api/v1/entries", status_code=201)
async def submit_entry(request: EntryRequest):
    print(f"📥 [Backend] POST /api/v1/entries called with payload: {request.raw_text}")
    if not request.raw_text or not request.raw_text.strip():
        print("❌ [Backend] Validation failed: raw_text is empty")
        error = ErrorModel(
            error=ErrorDetail(
                code="VALIDATION_FAILED",
                message="The raw_text field cannot be empty.",
                details=None,
            )
        )
        return JSONResponse(status_code=400, content=error.model_dump())

    entry = await data_service.add_entry(request.raw_text)
    print("✅ [Backend] Added entry to DataService successfully")
    return entry


@app.get("/api/v1/entries")
async def get_entries(limit: int = 10, offset: int = 0):
    print(f"📥 [Backend] GET /api/v1/entries called with limit={limit}, offset={offset}")
    result = await data_service.get_entries(limit=limit, offset=offset)
    print(f"✅ [Backend] Returning {len(result.get('data', []))} entries")
    return result


@app.get("/api/v1/insights/current")
async def get_current_insight():
    print("📥 [Backend] GET /api/v1/insights/current called")
    insight = await data_service.get_current_insight()
    print("✅ [Backend] Returning current insight")
    return insight
