import uuid
import json
import os
from datetime import datetime, timezone
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional

try:
    from models import JournalEntry, InsightModel, Correlation, EntryRequest, ErrorModel, ErrorDetail
except ModuleNotFoundError:
    from backend.models import JournalEntry, InsightModel, Correlation, EntryRequest, ErrorModel, ErrorDetail

app = FastAPI(title="MindMirror API Orchestration")

# CORS — allow Flutter frontend to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------------------------------------------------------------------------
# Data Service: loads analytics JSON files into memory
# ---------------------------------------------------------------------------
class DataService:
    """
    In-memory data store that loads the pre-generated analytics data.
    When a real database (Supabase) is available, this class would be
    replaced with actual DB queries.
    """

    def __init__(self):
        self._entries: List[dict] = []
        self._insight: Optional[dict] = None
        self._load_data()

    def _load_data(self):
        """Load synthetic data and insight from the analytics directory."""
        # Resolve paths relative to the project root
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

        # Load synthetic journal entries
        entries_path = os.path.join(base_dir, "analytics", "synthetic_data.json")
        if os.path.exists(entries_path):
            with open(entries_path, "r") as f:
                data = json.load(f)
                self._entries = data.get("data", [])
            print(f"[OK] Loaded {len(self._entries)} journal entries from {entries_path}")
        else:
            print(f"[WARN] No synthetic data found at {entries_path}, using empty dataset")

        # Load pre-computed insight
        insight_path = os.path.join(base_dir, "analytics", "current_insight.json")
        if os.path.exists(insight_path):
            with open(insight_path, "r") as f:
                self._insight = json.load(f)
            print(f"[OK] Loaded insight from {insight_path}")
        else:
            print(f"[WARN] No insight found at {insight_path}, using fallback")

    def get_entries(self, limit: int = 10, offset: int = 0) -> dict:
        """Return paginated entries sorted by created_at descending."""
        # Sort by created_at descending (newest first)
        sorted_entries = sorted(
            self._entries,
            key=lambda e: e.get("created_at", ""),
            reverse=True,
        )
        total = len(sorted_entries)
        page = sorted_entries[offset : offset + limit]
        return {
            "data": page,
            "meta": {
                "total": total,
                "has_more": (offset + limit) < total,
            },
        }

    def add_entry(self, raw_text: str) -> dict:
        """
        Create a new entry with mock sentiment extraction.

        In production, this would use Google Gemini via `instructor`:
            import google.generativeai as genai
            genai.configure(api_key=os.environ["GOOGLE_API_KEY"])
            model = genai.GenerativeModel("gemini-2.0-flash")
            client = instructor.from_gemini(model, mode=instructor.Mode.GEMINI_JSON)
            entry = client.chat.completions.create(
                response_model=JournalEntry,
                messages=[{"role": "user", "content": raw_text}],
                max_retries=3
            )
        """
        # Simple keyword-based mock extraction
        text_lower = raw_text.lower()
        sentiment = 0.0
        tags = []
        triggers = []

        # Sleep-related
        if any(w in text_lower for w in ["tired", "exhausted", "sleep", "insomnia", "fatigue"]):
            sentiment -= 0.4
            tags.extend(["tired", "fatigue"])
            triggers.append("lack of sleep")

        # Exercise-related
        if any(w in text_lower for w in ["gym", "workout", "exercise", "run", "jog"]):
            sentiment += 0.4
            tags.append("gym")
            triggers.append("exercise")

        # Stress-related
        if any(w in text_lower for w in ["stress", "anxious", "worried", "deadline", "pressure", "exam"]):
            sentiment -= 0.3
            tags.extend(["stressed"])
            triggers.append("academic pressure")

        # Positive keywords
        if any(w in text_lower for w in ["happy", "great", "wonderful", "amazing", "good", "energized"]):
            sentiment += 0.3
            tags.append("happy")

        # Default fallback
        if not tags:
            tags = ["general"]
            sentiment = 0.1

        sentiment = max(-1.0, min(1.0, sentiment))

        entry = {
            "id": str(uuid.uuid4()),
            "user_id": self._entries[0]["user_id"] if self._entries else "user-123",
            "raw_text": raw_text,
            "sentiment_score": round(sentiment, 2),
            "tags": list(set(tags)),
            "triggers": list(set(triggers)),
            "created_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        }

        # Prepend to in-memory store
        self._entries.insert(0, entry)
        return entry

    def get_current_insight(self) -> dict:
        """Return the pre-computed insight or a fallback."""
        if self._insight:
            return self._insight
        # Fallback insight
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


# Initialize the data service at startup
data_service = DataService()


# ---------------------------------------------------------------------------
# API Endpoints
# ---------------------------------------------------------------------------
@app.post("/api/v1/entries", status_code=201)
async def submit_entry(request: EntryRequest):
    if not request.raw_text or not request.raw_text.strip():
        error = ErrorModel(
            error=ErrorDetail(
                code="VALIDATION_FAILED",
                message="The raw_text field cannot be empty.",
                details=None,
            )
        )
        return JSONResponse(status_code=400, content=error.model_dump())

    entry = data_service.add_entry(request.raw_text)
    return entry


@app.get("/api/v1/entries")
async def get_entries(limit: int = 10, offset: int = 0):
    return data_service.get_entries(limit=limit, offset=offset)


@app.get("/api/v1/insights/current")
async def get_current_insight():
    return data_service.get_current_insight()
