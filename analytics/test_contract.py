import json
import os
import sys

def validate_journal_entry(entry):
    assert isinstance(entry.get("id"), str), "id must be string"
    assert isinstance(entry.get("user_id"), str), "user_id must be string"
    assert isinstance(entry.get("raw_text"), str), "raw_text must be string"
    
    score = entry.get("sentiment_score")
    assert isinstance(score, (int, float)), "sentiment_score must be a number"
    assert -1.0 <= score <= 1.0, f"sentiment_score must be between -1.0 and 1.0, got {score}"
    
    assert isinstance(entry.get("tags"), list), "tags must be a list"
    assert all(isinstance(t, str) for t in entry.get("tags")), "all tags must be strings"
    
    assert isinstance(entry.get("triggers"), list), "triggers must be a list"
    assert all(isinstance(t, str) for t in entry.get("triggers")), "all triggers must be strings"
    
    assert isinstance(entry.get("created_at"), str), "created_at must be string (ISO format)"

def validate_insight_model(insight):
    assert isinstance(insight.get("id"), str), "id must be string"
    assert isinstance(insight.get("user_id"), str), "user_id must be string"
    assert isinstance(insight.get("summary"), str), "summary must be string"
    
    assert isinstance(insight.get("correlations"), list), "correlations must be a list"
    for corr in insight.get("correlations"):
        assert isinstance(corr.get("trigger"), str), "correlation.trigger must be string"
        assert isinstance(corr.get("impact"), str), "correlation.impact must be string"
        conf = corr.get("confidence_score")
        assert isinstance(conf, (int, float)), "correlation.confidence_score must be a number"
        assert 0.0 <= conf <= 1.0, "correlation.confidence_score must be between 0.0 and 1.0"
        
    assert isinstance(insight.get("suggested_action"), str), "suggested_action must be string"
    assert isinstance(insight.get("generated_at"), str), "generated_at must be string (ISO format)"

def main():
    print("Running JSON Contract Validation...")
    
    # Test Synthetic Data
    data_path = "analytics/synthetic_data.json"
    if not os.path.exists(data_path):
        print(f"Missing file: {data_path}")
        sys.exit(1)
        
    with open(data_path, "r") as f:
        data = json.load(f)
        
    entries = data.get("data", [])
    for i, entry in enumerate(entries):
        try:
            validate_journal_entry(entry)
        except AssertionError as e:
            print(f"Validation failed for synthetic_data.json at entry index {i}: {e}")
            sys.exit(1)
            
    print(f"synthetic_data.json passed validation ({len(entries)} entries).")
    
    # Test Current Insight
    insight_path = "analytics/current_insight.json"
    if not os.path.exists(insight_path):
        print(f"Missing file: {insight_path}")
        sys.exit(1)
        
    with open(insight_path, "r") as f:
        insight = json.load(f)
        
    try:
        validate_insight_model(insight)
    except AssertionError as e:
        print(f"Validation failed for current_insight.json: {e}")
        sys.exit(1)
        
    print(f"current_insight.json passed validation (1 insight with {len(insight.get('correlations', []))} correlations).")
    print("\nAll files perfectly match the docs/JSON_CONTRACT.md!")

if __name__ == "__main__":
    main()
