from pydantic import BaseModel, Field
from typing import List, Optional, Any
from datetime import datetime

class JournalEntry(BaseModel):
    id: str = Field(..., description="uuid-string")
    user_id: str = Field(..., description="uuid-string")
    raw_text: str
    sentiment_score: float = Field(..., ge=-1.0, le=1.0)
    tags: List[str]
    triggers: List[str]
    created_at: datetime

class Correlation(BaseModel):
    trigger: str
    impact: str
    confidence_score: float

class InsightModel(BaseModel):
    id: str = Field(..., description="uuid-string")
    user_id: str = Field(..., description="uuid-string")
    summary: str
    correlations: List[Correlation]
    suggested_action: str
    generated_at: datetime

class ErrorDetail(BaseModel):
    code: str
    message: str
    details: Optional[Any] = None

class ErrorModel(BaseModel):
    error: ErrorDetail

class EntryRequest(BaseModel):
    raw_text: str
