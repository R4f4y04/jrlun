-- Seed Data matching docs/JSON_CONTRACT.md

-- Insert a test user UUID (so we can relate entries and insights)
-- We will use a deterministic UUID for testing purposes
DO $$
DECLARE
    test_user_id UUID := '11111111-1111-1111-1111-111111111111';
BEGIN
    -- Insert Mock Journal Entries
    INSERT INTO journal_entries (id, user_id, raw_text, sentiment_score, tags, triggers, created_at)
    VALUES 
    (
        '22222222-2222-2222-2222-222222222221',
        test_user_id,
        'I''m exhausted from studying. Didn''t sleep much.',
        -0.40,
        '["studying", "tired"]'::jsonb,
        '["lack of sleep", "academic pressure"]'::jsonb,
        '2026-04-25 14:30:00+00'
    ),
    (
        '22222222-2222-2222-2222-222222222222',
        test_user_id,
        'Had a great workout today at the gym. Feeling energized!',
        0.80,
        '["gym", "workout", "energetic"]'::jsonb,
        '["exercise", "good health"]'::jsonb,
        '2026-04-24 10:15:00+00'
    ),
    (
        '22222222-2222-2222-2222-222222222223',
        test_user_id,
        'Feeling a bit stressed about the upcoming presentation, but I think I am prepared.',
        0.10,
        '["work", "stress", "presentation"]'::jsonb,
        '["public speaking", "work pressure"]'::jsonb,
        '2026-04-23 16:45:00+00'
    );

    -- Insert Mock Insight
    INSERT INTO insights (id, user_id, summary, correlations, suggested_action, generated_at)
    VALUES 
    (
        '33333333-3333-3333-3333-333333333333',
        test_user_id,
        'Your mood consistently drops on days with less than 6 hours of sleep.',
        '[
            {
                "trigger": "lack of sleep",
                "impact": "negative",
                "confidence_score": 0.85
            }
        ]'::jsonb,
        'Consider adjusting your evening routine tonight to prioritize rest.',
        '2026-04-25 15:00:00+00'
    );
END $$;
