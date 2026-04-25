import uuid
from datetime import datetime, timezone
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List, Optional

# Assuming models.py is in the same directory
from models import JournalEntry, InsightModel, Correlation, EntryRequest, ErrorModel, ErrorDetail

app = FastAPI(title="MindMirror API Orchestration")

# Mock Service
class MockOrchestrationService:
    def process_entry(self, raw_text: str) -> JournalEntry:
        """
        In production, this would use `instructor` to coerce LLM output 
        into the JournalEntry schema, e.g.,
        
        client = instructor.from_openai(OpenAI())
        entry = client.chat.completions.create(
            model="gpt-4o-mini",
            response_model=JournalEntry,
            messages=[{"role": "user", "content": raw_text}],
            max_retries=3
        )
        """
        # Returning a mocked instance for now
        return JournalEntry(
            id=str(uuid.uuid4()),
            user_id="mock-user-123",
            raw_text=raw_text,
            sentiment_score=-0.4 if "exhausted" in raw_text.lower() else 0.5,
            tags=["studying", "tired"] if "exhausted" in raw_text.lower() else ["general"],
            triggers=["lack of sleep", "academic pressure"] if "exhausted" in raw_text.lower() else [],
            created_at=datetime.now(timezone.utc)
        )

    def get_current_insight(self) -> InsightModel:
        return InsightModel(
            id=str(uuid.uuid4()),
            user_id="mock-user-123",
            summary="Your mood consistently drops on days with less than 6 hours of sleep.",
            correlations=[
                Correlation(
                    trigger="lack of sleep",
                    impact="negative",
                    confidence_score=0.85
                )
            ],
            suggested_action="Consider adjusting your evening routine tonight to prioritize rest.",
            generated_at=datetime.now(timezone.utc)
        )

mock_service = MockOrchestrationService()

@app.post("/api/v1/entries", response_model=JournalEntry, status_code=201)
async def submit_entry(request: EntryRequest):
    if not request.raw_text or not request.raw_text.strip():
        # Custom error format as per JSON_CONTRACT.md
        error = ErrorModel(error=ErrorDetail(
            code="VALIDATION_FAILED",
            message="The raw_text field cannot be empty.",
            details=None
        ))
        return JSONResponse(status_code=400, content=error.model_dump())

    # Process through mock service (acting as LLM Orchestration Layer)
    entry = mock_service.process_entry(request.raw_text)
    return entry

@app.get("/api/v1/entries")
async def get_entries(limit: int = 10, offset: int = 0):
    entry = mock_service.process_entry("I'm exhausted from studying. Didn't sleep much.")
    return {
        "data": [entry],
        "meta": {
            "total": 1,
            "has_more": False
        }
    }

@app.get("/api/v1/insights/current", response_model=InsightModel)
async def get_current_insight():
    insight = mock_service.get_current_insight()
    return insight
