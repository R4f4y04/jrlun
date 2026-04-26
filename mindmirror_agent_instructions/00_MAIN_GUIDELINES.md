# MindMirror Agent Build Instructions

## Project summary
MindMirror is a premium AI journaling and self-insight mobile app. The UI must feel dark, emotional, futuristic, and polished. The product should look like a personal behavioral intelligence companion, not a generic notes app.

## Core visual language
- Dark mode only.
- Backgrounds: black, deep navy, charcoal.
- Primary accents: purple, violet, blue-purple gradients.
- Secondary accents: teal, cyan, soft green, warm yellow for analytics and mood states.
- Use soft glows, subtle glassmorphism, rounded cards, and gentle shadows.
- Typography should be clean, modern, and highly readable.
- Keep spacing generous and consistent.
- Avoid clutter. Every screen should have one clear focus.

## Design principles
1. Make the app feel emotionally intelligent and calm.
2. Keep the interface premium and minimal.
3. Use rounded corners everywhere.
4. Use clear hierarchy: title, main card, supporting cards, bottom nav.
5. Make charts and insights visually simple and readable.
6. Make buttons obvious but not loud.
7. Ensure the app looks like it can be shipped as a real product.

## Components to reuse across screens
- Rounded top bars and section headers
- Large cards with dark translucent surfaces
- Purple gradient primary buttons
- Smaller secondary outline buttons
- Bottom navigation with four tabs: Home, Journal, Insights, Profile
- Emoji mood indicators
- Insight cards
- Trend charts and pattern cards
- Soft glowing icons

## Content style
- Use short, encouraging, emotionally aware copy.
- Keep text human and supportive.
- Avoid robotic phrasing.
- Use simple names, sample data, and realistic journal text.
- Use “Amaan” as the sample user name unless a screen explicitly needs something else.

## Data assumptions
The product stores:
- daily journal entries
- mood ratings
- stress levels
- tags like exercise, sleep, social, work
- AI summaries
- pattern insights
- weekly analytics

## Navigation rules
- Every page should feel part of the same app.
- Bottom nav should be present on core screens.
- Active tab must match the screen purpose.
- Use consistent icon style.

## Visual consistency rules
- Keep status bar iPhone-style.
- Maintain similar paddings, card radius, and glow intensity across all screens.
- Do not switch to a light theme.
- Do not use bright white backgrounds.
- Do not use excessive borders unless needed for structure.

## Output expectations
- Build each page as a polished, production-like mobile screen.
- Do not leave placeholders unless the page explicitly needs one.
- Fill each screen with realistic and complete content.
- Make charts and cards look intentional, not generic.

## Build order
1. Splash / landing screen
2. Journal check-in screen
3. Dashboard summary screen
4. Insights overview screen
5. Archive / calendar screen
6. Journal detail screen
7. Mood trends screen
8. Patterns screen
9. AI coach chat screen
10. Habit impact screen
11. Weekly report screen
12. Profile / settings screen

## Final quality bar
The full app should look like one coherent product suite. Every screen should feel premium, calm, and intelligent, with no missing sections or visual inconsistency.
