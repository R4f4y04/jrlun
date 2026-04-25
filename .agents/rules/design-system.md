---
trigger: always_on
---

Design System & UI Specification: MindMirror
🎯 Purpose
This document defines the visual language and component specifications for the MindMirror Flutter application. All UI agents must strictly adhere to these guidelines to ensure a cohesive, accessible, and psychologically comforting user experience. Never hardcode hex values within individual widgets. Always map them to the Material 3 ThemeData and access them via Theme.of(context).

🎨 1. Color System (Material 3)
The application uses a custom, purple-based tonal palette designed to evoke introspection and calmness, while ensuring high contrast for readability.

1.1 The Palette
Define these strictly within the colorScheme of your ThemeData.

Role	Light Theme (Hex)	Dark Theme (Hex)	Usage Rules
Primary	#800080 (Deep Purple)	#C3B1E1 (Pastel Purple)	Floating Action Buttons (FABs), active chart lines, primary submit buttons.
On Primary	#FFFFFF	#1A001A	Text/Icons rendered directly on top of Primary elements.
Primary Container	#E6E6FA (Lavender)	#483248 (Eggplant)	Reserved for the Insight Card and AI Feedback.
On Primary Container	#1A001A (Near Black)	#E6E6FA (Lavender)	Text rendered inside the Insight Card.
Surface	#F3E5F5 (Tinted White)	#301934 (Dark Plum)	The main scaffold/background color.
Surface Variant	#E1BEE7 (Light Lilac)	#51414F (Quartz)	Secondary cards (historical entries), dividers, inactive chips.
Error	#B3261E	#F2B8B5	Destructive actions or system errors (use sparingly).
🔤 2. Typography
We rely on Flutter's default Material 3 typography (Roboto/San Francisco), but with specific weight and styling rules to organize information hierarchy.

Display / Headline: Used only for major screen titles (e.g., "Your Insights").

Weight: FontWeight.w600

Body Large: Used for the actual text of the Journal Entries.

Weight: FontWeight.w400

Height: 1.5 (Ensure breathing room between lines for readability).

Body Medium / Label Large: Used for AI-generated insights and summaries.

Rule: When rendering AI text, dynamically apply FontWeight.w700 (Bold) to extracted tags, activities, and triggers to draw the user's eye to actionable data.

📐 3. Spacing, Layout & Shape
Whitespace is fundamental. The app must not feel cluttered.

Global Padding: Use 16.0 for standard horizontal screen padding and 24.0 for prominent visual breaks.

Border Radius: Adhere to Material 3 rounded corners.

Cards (Insight & Entry): BorderRadius.circular(16.0)

Chips (Tags/Activities): BorderRadius.circular(8.0)

Elevation: Keep the app mostly flat. Rely on tonal contrast (e.g., Surface vs Surface Variant) rather than heavy drop shadows. Set elevation: 0 on most Cards, except for the pinned Insight Card which may have an elevation of 2.

🧩 4. Core Components Specifications
4.1 The Insight Card (Hero Component)
This is the most critical widget in the application.

Container: Card widget.

Color: Theme.of(context).colorScheme.primaryContainer.

Placement: Pinned to the top of the dashboard scroll view (or wrapped in a SliverAppBar / sticky header).

Animation: Must be wrapped in an AnimatedSwitcher with a duration of 300ms. When the text changes (e.g., a new insight is pulled from the backend), it must cross-fade smoothly.

Iconography: Include a subtle, non-distracting icon (e.g., Icons.auto_awesome or Icons.insights) to denote AI generation.

4.2 Journal Entry Input Field
Style: Minimalist. Do not use heavy borders. Use InputDecoration with InputBorder.none or a very subtle underline.

Interaction: Must support multiline input natively (minLines: 3, maxLines: null).

Action: The "Save" button should be prominently accessible, utilizing the Primary color.

4.3 Behavioral Chips (Tags & Triggers)
When displaying extracted metadata on past entries:

Use Flutter's Chip widget.

Color: Surface Variant.

Text Style: LabelSmall.

4.4 Data Visualization (Syncfusion Charts)
Gridlines: Disable major and minor vertical gridlines to reduce clutter. Keep horizontal gridlines subtle (low opacity).

Trend Line: The main sentiment trend line must be smooth (SplineSeries in Syncfusion) and use the Primary color.

Interactivity: Enable crosshair and tooltip behaviors so the user can tap a specific day to see the exact sentiment score and associated activities.

🛑 5. Rules for the Flutter UI Agent
NO HARDCODING: Never write color: Colors.purple or color: Color(0xFF800080) inside a widget file. Always define it in theme/app_theme.dart and call Theme.of(context).colorScheme....

REUSABILITY: If you build a specific styled button or card, abstract it into lib/core/theme/components/ rather than duplicating the widget tree.

RESPONSIVENESS: Ensure all layouts use Expanded, Flexible, or MediaQuery appropriately so the app does not overflow on smaller mobile screens.

STATE REBUILDING: Ensure that complex UI animations (like the Insight Card updating or Charts rendering) are isolated in their own Consumer widgets so the entire screen does not rebuild on a state change.