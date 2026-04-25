import json
import uuid
from datetime import datetime, timezone
import scipy.stats as stats
import numpy as np

def analyze_data(input_file="analytics/synthetic_data.json", output_file="analytics/current_insight.json"):
    try:
        with open(input_file, 'r') as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"Error: {input_file} not found. Please run generate_synthetic_month.py first.")
        return

    entries = data.get("data", [])
    if not entries:
        print("No entries found in the dataset.")
        return
        
    user_id = entries[0].get("user_id", str(uuid.uuid4()))

    # Extract all sentiment scores and all unique triggers
    sentiment_scores = []
    all_triggers = set()
    
    for entry in entries:
        sentiment_scores.append(entry.get("sentiment_score", 0.0))
        for trigger in entry.get("triggers", []):
            all_triggers.add(trigger)
            
    sentiment_array = np.array(sentiment_scores)
    
    correlations_list = []
    
    # Run Kendall's Tau for each trigger
    for trigger in all_triggers:
        # Create a binary array (1 if trigger present, 0 if not) for the 30 days
        trigger_presence = [1 if trigger in entry.get("triggers", []) else 0 for entry in entries]
                
        trigger_array = np.array(trigger_presence)
        
        # Calculate Kendall's Tau
        # kendalltau returns Correlation (tau) and p-value
        tau, p_value = stats.kendalltau(trigger_array, sentiment_array)
        
        # We handle NaN which happens if a trigger is constant (e.g. all 0s or all 1s, which shouldn't happen here but safe)
        if not np.isnan(tau):
            print(f"Trigger: '{trigger}' -> Tau: {tau:.3f}, p-value: {p_value:.3f}")
            
            # Filter for statistical significance (p < 0.15 is generous but fair for 30 days of data)
            if p_value < 0.15:
                correlations_list.append({
                    "trigger": trigger,
                    "tau": tau,
                    "p_value": p_value
                })

    if not correlations_list:
        print("No statistically significant correlations found.")
        return
        
    # Sort correlations by absolute tau (strongest pattern first)
    correlations_list.sort(key=lambda x: abs(x["tau"]), reverse=True)
    
    best_trigger_info = correlations_list[0]
    best_correlation = best_trigger_info["trigger"]
    best_tau = best_trigger_info["tau"]
        
    print(f"\nWinner: '{best_correlation}' with Tau: {best_tau:.3f}")

    # Generate the InsightModel based on the best correlation
    impact = "positive" if best_tau > 0 else "negative"
    
    # Dynamic text based on trigger and impact
    if best_correlation == "lack of sleep":
        summary = "Your mood consistently drops on days with less than 6 hours of sleep."
        suggested_action = "Consider adjusting your evening routine tonight to prioritize rest."
    elif best_correlation == "exercise":
        summary = "You consistently report higher sentiment scores on days you exercise."
        suggested_action = "Great job! Keep scheduling regular workouts to maintain your mood."
    elif best_correlation == "academic pressure":
        summary = "Academic pressure is slightly lowering your overall mood on weekdays."
        suggested_action = "Try to schedule short 10-minute breaks every hour while studying."
    else:
        # Fallback text
        summary = f"We noticed a strong {impact} correlation between your mood and '{best_correlation}'."
        suggested_action = f"Pay attention to how '{best_correlation}' affects you going forward."
        
    # Create a list of the top 3 strongest correlations for the UI
    correlations_output = []
    for c in correlations_list[:3]:
        # Scale tau into a more user-friendly confidence score (0 to 1.0)
        confidence = min(1.0, round(abs(c["tau"]) * 1.5, 2))
        correlations_output.append({
          "trigger": c["trigger"],
          "impact": "positive" if c["tau"] > 0 else "negative",
          "confidence_score": confidence
        })

    insight = {
      "id": str(uuid.uuid4()),
      "user_id": user_id,
      "summary": summary,
      "correlations": correlations_output,
      "suggested_action": suggested_action,
      "generated_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    }

    # Output to the requested file
    with open(output_file, 'w') as f:
        json.dump(insight, f, indent=2)
        
    print(f"\nGenerated InsightModel successfully at {output_file}")

if __name__ == "__main__":
    analyze_data()
