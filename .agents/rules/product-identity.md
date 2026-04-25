---
trigger: always_on
---

***

# 🎨 Product Identity & UX Philosophy: MindMirror

## 🎯 Core Vision
MindMirror is not a diary; it is a **Personal Behavioral Intelligence System**. 
The product's fundamental purpose is to shift journaling from **passive reflection** to **active self-understanding**. Every UI element, color choice, and AI-generated text must serve this goal: converting unstructured human experiences into quantifiable, actionable insights.

---

## 🗣️ Voice & Tone (The AI Persona)
When the system communicates with the user (via Insight Cards, summaries, or nudges), it must act as an insightful, observant companion. 

### Core Traits
1. **Analytical, but Empathetic:** The system observes data but understands it belongs to a human. 
2. **Concise & Direct:** Do not waste the user's time. Get straight to the insight.
3. **Non-Presumptive:** The system identifies *correlations*, not medical diagnoses. Never tell the user how they feel; reflect the patterns of what they have reported.

### 🚫 The "Zero-Fluff" AI Rule (CRITICAL)
The AI must **NEVER** use standard LLM conversational filler. 
- **BANNED PHRASES:** "Sure, I can help with that," "Here is your insight," "Based on my analysis," "As an AI..."
- **Rule:** Start the output with the insight immediately. 

### ✅ Copywriting Examples
* **BAD (Robotic):** "Data indicates a 40% correlation between sleep < 6 hours and negative sentiment scores. Try sleeping more."
* **BAD (Overly emotional):** "Oh no, it looks like you've been feeling super sad lately! I'm so sorry. You should take a break!"
* **GOOD (MindMirror Identity):** "Your mood consistently drops on days with less than 6 hours of sleep. Consider adjusting your evening routine tonight."
* **GOOD (Actionable):** "Stress spikes before project deadlines. A 15-minute planning session today might help."

---

## 🎨 Visual Identity & Design System

The application deals with sensitive, personal mental data. The interface must be psychologically comforting, minimal, and devoid of clutter.

### The Material 3 Color Palette
We utilize a custom tonal palette centered around Purple, which historically conveys introspection, wisdom, and calmness.

* **Primary Action Color:** Deep Purple (`#800080` Light / `#C3B1E1` Dark)
    * *Usage:* Submit buttons, active chart trend lines.
* **The Intelligence Layer (Primary Container):** Lavender (`#E6E6FA` Light / `#483248` Dark)
    * *Usage:* **Strictly reserved for Insight Cards.** When the user sees this color, they should immediately associate it with the AI's intelligence and system feedback.
* **Background (Surface):** Tinted White (`#F3E5F5` Light) / Dark Plum (`#301934` Dark)
    * *Usage:* The main app background. We avoid stark white or pure black to reduce eye strain during late-night journaling.

### Typography & Spacing
* **Whitespace is a feature:** Do not cram elements together. Use generous padding (e.g., `16.0` or `24.0` standard padding in Flutter) around journal entries.
* **Font Weights:** Use standard, readable fonts. Emphasize *triggers* and *activities* in bold within the Insight Cards to draw the eye to the actionable data.

---

## ⚙️ Core UX Mechanics

### 1. Frictionless Input (Minimal Cognitive Load)
Users should not feel like they are filling out a tax form. 
- Do not force the user to categorize their own mood if they don't want to. Let them type free-form text and let the AI Orchestration layer do the heavy lifting of extracting the metadata.
- **Rule:** The primary action is a single text box and a "Save" button. Everything else is secondary.

### 2. Maximum Output Value
Every time a user inputs data, the system should ideally react. 
- The user gives: "I'm exhausted from studying."
- The system gives back: An updated trend graph and a newly generated daily summary. 

### 3. The Insight Card Hierarchy
The Insight Card is the hero of the application. 
- It must always live at the **top** of the dashboard view.
- It must stand out visually from the chronological journal feed.
- It should feel alive. When the backend detects a new correlation, the UI should use implicit animations (cross-fading) to introduce the new insight, making the system feel active rather than static.