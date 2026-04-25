-- Enable pg_jsonschema extension
CREATE EXTENSION IF NOT EXISTS "pg_jsonschema";

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

-- Apply JSON schema validation for tags
ALTER TABLE journal_entries ADD CONSTRAINT tags_is_string_array CHECK (
    jsonb_matches_schema(
        '{
            "type": "array",
            "items": {"type": "string"}
        }'::jsonb,
        tags
    )
);

-- Apply JSON schema validation for triggers
ALTER TABLE journal_entries ADD CONSTRAINT triggers_is_string_array CHECK (
    jsonb_matches_schema(
        '{
            "type": "array",
            "items": {"type": "string"}
        }'::jsonb,
        triggers
    )
);

-- Index for journal_entries (Composite B-tree as mandated)
CREATE INDEX idx_journal_entries_user_id_created_at ON journal_entries (user_id, created_at DESC);


-- Create Insights table
CREATE TABLE IF NOT EXISTS insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    summary TEXT NOT NULL,
    correlations JSONB NOT NULL DEFAULT '[]'::jsonb,
    suggested_action TEXT NOT NULL,
    generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Apply JSON schema validation for correlations
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

-- Index for insights (Composite B-tree as mandated)
CREATE INDEX idx_insights_user_id_generated_at ON insights (user_id, generated_at DESC);
