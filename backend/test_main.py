import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

# --- Functional Tests ---

def test_submit_entry_success():
    payload = {"raw_text": "I'm exhausted from studying. Didn't sleep much."}
    response = client.post("/api/v1/entries", json=payload)
    assert response.status_code == 201
    
    data = response.json()
    assert "id" in data
    assert data["raw_text"] == payload["raw_text"]
    assert "sentiment_score" in data
    assert isinstance(data["sentiment_score"], float)
    assert "tags" in data
    assert isinstance(data["tags"], list)
    assert "triggers" in data
    assert isinstance(data["triggers"], list)

def test_submit_entry_empty_text():
    payload = {"raw_text": "   "}
    response = client.post("/api/v1/entries", json=payload)
    assert response.status_code == 400
    
    data = response.json()
    assert "error" in data
    assert data["error"]["code"] == "VALIDATION_FAILED"
    assert "message" in data["error"]

def test_get_entries():
    response = client.get("/api/v1/entries")
    assert response.status_code == 200
    
    data = response.json()
    assert "data" in data
    assert isinstance(data["data"], list)
    assert "meta" in data
    assert "total" in data["meta"]
    assert "has_more" in data["meta"]

def test_get_current_insight():
    response = client.get("/api/v1/insights/current")
    assert response.status_code == 200
    
    data = response.json()
    assert "id" in data
    assert "summary" in data
    assert "correlations" in data
    assert isinstance(data["correlations"], list)
    assert "suggested_action" in data

# --- Performance Tests ---

def test_benchmark_submit_entry(benchmark):
    payload = {"raw_text": "This is a performance test for the orchestration layer."}
    
    def post_request():
        return client.post("/api/v1/entries", json=payload)
        
    response = benchmark(post_request)
    assert response.status_code == 201

def test_benchmark_get_insight(benchmark):
    def get_request():
        return client.get("/api/v1/insights/current")
        
    response = benchmark(get_request)
    assert response.status_code == 200
