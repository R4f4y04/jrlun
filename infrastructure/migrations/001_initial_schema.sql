-- ============================================================================
-- MindMirror Schema: journal_entries + insights
-- Hardened: pg_jsonschema constraints are optional (wrapped in exception block)
-- ============================================================================

-- Create Journal Entries table
CREATE TABLE IF NOT EXISTS journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    raw_text TEXT NOT NULL,
    sentiment_score NUMERIC(3, 2) CHECK (sentiment_score >= -1.0 AND sentiment_score <= 1.0),
    tags JSONB NOT NULL DEFAULT '[]'::jsonb,
    triggers JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for journal_entries (Composite B-tree as mandated)
CREATE INDEX IF NOT EXISTS idx_journal_entries_user_id_created_at
    ON journal_entries (user_id, created_at DESC);

-- Create Insights table
CREATE TABLE IF NOT EXISTS insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    summary TEXT NOT NULL,
    correlations JSONB NOT NULL DEFAULT '[]'::jsonb,
    suggested_action TEXT NOT NULL,
    generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for insights (Composite B-tree as mandated)
CREATE INDEX IF NOT EXISTS idx_insights_user_id_generated_at
    ON insights (user_id, generated_at DESC);

-- ============================================================================
-- Optional: pg_jsonschema validation constraints
-- These enhance data integrity but are not required for the app to function.
-- If the extension is not available, we skip gracefully.
-- ============================================================================
DO $$
BEGIN
    CREATE EXTENSION IF NOT EXISTS "pg_jsonschema";

    ALTER TABLE journal_entries ADD CONSTRAINT tags_is_string_array CHECK (
        jsonb_matches_schema(
            '{
                "type": "array",
                "items": {"type": "string"}
            }'::jsonb,
            tags
        )
    );

    ALTER TABLE journal_entries ADD CONSTRAINT triggers_is_string_array CHECK (
        jsonb_matches_schema(
            '{
                "type": "array",
                "items": {"type": "string"}
            }'::jsonb,
            triggers
        )
    );

    ALTER TABLE insights ADD CONSTRAINT correlations_schema_check CHECK (
        jsonb_matches_schema(
            '{
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "trigger": {"type": "string"},
                        "impact": {"type": "string"},
                        "confidence_score": {"type": "number"}
                    },
                    "required": ["trigger", "impact", "confidence_score"]
                }
            }'::jsonb,
            correlations
        )
    );

    RAISE NOTICE '[OK] pg_jsonschema constraints applied successfully';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '[WARN] pg_jsonschema not available — skipping JSON schema validation constraints. Error: %', SQLERRM;
END $$;
