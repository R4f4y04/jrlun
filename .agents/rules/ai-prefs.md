---
trigger: always_on
---

Here is the updated master global instruction file. It has been rebuilt to explicitly define the relationship between this global document and the branch-specific files, and it introduces a highly specialized context-logging protocol for each of the four domains.

Save this as docs/AI_GLOBAL_RULES.md.

🧠 AI Developer Master Instructions: MindMirror System
🎯 Project Overview & The Multi-Agent Environment
MindMirror is an AI-driven behavioral journaling platform designed for a rapid hackathon deployment.

CRITICAL CONTEXT FOR AI AGENTS: You are operating in a multi-agent, highly parallelized environment. There are four distinct human developers (Rafay, Dar, Talal, Shayan), each utilizing their own AI coding agent in complete isolation. You do NOT have access to the live code of the other branches. You must rely entirely on the mock services and the established docs/JSON_CONTRACT.md.

🏗️ Branch Hierarchy & Local Instructions
This document serves as the Global Baseline. However, you are operating within a specific domain. Upon initialization, you must read your branch-specific instruction file. The branch rules provide your tech stack, architectural patterns, and localized constraints.

Branch Owner	Domain	Local Instruction File (Read Immediately)
Rafay	Frontend (Flutter UI & State)	frontend/.ai_branch_rules.md
Dar	Orchestration (FastAPI & LLM)	backend/.ai_branch_rules.md
Talal	Infrastructure (Supabase & Docker)	infrastructure/.ai_branch_rules.md
Shayan	Analytics (Data Seeder & Math)	analytics/.ai_branch_rules.md
Rule of Precedence: If a directive in a branch-specific .ai_branch_rules.md file conflicts with this global document, the branch-specific rule wins for that specific domain.

📝 The Asymmetric Context Logging Protocol (MANDATORY)
Because the codebase will be developed in isolation and merged under extreme time constraints, standard git commit messages are insufficient. Every agent must maintain a .branch_context.md file in their respective root directory.

You must update this file after every significant generation. The logs are structured asymmetrically because each branch produces different dependencies.

1. Frontend Context Logging (frontend/.branch_context.md)
Focus: UI state, consumed interfaces, and mock dependencies.
When writing to the frontend log, use this format:

Markdown
- [YYYY-MM-DD] [Feature/Component Name]:
  - **Action**: Created `InsightCard` and `InsightController`.
  - **Local State**: Managed via Provider (`insight_provider.dart`).
  - **Mocks Used**: Relying on `MockInsightService` returning dummy `List<InsightModel>`.
  - **Integration Demand**: Waiting for backend `GET /api/v1/insights` to return exact structure defined in `JSON_CONTRACT.md`.
2. Orchestration Context Logging (backend/.branch_context.md)
Focus: API surface area, schema enforcement, and LLM prompt mechanics.
When writing to the backend log, use this format:

Markdown
- [YYYY-MM-DD] [Endpoint/Service]:
  - **Action**: Deployed `POST /api/v1/analyze-entry` route.
  - **Schema Enforcement**: Added `BehavioralExtraction` Pydantic model via `instructor`.
  - **LLM Config**: `gpt-4o-mini`, max_retries=3, strict JSON mode.
  - **Integration Demand**: Expecting Supabase DB to accept `jsonb` inserts at `supabase-db:5432`.
3. Infrastructure Context Logging (infrastructure/.branch_context.md)
Focus: Migrations, indexing, and internal network availability.
When writing to the infrastructure log, use this format:

Markdown
- [YYYY-MM-DD] [Database/Docker]:
  - **Action**: Generated migration `002_add_jsonb_behavior.sql`.
  - **Schema Note**: Added `tags` and `triggers` as `jsonb` with `pg_jsonschema` validation.
  - **Indexing**: Composite B-tree added for `user_id` + `created_at`.
  - **Network Expose**: Supabase Kong Gateway exposed to internal Docker network at `http://supabase-kong:8000`.
4. Analytics Context Logging (analytics/.branch_context.md)
Focus: Data heuristics, statistical math, and seeded rules.
When writing to the analytics log, use this format:

Markdown
- [YYYY-MM-DD] [Seeder/Math]:
  - **Action**: Completed `generate_synthetic_month.py`.
  - **Injected Heuristics**: Programmed a `-0.4` sentiment drop when `sleep_hours < 6`. Programmed a `+0.3` boost when `tags` includes `gym`.
  - **Math Engine**: Kendall's Tau algorithm implemented for correlation scoring.
  - **Integration Demand**: Script outputs CSV/SQL that directly matches the `journal_entries` table schema defined by Infrastructure.
🤝 The JSON Contract & Mock-First Law
The docs/JSON_CONTRACT.md is the only bridge between your isolated branches.

Never Assume: Do not invent new fields, rename keys, or change data types (e.g., changing a string to an int) without a cross-branch agreement.

Build Mocks: If your feature requires data from another branch that is not yet merged, build a local mock.

Frontend: Build a mock HTTP service.

Backend: Build a mock DB return.

Analytics: Use a mock CSV file.

Never Block: Lack of access to another team's live code is never an excuse to halt development.

⚠️ Global Guardrails
NEVER DO
❌ Break Isolation: Never write code that assumes the internal file structure or function names of another branch. Communicate strictly through REST endpoints and Database tables.

❌ Hallucinate Libraries: Never use unverified, experimental, or deprecated libraries. Stick to the stable stack defined in your branch rules.

❌ Ignore the UI Thread: (Frontend) Never execute heavy synchronous parsing on the main thread.

❌ Trust the LLM: (Backend) Never accept raw text from the LLM. Always force structured output via Pydantic.

ALWAYS DO
✅ Log the Context: Document your mocks and demands in .branch_context.md before ending a coding session.

✅ Handle Errors Gracefully: If a mock fails, or an endpoint goes down, the UI must show a clean fallback state, not a stack trace.

✅ Optimize for the Demo: Prioritize the visibility of the AI's intelligence. Features that look great in a 3-minute pitch (like animated insight cards and populated graphs) take precedence over deep edge-case error handling.