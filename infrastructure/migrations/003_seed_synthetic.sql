-- ============================================================================
-- MindMirror: 30-day synthetic data seed
-- Generated from analytics/synthetic_data.json + current_insight.json
-- ============================================================================

DO $$
DECLARE
    synth_user_id UUID := '4e3c9a57-9629-46d4-ae8e-50921bfce626';
BEGIN

-- -------------------------------------------------------------------------
-- Journal Entries (30 days of synthetic behavioral data)
-- -------------------------------------------------------------------------
INSERT INTO journal_entries (id, user_id, raw_text, sentiment_score, tags, triggers, created_at) VALUES
('c92e7aab-e232-416a-8533-92fe7cbfd2d5', synth_user_id,
 'Slept well (8.2 hours). Feeling refreshed. Spent hours studying. The workload is heavy right now.',
 0.18, '["stressed","studying","rested"]'::jsonb, '["academic pressure"]'::jsonb,
 '2026-03-26T19:58:53.760202+00:00'),

('571337b6-fe20-4570-84cc-68129af93cf7', synth_user_id,
 'Only got 5.1 hours of sleep last night. Feeling completely drained. Spent hours studying. The workload is heavy right now.',
 -0.61, '["studying","fatigue","stressed","brain-fog","tired"]'::jsonb, '["lack of sleep","academic pressure"]'::jsonb,
 '2026-03-27T19:58:53.760202+00:00'),

('56ecbd24-f957-49c4-a6c5-d606374ef4a2', synth_user_id,
 'Only got 5.5 hours of sleep last night. Feeling completely drained. Hit the gym today. It was a solid workout. Enjoying the weekend downtime.',
 -0.17, '["fatigue","brain-fog","tired","gym","weekend"]'::jsonb, '["lack of sleep","exercise"]'::jsonb,
 '2026-03-28T19:58:53.760202+00:00'),

('91cafbd7-f419-4a65-b8f9-2b9843a21ee7', synth_user_id,
 'Slept well (6.2 hours). Feeling refreshed. Enjoying the weekend downtime.',
 0.23, '["weekend","rested"]'::jsonb, '[]'::jsonb,
 '2026-03-29T19:58:53.760202+00:00'),

('e294a98c-f369-4054-a0a6-7bedee7731ff', synth_user_id,
 'Only got 5.3 hours of sleep last night. Feeling completely drained. Spent hours studying. The workload is heavy right now.',
 -0.70, '["studying","fatigue","stressed","brain-fog","tired"]'::jsonb, '["lack of sleep","academic pressure"]'::jsonb,
 '2026-03-30T19:58:53.760202+00:00'),

('14d12fd1-284d-4ac8-8575-47f90577990e', synth_user_id,
 'Slept well (6.3 hours). Feeling refreshed. Spent hours studying. The workload is heavy right now.',
 0.11, '["stressed","studying","rested"]'::jsonb, '["academic pressure"]'::jsonb,
 '2026-03-31T19:58:53.760202+00:00'),

('714a158c-342c-4b5d-bc70-a53fdd8cac79', synth_user_id,
 'Slept well (8.8 hours). Feeling refreshed. Spent hours studying. The workload is heavy right now.',
 -0.12, '["stressed","studying","rested"]'::jsonb, '["academic pressure"]'::jsonb,
 '2026-04-01T19:58:53.760202+00:00'),

('77a5535d-acb2-411d-85c6-4b13eaaa7c71', synth_user_id,
 'Slept well (7.4 hours). Feeling refreshed. Hit the gym today. It was a solid workout. Got a lot of work done today.',
 0.61, '["gym","productive","rested"]'::jsonb, '["exercise"]'::jsonb,
 '2026-04-02T19:58:53.760202+00:00'),

('bdd72ded-73ab-4117-8356-0badb97173c4', synth_user_id,
 'Slept well (7.7 hours). Feeling refreshed. Hit the gym today. It was a solid workout. Got a lot of work done today.',
 0.51, '["gym","productive","rested"]'::jsonb, '["exercise"]'::jsonb,
 '2026-04-03T19:58:53.760202+00:00'),

('a3060071-d2dc-498c-8932-1be018c3f9f3', synth_user_id,
 'Slept well (7.0 hours). Feeling refreshed. Enjoying the weekend downtime.',
 0.12, '["weekend","rested"]'::jsonb, '[]'::jsonb,
 '2026-04-04T19:58:53.760202+00:00'),

('53043288-6eb9-4abd-a714-79d09537e01c', synth_user_id,
 'Slept well (8.1 hours). Feeling refreshed. Enjoying the weekend downtime.',
 0.39, '["weekend","rested"]'::jsonb, '[]'::jsonb,
 '2026-04-05T19:58:53.760202+00:00'),

('95513f50-555a-4f47-9054-2051dcec9de5', synth_user_id,
 'Slept well (8.7 hours). Feeling refreshed. Got a lot of work done today.',
 0.46, '["productive","rested"]'::jsonb, '[]'::jsonb,
 '2026-04-06T19:58:53.760202+00:00'),

('3b581305-b9ef-4342-a719-2cd2429e6eed', synth_user_id,
 'Only got 5.0 hours of sleep last night. Feeling completely drained. Spent hours studying. The workload is heavy right now.',
 -0.79, '["studying","fatigue","stressed","brain-fog","tired"]'::jsonb, '["lack of sleep","academic pressure"]'::jsonb,
 '2026-04-07T19:58:53.760202+00:00'),

('13cba98b-e6a5-48ba-9121-6c6bf945b66b', synth_user_id,
 'Slept well (10.3 hours). Feeling refreshed. Spent hours studying. The workload is heavy right now.',
 0.06, '["stressed","studying","rested"]'::jsonb, '["academic pressure"]'::jsonb,
 '2026-04-08T19:58:53.760202+00:00'),

('98086305-0fc3-4afd-9461-6290fc5bf74c', synth_user_id,
 'Slept well (6.5 hours). Feeling refreshed. Spent hours studying. The workload is heavy right now.',
 -0.13, '["stressed","studying","rested"]'::jsonb, '["academic pressure"]'::jsonb,
 '2026-04-09T19:58:53.760202+00:00'),

('d108cf35-4be8-4248-b003-8c9ed6750991', synth_user_id,
 'Slept well (7.1 hours). Feeling refreshed. Spent hours studying. The workload is heavy right now.',
 0.30, '["stressed","studying","rested"]'::jsonb, '["academic pressure"]'::jsonb,
 '2026-04-10T19:58:53.760202+00:00'),

('aea1bf1d-7712-40ba-891a-4052fc04d061', synth_user_id,
 'Only got 5.1 hours of sleep last night. Feeling completely drained. Hit the gym today. It was a solid workout. Enjoying the weekend downtime.',
 0.11, '["fatigue","brain-fog","tired","gym","weekend"]'::jsonb, '["lack of sleep","exercise"]'::jsonb,
 '2026-04-11T19:58:53.760202+00:00'),

('857ea616-3772-443a-aec0-f1e3442dc6ca', synth_user_id,
 'Slept well (8.5 hours). Feeling refreshed. Enjoying the weekend downtime.',
 0.52, '["weekend","rested"]'::jsonb, '[]'::jsonb,
 '2026-04-12T19:58:53.760202+00:00'),

('2521fbe9-5e49-45a3-ba6b-ebfd37793785', synth_user_id,
 'Slept well (7.9 hours). Feeling refreshed. Spent hours studying. The workload is heavy right now.',
 -0.08, '["stressed","studying","rested"]'::jsonb, '["academic pressure"]'::jsonb,
 '2026-04-13T19:58:53.760202+00:00'),

('63b5a2bc-eb28-4e97-8c87-600183bdd1b0', synth_user_id,
 'Only got 5.4 hours of sleep last night. Feeling completely drained. Got a lot of work done today.',
 -0.40, '["productive","brain-fog","tired","fatigue"]'::jsonb, '["lack of sleep"]'::jsonb,
 '2026-04-14T19:58:53.760202+00:00'),

('3c3e5b3b-d9ec-4c52-b743-e8a022003ace', synth_user_id,
 'Slept well (8.7 hours). Feeling refreshed. Spent hours studying. The workload is heavy right now.',
 0.29, '["stressed","studying","rested"]'::jsonb, '["academic pressure"]'::jsonb,
 '2026-04-15T19:58:53.760202+00:00'),

('4795a1a1-eef1-4115-b601-fa3615cf9289', synth_user_id,
 'Slept well (8.6 hours). Feeling refreshed. Got a lot of work done today.',
 0.47, '["productive","rested"]'::jsonb, '[]'::jsonb,
 '2026-04-16T19:58:53.760202+00:00'),

('99ba5470-a73f-4d3e-b2e1-b2185b89e20d', synth_user_id,
 'Slept well (8.2 hours). Feeling refreshed. Hit the gym today. It was a solid workout. Got a lot of work done today.',
 0.94, '["gym","productive","rested"]'::jsonb, '["exercise"]'::jsonb,
 '2026-04-17T19:58:53.760202+00:00'),

('ba4df926-2ecb-4821-afe3-2b40fb84e4ca', synth_user_id,
 'Slept well (8.4 hours). Feeling refreshed. Enjoying the weekend downtime.',
 0.17, '["weekend","rested"]'::jsonb, '[]'::jsonb,
 '2026-04-18T19:58:53.760202+00:00'),

('0611e8a1-3649-416c-880d-f015510bcf3f', synth_user_id,
 'Only got 4.1 hours of sleep last night. Feeling completely drained. Enjoying the weekend downtime.',
 -0.44, '["brain-fog","tired","weekend","fatigue"]'::jsonb, '["lack of sleep"]'::jsonb,
 '2026-04-19T19:58:53.760202+00:00'),

('ab7a8962-6095-41ea-94f5-b2a4ce1a21d4', synth_user_id,
 'Slept well (9.2 hours). Feeling refreshed. Hit the gym today. It was a solid workout. Got a lot of work done today.',
 0.51, '["gym","productive","rested"]'::jsonb, '["exercise"]'::jsonb,
 '2026-04-20T19:58:53.760202+00:00'),

('61c8f265-91cc-4bdb-bbaf-1bc385f68504', synth_user_id,
 'Slept well (7.2 hours). Feeling refreshed. Got a lot of work done today.',
 0.52, '["productive","rested"]'::jsonb, '[]'::jsonb,
 '2026-04-21T19:58:53.760202+00:00'),

('e86a51ec-ebcf-470c-8469-eda373af5d7a', synth_user_id,
 'Slept well (6.6 hours). Feeling refreshed. Hit the gym today. It was a solid workout. Spent hours studying. The workload is heavy right now.',
 0.41, '["stressed","gym","studying","rested"]'::jsonb, '["exercise","academic pressure"]'::jsonb,
 '2026-04-22T19:58:53.760202+00:00'),

('f23dd517-af46-4c9b-a366-66e72405251a', synth_user_id,
 'Only got 5.0 hours of sleep last night. Feeling completely drained. Hit the gym today. It was a solid workout. Spent hours studying. The workload is heavy right now.',
 -0.27, '["studying","fatigue","stressed","brain-fog","tired","gym"]'::jsonb, '["lack of sleep","exercise","academic pressure"]'::jsonb,
 '2026-04-23T19:58:53.760202+00:00'),

('0abecc29-4f43-45fd-91a5-02ac2b77e3c8', synth_user_id,
 'Slept well (6.7 hours). Feeling refreshed. Got a lot of work done today.',
 0.14, '["productive","rested"]'::jsonb, '[]'::jsonb,
 '2026-04-24T19:58:53.760202+00:00');


-- -------------------------------------------------------------------------
-- Insight (pre-computed correlation analysis)
-- -------------------------------------------------------------------------
INSERT INTO insights (id, user_id, summary, correlations, suggested_action, generated_at) VALUES
('f276b463-4e97-4244-ac62-d4032ecf8a87', synth_user_id,
 'Your mood consistently drops on days with less than 6 hours of sleep.',
 '[
     {"trigger": "lack of sleep", "impact": "negative", "confidence_score": 0.91},
     {"trigger": "academic pressure", "impact": "negative", "confidence_score": 0.59},
     {"trigger": "exercise", "impact": "positive", "confidence_score": 0.36}
 ]'::jsonb,
 'Consider adjusting your evening routine tonight to prioritize rest.',
 '2026-04-25T20:05:02.958990+00:00');

RAISE NOTICE '[OK] Seeded 30 synthetic journal entries + 1 insight';

END $$;
