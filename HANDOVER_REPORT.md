# 🪞 MindMirror — Complete Project Handover Report

**Last Updated**: April 26, 2026, 05:58 AM PKT  
**Project**: MindMirror — AI-Driven Behavioral Journaling Platform  
**Context**: Hackathon rapid-build, multi-agent parallel development (4 branches merged)

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture & Tech Stack](#2-architecture--tech-stack)
3. [Repository Structure](#3-repository-structure)
4. [What Has Been Accomplished](#4-what-has-been-accomplished)
5. [Current System Status](#5-current-system-status)
6. [Known Issues & Blockers](#6-known-issues--blockers)
7. [What Remains To Be Done](#7-what-remains-to-be-done)
8. [How To Run the Project](#8-how-to-run-the-project)
9. [Key Design Decisions & Trade-offs](#9-key-design-decisions--trade-offs)
10. [Critical Files Reference](#10-critical-files-reference)

---

## 1. Project Overview

MindMirror is a **Personal Behavioral Intelligence System** that transforms unstructured journal entries into quantifiable insights. The user writes free-form text about their day, and the system:

1. **Extracts** sentiment scores, emotional tags, and behavioral triggers using Google Gemini LLM
2. **Stores** the enriched data in a PostgreSQL database
3. **Analyzes** patterns across 30 days of entries using correlation math (Kendall's Tau)
4. **Presents** actionable insights through an animated Flutter dashboard with trend charts

The system was developed by 4 isolated developer branches and merged into a single integrated application.

---

## 2. Architecture & Tech Stack

```
┌──────────────────────┐
│   Flutter Frontend   │  ← Dart/Flutter (Windows/Mobile)
│   (Provider + Dio)   │
└──────────┬───────────┘
           │ HTTP (localhost:8001)
           ▼
┌──────────────────────┐
│   FastAPI Backend     │  ← Python 3.10 (Uvicorn)
│   (Instructor + LLM) │
└──────────┬───────────┘
           │ asyncpg (port 5432)
           ▼
┌──────────────────────┐
│   PostgreSQL 15.1    │  ← Supabase Postgres Docker image
│   (JSONB columns)    │
└──────────────────────┘
```

| Layer | Technology | Key Libraries |
|---|---|---|
| **Frontend** | Flutter 3.39.0-0.1.pre (beta) | `provider`, `dio`, `intl`, `CustomPainter` charts |
| **Backend** | Python 3.10 + FastAPI | `instructor`, `google-genai`, `asyncpg`, `pydantic` |
| **Database** | PostgreSQL 15.1 (Supabase) | JSONB columns, B-tree composite indexes |
| **Analytics** | Python 3.10 | `scipy` (Kendall's Tau), custom seeder |
| **Infra** | Docker Compose | 3 services: backend, supabase-db, adminer |

---

## 3. Repository Structure

```
jrlun/
├── .env                          # Environment variables (API keys, DB URL)
├── docker-compose.yml            # Orchestrates all 3 containers
│
├── frontend/                     # Flutter application
│   └── lib/
│       ├── main.dart             # Entry point with MultiProvider
│       ├── core/theme/
│       │   └── app_theme.dart    # Material 3 theme (purple palette)
│       ├── models/
│       │   ├── journal_entry.dart    # JournalEntry data model
│       │   └── insight_model.dart    # InsightModel data model
│       ├── services/
│       │   ├── api_config.dart       # Base URL config (localhost:8001)
│       │   ├── journal_service.dart  # Real Dio HTTP service
│       │   ├── insight_service.dart  # Real Dio HTTP service
│       │   ├── mock_journal_service.dart  # Mock fallback
│       │   └── mock_insight_service.dart  # Mock fallback
│       ├── controllers/
│       │   ├── journal_provider.dart     # State management (entries)
│       │   └── insight_provider.dart     # State management (insights)
│       └── modules/dashboard/
│           ├── screens/
│           │   └── dashboard_screen.dart  # Main dashboard UI
│           └── widgets/
│               ├── insight_card.dart          # Hero AI insight card
│               ├── sentiment_chart.dart       # 30-day trend (CustomPainter)
│               ├── journal_input_field.dart   # Free-text entry input
│               └── historical_entries_feed.dart  # Past entries list
│
├── backend/                      # FastAPI orchestration layer
│   ├── Dockerfile                # Container build instructions
│   ├── requirements.txt          # Python dependencies
│   ├── main.py                   # API endpoints + dual-mode DataService
│   ├── models.py                 # Pydantic schemas (JournalEntry, InsightModel, etc.)
│   └── db.py                     # asyncpg connection pool management
│
├── infrastructure/               # Database schema & config
│   ├── migrations/
│   │   ├── 001_initial_schema.sql    # Tables + indexes (hardened)
│   │   ├── 002_seed_data.sql         # 3 sample entries (original seed)
│   │   └── 003_seed_synthetic.sql    # 30-day synthetic dataset + insight
│   └── docker-compose.yml            # Infrastructure-only compose (legacy)
│
├── analytics/                    # Data generation & correlation engine
│   ├── generate_synthetic_month.py   # 30-day synthetic data generator
│   ├── correlation_engine.py         # Kendall's Tau correlation analysis
│   ├── synthetic_data.json           # Generated 30-day dataset
│   ├── current_insight.json          # Pre-computed insight
│   └── test_contract.py              # Schema validation tests
│
└── docs/                         # Documentation
    ├── JSON_CONTRACT.md              # The single source of truth for all APIs
    ├── POST_MERGE_ROADMAP.md         # Integration roadmap (phases 1-5)
    ├── FRONTEND_SESSION_REPORT.md    # Frontend branch session report
    └── TEAM_HANDOFF_PROMPTS.md       # Team handoff context
```

---

## 4. What Has Been Accomplished

### Phase 1: Frontend ↔ Backend Connection ✅

| Item | Status | Details |
|---|---|---|
| Real HTTP services | ✅ Done | `journal_service.dart` and `insight_service.dart` replace mocks using Dio |
| Providers updated | ✅ Done | `JournalProvider` and `InsightProvider` accept injectable services |
| Mock fallback preserved | ✅ Done | Uncomment 2 lines in `main.dart` to swap back to mocks |
| API config centralized | ✅ Done | `api_config.dart` → `http://localhost:8001` |
| Error handling | ✅ Done | Standard error format parsed from JSON contract |

### Phase 2: Backend LLM Integration ✅

| Item | Status | Details |
|---|---|---|
| Google Gemini SDK | ✅ Done | Upgraded from deprecated `google.generativeai` to `google-genai` |
| Structured extraction | ✅ Done | `instructor` library forces Gemini to return `SentimentExtraction` Pydantic model |
| Graceful degradation | ✅ Done | If LLM fails (429 rate limit, network), defaults to `sentiment_score: 0.0`, `tags: ["general"]` |
| Model used | ✅ Done | `gemini-1.5-flash` with `max_retries=3` |

### Phase 3: Analytics Data Pipeline ✅

| Item | Status | Details |
|---|---|---|
| Synthetic data generator | ✅ Done | `generate_synthetic_month.py` creates 30 days of realistic entries |
| Behavioral heuristics | ✅ Done | Sleep < 6h → -0.4 sentiment drop; gym tag → +0.3 boost |
| Correlation engine | ✅ Done | Kendall's Tau algorithm in `correlation_engine.py` |
| Pre-computed insight | ✅ Done | `current_insight.json` with 3 correlations (sleep: 0.91, academic: 0.59, exercise: 0.36) |
| Schema validation | ✅ Done | `test_contract.py` validates output matches `JSON_CONTRACT.md` |

### Phase 4: UI/UX Polish ✅

| Item | Status | Details |
|---|---|---|
| Shimmer loading skeletons | ✅ Done | Animated placeholder during network latency |
| Error fallback cards | ✅ Done | Retry button when backend is offline |
| Date parsing fix | ✅ Done | Handles malformed `+00:00Z` timestamps from analytics |
| Chart hover interaction | ✅ Done | `_indexFromX` using `RenderBox` for tap-to-inspect |
| Date formatting | ✅ Done | `intl` DateFormat for tooltips and feed |
| Sentiment chart | ✅ Done | Pure `CustomPainter` spline (Syncfusion removed due to Flutter beta incompatibility) |
| Material 3 theme | ✅ Done | Purple tonal palette per design system spec |

### Phase 5: Docker Infrastructure ✅

| Item | Status | Details |
|---|---|---|
| Docker Compose | ✅ Done | 3 services: backend (8001), supabase-db (5432), adminer (8080) |
| DB healthcheck | ✅ Done | Backend waits for Postgres via `depends_on` + `pg_isready` |
| SQL migrations | ✅ Done | Hardened — `pg_jsonschema` fails gracefully, tables always created |
| Synthetic data seeded | ✅ Done | 30 entries + 1 insight auto-loaded via `003_seed_synthetic.sql` |
| Backend DB wiring | ✅ Done | `asyncpg` pool, dual-mode (Postgres or JSON fallback) |
| Persistent volume | ✅ Done | `pgdata` volume survives container restarts |

---

## 5. Current System Status

### Containers (as of April 26, 2026)

| Container | Image | Status | Port |
|---|---|---|---|
| `supabase-db` | `supabase/postgres:15.1.0.147` | ✅ Healthy | `localhost:5432` |
| `mindmirror-backend` | `jrlun-backend` (custom) | ✅ Running (DATABASE mode) | `localhost:8001` |
| `adminer` | `adminer` | ✅ Running | `localhost:8080` |

### API Endpoints (Verified Working)

| Endpoint | Method | Status | Notes |
|---|---|---|---|
| `/api/v1/entries` | GET | ✅ 200 | Returns paginated entries from Postgres |
| `/api/v1/entries` | POST | ✅ 201 | Creates entry with LLM extraction (or fallback) |
| `/api/v1/insights/current` | GET | ✅ 200 | Returns latest insight from Postgres |

### Database Contents

| Table | Row Count | Notes |
|---|---|---|
| `journal_entries` | 33 | 30 synthetic + 3 original seed entries |
| `insights` | 2 | 1 synthetic + 1 original seed insight |

---

## 6. Known Issues & Blockers

### 🔴 Critical: Gemini API Rate Limiting (429)

- **What**: The Google Gemini API key hits `429 RESOURCE_EXHAUSTED (limit: 0)` when submitting new journal entries
- **Why**: The Google Cloud project backing the API key does not have a billing account linked. Google now requires billing even for the free tier.
- **Impact**: New entries get saved with fallback values (`sentiment_score: 0.0`, `tags: ["general"]`) instead of real AI extraction
- **Workaround in place**: The backend catches the error gracefully — the app doesn't crash
- **Fix**: Go to [Google Cloud Console](https://console.cloud.google.com) → select the project → Billing → Link a billing account. The `limit: 0` restriction will lift immediately. No code changes needed.

### 🟡 Minor: `pg_jsonschema` Extension Unavailable

- **What**: The `supabase/postgres:15.1.0.147` Docker image doesn't have the `pg_jsonschema` extension available (requires `supabase_admin` role)
- **Impact**: JSON schema validation constraints are skipped. Data integrity relies on application-level validation (Pydantic models) instead of database-level constraints.
- **Workaround in place**: Migration wrapped in `DO $$ ... EXCEPTION` block — tables are created successfully without the constraints
- **Fix**: Use the full Supabase self-hosted stack (which includes the admin role) or validate at the application layer (already done via Pydantic)

### 🟡 Minor: Flutter Beta Version Lock

- **What**: Frontend built on Flutter `3.39.0-0.1.pre` (beta channel)
- **Impact**: If running on Flutter stable, you may need to adjust:
  - `CardThemeData` → `CardTheme`
  - `.withValues(alpha:)` → `.withOpacity()`
  - `surfaceContainerHighest` → `surfaceVariant`
- **Fix**: Run `flutter channel beta && flutter upgrade` or manually adjust the 3 API calls in `app_theme.dart`

---

## 7. What Remains To Be Done

### High Priority (For Demo)

| # | Task | Effort | Details |
|---|---|---|---|
| 1 | **Enable Gemini API billing** | 5 min | Link billing account in Google Cloud Console. Zero code changes. |
| 2 | **Test real LLM extraction** | 10 min | Submit a journal entry from the Flutter app, verify tags/triggers/sentiment are real (not fallback). |
| 3 | **Run Flutter frontend against Docker** | 5 min | `flutter run` — should connect to `localhost:8001` automatically. Verify the 30-day chart renders. |
| 4 | **Record the demo** | 30 min | Walk through: write entry → see AI extraction → view trend chart → read insight card. |

### Medium Priority (Polish)

| # | Task | Effort | Details |
|---|---|---|---|
| 5 | **Real-time insight regeneration** | 2 hrs | Currently the insight is pre-computed. Add a backend endpoint that re-runs `correlation_engine.py` against the DB and updates the `insights` table when new entries are added. |
| 6 | **Multi-user support** | 1 hr | Currently hardcoded to `user_id: 4e3c9a57-...`. Add user auth (Supabase Auth) and filter queries by authenticated user. |
| 7 | **Insight card auto-refresh** | 30 min | Add a periodic timer or pull-to-refresh that re-fetches the insight every 60s so the `AnimatedSwitcher` cross-fade fires during the demo. |
| 8 | **Pagination in UI** | 30 min | Frontend currently fetches first 10 entries. Add "Load More" button using the `has_more` meta field. |

### Low Priority (Post-Hackathon)

| # | Task | Effort | Details |
|---|---|---|---|
| 9 | Dark mode testing | 30 min | Theme is defined but may need visual QA |
| 10 | Supabase Auth integration | 2 hrs | Replace hardcoded user_id with real JWT-based auth |
| 11 | Flutter Web build | 1 hr | Deploy frontend as a static web app (currently Windows-only) |
| 12 | CI/CD pipeline | 2 hrs | GitHub Actions for automated testing and Docker image builds |
| 13 | Production Supabase | 1 hr | Replace local Docker Supabase with Supabase Cloud for persistent hosting |

---

## 8. How To Run the Project

### Prerequisites

- **Docker Desktop** (installed and running)
- **Flutter SDK** (3.39.0-0.1.pre beta, or adjust `app_theme.dart` for stable)
- **Google API Key** with billing enabled (optional — app works without it using fallback values)

### Option A: Full Docker Stack (Recommended)

```powershell
# 1. Navigate to project root
cd c:\Users\u2023629\Documents\Hackathon\jrlun

# 2. Start all services (builds backend, starts Postgres, seeds data)
docker compose up --build -d

# 3. Verify everything is healthy
docker compose ps

# 4. Check backend connected to DB
docker logs mindmirror-backend 2>&1 | Select-Object -Last 5
# Should show: "[OK] Backend running in DATABASE mode (Postgres)"

# 5. Run the Flutter frontend
cd frontend
flutter run

# 6. (Optional) View database via Adminer
# Open http://localhost:8080 in browser
# Server: supabase-db | User: postgres | Password: postgres | DB: postgres
```

### Option B: Backend Only (No Docker, JSON Fallback)

```powershell
# Without DATABASE_URL set, backend falls back to JSON files
cd c:\Users\u2023629\Documents\Hackathon\jrlun
python -m uvicorn backend.main:app --host 0.0.0.0 --port 8001

# In another terminal
cd frontend
flutter run
```

### Stopping Everything

```powershell
docker compose down       # Stop containers (data persists in volume)
docker compose down -v    # Stop containers AND delete database volume
```

---

## 9. Key Design Decisions & Trade-offs

### Dual-Mode Backend
The backend's `DataService` checks for `DATABASE_URL` at startup. If present, all operations use `asyncpg` against Postgres. If absent, it loads `synthetic_data.json` into memory. This ensures the demo never breaks — even if Docker is down, the backend serves data.

### Mock-First Fallback in Frontend
The `main.dart` has commented-out lines to swap real services for mock services. During the demo, if the backend crashes, you can hot-restart with mocks in under 10 seconds.

### Hardened Migrations
The `pg_jsonschema` extension requires a specific Supabase admin role. Rather than failing the entire DB init, we wrapped the constraints in exception handlers. Tables and data are always created; JSON validation constraints are a bonus.

### CustomPainter Over Syncfusion
The sentiment chart was rewritten as a pure `CustomPainter` because `syncfusion_flutter_charts 24.x` is incompatible with Flutter 3.39 beta. This eliminated an external dependency at the cost of more manual drawing code.

### Single User ID
For hackathon speed, all entries use a hardcoded `user_id`. This is the obvious first thing to change for a production system.

---

## 10. Critical Files Reference

### The JSON Contract (Source of Truth)
**File**: [`docs/JSON_CONTRACT.md`](docs/JSON_CONTRACT.md)  
Defines the exact shape of `JournalEntry`, `InsightModel`, error responses, and all API endpoints. Every branch was built against this contract. **Do not change field names without updating all 4 layers.**

### Environment Variables
**File**: [`.env`](.env)

| Variable | Value | Used By |
|---|---|---|
| `GOOGLE_API_KEY` | `AIzaSy...` | Backend (Gemini LLM extraction) |
| `DATABASE_URL` | `postgresql://postgres:postgres@supabase-db:5432/postgres` | Backend (asyncpg pool) |

### API Configuration
**File**: [`frontend/lib/services/api_config.dart`](frontend/lib/services/api_config.dart)

```dart
static const String baseUrl = 'http://localhost:8001';
static const String entriesPath = '/api/v1/entries';
static const String insightPath = '/api/v1/insights/current';
```

### Docker Compose Services

| Service | Container Name | Ports | Image |
|---|---|---|---|
| backend | `mindmirror-backend` | `8001:8000` | Custom (Python 3.10) |
| supabase-db | `supabase-db` | `5432:5432` | `supabase/postgres:15.1.0.147` |
| adminer | `adminer` | `8080:8080` | `adminer` (latest) |

---

*This report was generated on April 26, 2026. For the most up-to-date status, check `docker compose ps` and the backend logs.*
