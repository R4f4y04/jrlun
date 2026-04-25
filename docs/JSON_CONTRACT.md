# 🤝 MindMirror JSON Contract (The Mock-First Law)

This document is the **single source of truth** for all inter-branch communication. 
- **Frontend (Rafay)** will mock these exact structures while the backend is being built.
- **Backend (Dar)** will enforce these strict schemas via Pydantic.
- **Infrastructure (Talal)** will ensure the database can store the JSONB structures.
- **Analytics (Shayan)** will generate synthetic data matching these keys.

---

## 1. Data Models

### 1.1 Journal Entry Model (`JournalEntry`)
Represents a single user reflection, enriched by the LLM Orchestration layer.

```json
{
  "id": "uuid-string",
  "user_id": "uuid-string",
  "raw_text": "I'm exhausted from studying. Didn't sleep much.",
  "sentiment_score": -0.4, 
  "tags": ["studying", "tired"], 
  "triggers": ["lack of sleep", "academic pressure"],
  "created_at": "2026-04-25T14:30:00Z"
}
```
*Note: `sentiment_score` must be a float between `-1.0` (extremely negative) and `1.0` (extremely positive).*

### 1.2 Insight Model (`InsightModel`)
Represents the AI-generated behavioral correlation displayed on the UI's Hero Insight Card.

```json
{
  "id": "uuid-string",
  "user_id": "uuid-string",
  "summary": "Your mood consistently drops on days with less than 6 hours of sleep.",
  "correlations": [
    {
      "trigger": "lack of sleep",
      "impact": "negative",
      "confidence_score": 0.85
    }
  ],
  "suggested_action": "Consider adjusting your evening routine tonight to prioritize rest.",
  "generated_at": "2026-04-25T15:00:00Z"
}
```

---

## 2. API Endpoints

### 2.1 Submit New Entry
`POST /api/v1/entries`
- **Request Body:**
```json
{
  "raw_text": "I'm exhausted from studying. Didn't sleep much."
}
```
- **Response (201 Created):** Returns the enriched `JournalEntry` model.

### 2.2 Get Historical Entries
`GET /api/v1/entries?limit=10&offset=0`
- **Response (200 OK):**
```json
{
  "data": [
    // Array of JournalEntry models
  ],
  "meta": {
    "total": 45,
    "has_more": true
  }
}
```

### 2.3 Get Current Insight
`GET /api/v1/insights/current`
- **Response (200 OK):** Returns the most recent/relevant `InsightModel` for the dashboard Insight Card.

---

## 3. Standard Error Format
All 4xx and 5xx errors must return this exact structure to ensure the Flutter UI handles failures gracefully without crashing.

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "The raw_text field cannot be empty.",
    "details": null
  }
}
```
