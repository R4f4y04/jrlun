import json
import random
import uuid
from datetime import datetime, timedelta, timezone

def generate_month_data(output_file="analytics/synthetic_data.json"):
    user_id = str(uuid.uuid4())
    start_date = datetime.now(timezone.utc) - timedelta(days=30)
    
    entries = []
    
    for i in range(30):
        current_date = start_date + timedelta(days=i)
        
        # Base sentiment (slightly positive bias)
        sentiment = random.uniform(-0.1, 0.4)
        tags = []
        triggers = []
        raw_text_parts = []
        
        # Randomize sleep hours (normal distribution around 7 hours)
        sleep_hours = round(random.normalvariate(7, 1.5), 1)
        
        # Heuristic 1: Sleep deprivation
        if sleep_hours < 6:
            sentiment -= 0.6  # Severe penalty for lack of sleep
            tags.extend(["tired", "fatigue", "brain-fog"])
            triggers.append("lack of sleep")
            raw_text_parts.append(f"Only got {sleep_hours} hours of sleep last night. Feeling completely drained.")
        else:
            sentiment += 0.2
            tags.append("rested")
            raw_text_parts.append(f"Slept well ({sleep_hours} hours). Feeling refreshed.")
            
        # Heuristic 2: Exercise
        has_gym = random.choice([True, False, False]) # 33% chance
        if has_gym:
            sentiment += 0.4  # Boost from exercise
            tags.append("gym")
            triggers.append("exercise")
            raw_text_parts.append("Hit the gym today. It was a solid workout.")
            
        # Heuristic 3: Academic/Work pressure on weekdays
        if current_date.weekday() < 5:  # Monday to Friday
            is_stressed = random.choice([True, False])
            if is_stressed:
                sentiment -= 0.3
                tags.extend(["studying", "stressed"])
                triggers.append("academic pressure")
                raw_text_parts.append("Spent hours studying. The workload is heavy right now.")
            else:
                tags.append("productive")
                raw_text_parts.append("Got a lot of work done today.")
        else:
            tags.append("weekend")
            raw_text_parts.append("Enjoying the weekend downtime.")
            
        # Clamp sentiment between -1.0 and 1.0
        sentiment = max(-1.0, min(1.0, sentiment))
        
        # Join text parts and add some randomness
        raw_text = " ".join(raw_text_parts)
        
        entry = {
            "id": str(uuid.uuid4()),
            "user_id": user_id,
            "raw_text": raw_text,
            "sentiment_score": round(sentiment, 2),
            "tags": list(set(tags)),
            "triggers": list(set(triggers)),
            "created_at": current_date.isoformat() + "Z"
        }
        
        entries.append(entry)
        
    # Wrapping in the paginated response format as expected by frontend
    output_data = {
        "data": entries,
        "meta": {
            "total": 30,
            "has_more": False
        }
    }
        
    with open(output_file, 'w') as f:
        json.dump(output_data, f, indent=2)
        
    print(f"Successfully generated 30 synthetic entries at {output_file}")
    print(f"Using User ID: {user_id}")

if __name__ == "__main__":
    generate_month_data()
