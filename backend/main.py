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
        Create a new entry with real sentiment extraction via Google Gemini.
        """
        from google import genai
        import instructor
        from pydantic import BaseModel, Field

        class SentimentExtraction(BaseModel):
            sentiment_score: float = Field(..., description="Sentiment score from -1.0 (very negative) to 1.0 (very positive)")
            tags: List[str] = Field(..., description="List of emotion or situational tags (e.g., 'tired', 'gym', 'stressed')")
            triggers: List[str] = Field(..., description="List of specific triggers causing the emotion (e.g., 'lack of sleep', 'academic pressure')")

        api_key = os.environ.get("GOOGLE_API_KEY", "AIzaSyApC3hl9KANowmBplAcvEQ-WFkjX-6K2Ek")
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
            sentiment = extracted.sentiment_score
            tags = extracted.tags
            triggers = extracted.triggers
        except Exception as e:
            print(f"[ERROR] Gemini extraction failed: {e}")
            # Fallback values if extraction fails
            sentiment = 0.0
            tags = ["general"]
            triggers = []

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

    entry = data_service.add_entry(request.raw_text)
    print("✅ [Backend] Added entry to DataService successfully")
    return entry


@app.get("/api/v1/entries")
async def get_entries(limit: int = 10, offset: int = 0):
    print(f"📥 [Backend] GET /api/v1/entries called with limit={limit}, offset={offset}")
    result = data_service.get_entries(limit=limit, offset=offset)
    print(f"✅ [Backend] Returning {len(result.get('data', []))} entries")
    return result


@app.get("/api/v1/insights/current")
async def get_current_insight():
    print("📥 [Backend] GET /api/v1/insights/current called")
    insight = data_service.get_current_insight()
    print("✅ [Backend] Returning current insight")
    return insight
