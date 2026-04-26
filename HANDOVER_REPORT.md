# 🪞 MindMirror — Complete Technical Handover

**Last Updated**: April 26, 2026, 07:00 AM PKT  
**Status**: ✅ Fully operational end-to-end  
**LLM Provider**: Groq (Llama 3.3 70B) — real AI extraction confirmed working

---

## 1. What MindMirror Is

A **Personal Behavioral Intelligence System** built for a hackathon. Users write free-form journal entries; the system uses AI to extract sentiment, tags, and triggers, then visualizes patterns over time.

**Data flow:**
```
User types journal entry
    → Flutter frontend sends POST to FastAPI
        → Groq LLM extracts sentiment_score, tags, triggers (structured JSON via instructor)
            → Enriched entry stored in PostgreSQL
                → Dashboard renders 30-day trend chart + AI insight card
```

---

## 2. Architecture

```
┌─────────────────────────┐
│   Flutter Frontend       │  Port: Chrome (Web) or Windows native
│   Provider + Dio HTTP    │  Config: api_config.dart → localhost:8001
└───────────┬─────────────┘
            │ HTTP REST
            ▼
┌─────────────────────────┐
│   FastAPI Backend        │  Port: 8001 (host) → 8000 (container)
│   Groq + instructor      │  Dual-mode: Postgres OR JSON fallback
└───────────┬─────────────┘
            │ asyncpg
            ▼
┌─────────────────────────┐
│   PostgreSQL 15.1        │  Port: 5432
│   Supabase Docker image  │  Tables: journal_entries, insights
└─────────────────────────┘
```

**Docker containers** (all healthy):

| Container | Image | Port | Role |
|---|---|---|---|
| `mindmirror-backend` | Custom Python 3.10 | 8001 | API + LLM orchestration |
| `supabase-db` | supabase/postgres:15.1.0.147 | 5432 | PostgreSQL database |
| `adminer` | adminer | 8080 | DB admin UI |

---

## 3. What Was Built — Detailed Breakdown

### 3.1 Frontend (Flutter)

**Tech**: Flutter 3.39.0-0.1.pre (beta), Provider for state, Dio for HTTP, CustomPainter for charts.

#### File-by-file:

| File | Purpose | Key Details |
|---|---|---|
| `main.dart` | App entry point | `MultiProvider` injects `JournalProvider` + `InsightProvider`. Commented lines allow instant swap to mock services. |
| `app_theme.dart` | Material 3 theme | Purple tonal palette (`#800080` primary, `#E6E6FA` insight container, `#F3E5F5` surface). Light + dark themes defined. |
| `api_config.dart` | API routing | `baseUrl: http://localhost:8001`, paths: `/api/v1/entries`, `/api/v1/insights/current` |
| `journal_entry.dart` | Data model | Parses JSON from backend. Handles malformed `+00:00Z` timestamps. Fields: id, user_id, raw_text, sentiment_score, tags, triggers, created_at. |
| `insight_model.dart` | Data model | Parses insight JSON. Fields: id, user_id, summary, correlations[], suggested_action, generated_at. |
| `journal_service.dart` | HTTP service | Dio-backed. `getHistoricalEntries(limit, offset)` and `submitEntry(rawText)`. Parses standard error format. |
| `insight_service.dart` | HTTP service | Dio-backed. `getCurrentInsight()`. |
| `mock_journal_service.dart` | Mock fallback | 5 hardcoded entries for offline demo. |
| `mock_insight_service.dart` | Mock fallback | 1 hardcoded insight for offline demo. |
| `journal_provider.dart` | State mgmt | `fetchEntries()`, `addEntry(text)`, `clearError()`. Exposes `entries`, `isLoading`, `error`. |
| `insight_provider.dart` | State mgmt | `fetchCurrentInsight()`. Exposes `currentInsight`, `isLoading`, `error`. |
| `dashboard_screen.dart` | Main UI | Composes all widgets. Pull-to-refresh. 60s auto-refresh timer for insight. Shimmer loaders during loading. Error fallback cards with retry buttons. |
| `insight_card.dart` | Hero widget | `AnimatedSwitcher` with 300ms cross-fade. Uses `primaryContainer` color. Dynamically bolds trigger words in summary via `RichText`. Shows `auto_awesome` icon + suggested action. |
| `sentiment_chart.dart` | Trend chart | Pure `CustomPainter` (no Syncfusion). Animated spline line with gradient fill. Horizontal gridlines at -1, -0.5, 0, 0.5, 1. Hover/tap interaction shows date + score tooltip. 900ms draw animation on load. |
| `journal_input_field.dart` | Text input | Minimalist multiline input. Submit button in primary color. |
| `historical_entries_feed.dart` | Entry list | Scrollable list of past entries with sentiment chips and date formatting via `intl`. |

#### How the frontend connects to the backend:

1. `DashboardScreen.initState()` calls `fetchEntries()` and `fetchCurrentInsight()`
2. Providers call their respective services (`JournalService`, `InsightService`)
3. Services use Dio to make HTTP requests to `http://localhost:8001/api/v1/...`
4. Responses are parsed into `JournalEntry` / `InsightModel` dart objects
5. Providers call `notifyListeners()` → UI rebuilds via `Consumer` widgets

#### Mock fallback mechanism:

In `main.dart`, swap these two lines:
```dart
// Real (default):
ChangeNotifierProvider(create: (_) => JournalProvider()),
// Mock (offline):
ChangeNotifierProvider(create: (_) => JournalProvider(service: MockJournalService())),
```

---

### 3.2 Backend (FastAPI + Groq)

**Tech**: Python 3.10, FastAPI, Groq SDK, instructor (structured LLM output), asyncpg (Postgres driver), Pydantic.

#### Core Design: Dual-Mode DataService

The `DataService` class in `main.py` operates in two modes:

**DATABASE mode** (when `DATABASE_URL` env var is set):
- All reads → `SELECT` from Postgres via asyncpg
- All writes → `INSERT` into Postgres via asyncpg
- Activated automatically when Docker stack is running

**JSON-FILE mode** (when `DATABASE_URL` is not set):
- Loads `analytics/synthetic_data.json` into memory on startup
- New entries appended to in-memory list
- Useful for running backend standalone without Docker

#### LLM Extraction Pipeline:

```python
# 1. User submits: "I am exhausted from studying all night"
# 2. Backend creates Groq client with instructor wrapper
groq_client = Groq(api_key=os.environ.get("GROQ_API_KEY"))
client = instructor.from_groq(groq_client)

# 3. Calls Llama 3.3 70B with structured output schema
extracted = client.chat.completions.create(
    model="llama-3.3-70b-versatile",
    response_model=SentimentExtraction,  # Pydantic model
    messages=[system_prompt, user_text],
    max_retries=3
)
# 4. Returns: sentiment_score=-0.8, tags=["exhausted","studying"], triggers=["lack of sleep"]
# 5. Clamped to [-1.0, 1.0], stored in Postgres
```

**Fallback**: If Groq fails for any reason, returns `(0.0, ["general"], [])` — the app never crashes.

#### API Endpoints:

| Endpoint | Method | Request | Response | Status |
|---|---|---|---|---|
| `/api/v1/entries` | GET | `?limit=10&offset=0` | `{data: [JournalEntry[]], meta: {total, has_more}}` | ✅ Working |
| `/api/v1/entries` | POST | `{"raw_text": "..."}` | Single enriched `JournalEntry` | ✅ Working (real AI) |
| `/api/v1/insights/current` | GET | — | Single `InsightModel` | ✅ Working |

#### File-by-file:

| File | Purpose |
|---|---|
| `main.py` | FastAPI app, CORS, DataService (dual-mode), 3 API endpoints, row converters |
| `models.py` | Pydantic schemas: JournalEntry, InsightModel, Correlation, EntryRequest, ErrorModel |
| `db.py` | asyncpg connection pool lifecycle (init_db, close_db, get_pool) |
| `Dockerfile` | Python 3.10 slim, installs deps, copies backend + analytics, runs uvicorn |
| `requirements.txt` | fastapi, uvicorn, pydantic, instructor, groq, asyncpg |

---

### 3.3 Database (PostgreSQL)

**Image**: `supabase/postgres:15.1.0.147`

#### Schema (`001_initial_schema.sql`):

```sql
-- journal_entries
id             UUID PRIMARY KEY (auto-generated)
user_id        UUID NOT NULL
raw_text       TEXT NOT NULL
sentiment_score NUMERIC(3,2) CHECK (-1.0 to 1.0)
tags           JSONB DEFAULT '[]'
triggers       JSONB DEFAULT '[]'
created_at     TIMESTAMPTZ DEFAULT NOW()

-- insights
id              UUID PRIMARY KEY
user_id         UUID NOT NULL
summary         TEXT NOT NULL
correlations    JSONB DEFAULT '[]'
suggested_action TEXT NOT NULL
generated_at    TIMESTAMPTZ DEFAULT NOW()
```

**Indexes**: Composite B-tree on `(user_id, created_at DESC)` for both tables.

**pg_jsonschema**: The migration attempts to add JSON schema validation constraints but wraps them in an exception handler. On this Docker image they're skipped (missing `supabase_admin` role) — data integrity is enforced at the application layer via Pydantic instead.

#### Seed Data:

| Migration | Content |
|---|---|
| `002_seed_data.sql` | 3 sample entries + 1 insight (original infrastructure branch) |
| `003_seed_synthetic.sql` | 30 entries spanning March 26 – April 24, 2026 + 1 pre-computed insight with 3 correlations |

**Total in DB**: 33+ journal entries, 2 insights (plus any entries submitted during testing).

---

### 3.4 Analytics Pipeline

**Tech**: Python 3.10, scipy (Kendall's Tau).

| File | Purpose |
|---|---|
| `generate_synthetic_month.py` | Generates 30 days of realistic journal entries with injected behavioral heuristics |
| `correlation_engine.py` | Runs Kendall's Tau correlation analysis across the dataset |
| `synthetic_data.json` | Output: 30 entries with realistic sentiment patterns |
| `current_insight.json` | Output: Pre-computed insight with 3 correlations |
| `test_contract.py` | Validates output matches `docs/JSON_CONTRACT.md` schema |

**Injected Heuristics**:
- Sleep < 6 hours → sentiment drops by -0.4
- Tags include "gym" → sentiment boosts by +0.3
- Weekend days → slight positive boost

**Pre-computed correlations**:
- "lack of sleep" → negative impact, confidence: 0.91
- "academic pressure" → negative impact, confidence: 0.59
- "exercise" → positive impact, confidence: 0.36

---

### 3.5 Docker Infrastructure

**File**: `docker-compose.yml` at project root.

Key configurations:
- Backend maps `8001:8000` (matches Flutter's `api_config.dart`)
- Backend `depends_on` supabase-db with healthcheck (`pg_isready`)
- Backend restarts on failure
- Migrations auto-run via `/docker-entrypoint-initdb.d` mount
- Persistent `pgdata` volume survives container restarts
- `GROQ_API_KEY` and `DATABASE_URL` passed from `.env`

---

## 4. Integration History (Chronological)

| Session | What Was Done |
|---|---|
| **Analytics (Session 1)** | Generated 30-day synthetic data with behavioral heuristics. Built correlation engine. Validated against JSON contract. |
| **Integration (Session 2)** | Merged all 4 branches. Wired Flutter frontend to FastAPI backend via Dio. Replaced mock services. Fixed date parsing bugs. Built shimmer loaders and error states. Integrated Google Gemini with instructor for structured extraction. Hit 429 rate limit blocker. Prepared Docker architecture. |
| **Docker (Session 3, current)** | Fixed docker-compose (ports, healthcheck, depends_on). Hardened SQL migrations. Created `db.py` asyncpg module. Refactored `main.py` to dual-mode (DB + JSON fallback). Converted synthetic data to SQL seed. Spun up full Docker stack — all 3 containers healthy. Switched from Gemini to Groq (Llama 3.3 70B) — AI extraction now fully working. Verified end-to-end: Flutter → FastAPI → Groq → Postgres → Flutter. |

---

## 5. What Remains

### For the Demo (< 1 hour)

| Task | Effort | Notes |
|---|---|---|
| UI touchups | 30 min | Visual polish for the hackathon pitch |
| Record demo video | 15 min | Write entry → see AI tags → view chart → read insight |

### Future Improvements

| Task | Effort | Notes |
|---|---|---|
| Real-time insight regeneration | 2 hrs | Re-run correlation engine when new entries are added |
| Multi-user auth | 1-2 hrs | Supabase Auth, filter by authenticated user_id |
| Pagination UI | 30 min | "Load More" button using `has_more` meta field |
| Dark mode QA | 30 min | Theme is defined but needs visual testing |
| Flutter Web production build | 1 hr | `flutter build web` for static hosting |

---

## 6. How to Run

```powershell
# Start everything
cd c:\Users\u2023629\Documents\Hackathon\jrlun
docker compose up --build -d

# Verify
docker compose ps                    # All 3 containers should be "Up"
docker logs mindmirror-backend       # Should show "DATABASE mode (Postgres)"

# Run Flutter
cd frontend
flutter run -d chrome                # Web
flutter run -d windows               # Windows native

# Test API manually
Invoke-WebRequest -Uri "http://localhost:8001/api/v1/entries" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:8001/api/v1/entries" -Method POST -ContentType "application/json" -Body '{"raw_text":"Test entry"}' -UseBasicParsing

# View database
# Open http://localhost:8080 → Server: supabase-db, User: postgres, Pass: postgres

# Stop
docker compose down        # Keep data
docker compose down -v     # Delete data
```

---

## 7. Environment Variables (`.env`)

```
bhenchod api key nae daaltay docs mein
```

> ⚠️ `.env` is in `.gitignore` — will not be committed. Anyone cloning the repo needs to create their own.

---

## 8. Key Design Decisions

| Decision | Rationale |
|---|---|
| **Dual-mode backend** | If Docker is down, backend still serves JSON data. Demo never breaks. |
| **Mock service fallback** | 2-line swap in `main.dart` returns to hardcoded data. Emergency demo recovery. |
| **Groq over Gemini** | Gemini required billing setup (429 blocker). Groq's free tier has generous limits and sub-second latency. |
| **CustomPainter over Syncfusion** | Syncfusion 24.x incompatible with Flutter 3.39 beta. Custom chart eliminated the dependency. |
| **instructor for structured output** | Forces LLM to return exact Pydantic schema. No parsing or regex needed. Retries on malformed output. |
| **Hardened migrations** | pg_jsonschema wrapped in exception handler. Tables always created even if extension unavailable. |
| **Single user_id** | Hardcoded for hackathon speed. First thing to change for production. |
