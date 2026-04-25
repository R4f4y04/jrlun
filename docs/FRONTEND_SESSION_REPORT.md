# 📱 Frontend Branch Session Report — `feature/frontend-rafay`

> **Owner:** Rafay  
> **Branch:** `feature/frontend-rafay`  
> **Date:** 2026-04-25  
> **Flutter SDK:** `3.39.0-0.1.pre` (Beta channel, Dart `3.11.0-93.1.beta`)  
> **Status:** ✅ All planned work complete. Zero static analysis issues. App builds and runs on Windows.

---

## 1. Environment & SDK Constraints

This branch was developed on a **Flutter 3.39 pre-release SDK**. This is critical context because several standard APIs have been removed or renamed in this version compared to stable Flutter:

| Stable Flutter API | 3.39 Pre-release Equivalent | Files Affected |
|---|---|---|
| `CardTheme` (class name) | `CardThemeData` | `app_theme.dart` |
| `background` / `onBackground` in `ColorScheme` | Removed — use `surface` / `onSurface` | `app_theme.dart` |
| `surfaceVariant` in `ColorScheme` constructor | `surfaceContainerHighest` | `app_theme.dart` |
| `Color.withOpacity()` | `Color.withValues(alpha:)` | All widget files |
| `syncfusion_flutter_charts 24.x` | **Incompatible** — `markNeedsBuild` removed | Replaced with `CustomPainter` |

> **⚠️ If you switch to a stable Flutter SDK**, you may need to revert `CardThemeData` → `CardTheme`, restore `background`/`onBackground`, and change `surfaceContainerHighest` back to `surfaceVariant`.

---

## 2. Architecture Overview

The frontend strictly follows the **MVC pattern with Provider** as mandated by `.agents/workflows/frontend-rafay.md`.

```
frontend/lib/
├── main.dart                           # App entry point, MultiProvider, AppTheme
├── core/
│   └── theme/
│       └── app_theme.dart              # Material 3 ThemeData (light + dark)
├── models/
│   ├── journal_entry.dart              # JournalEntry data class
│   └── insight_model.dart              # InsightModel + InsightCorrelation data classes
├── services/
│   ├── mock_journal_service.dart       # Mock: returns dummy journal entries
│   └── mock_insight_service.dart       # Mock: returns dummy AI insight
├── controllers/
│   ├── journal_provider.dart           # ChangeNotifier for journal entries
│   └── insight_provider.dart           # ChangeNotifier for AI insight
└── modules/
    └── dashboard/
        ├── screens/
        │   └── dashboard_screen.dart   # Main screen assembling all components
        └── widgets/
            ├── insight_card.dart       # Hero AI Insight Card (AnimatedSwitcher)
            ├── sentiment_chart.dart    # Animated spline chart (CustomPainter)
            ├── journal_input_field.dart# Minimalist multiline text input + Save
            └── historical_entries_feed.dart # Scrollable entry cards with Chips
```

---

## 3. Detailed File-by-File Breakdown

### 3.1 `pubspec.yaml`
**Dependencies added:**
- `provider: ^6.1.2` — State management (ChangeNotifier MVC)
- `dio: ^5.4.3+1` — HTTP client (added for future integration, not yet consumed)
- `syncfusion_flutter_charts` — **Removed** due to SDK incompatibility; chart is now built with pure `CustomPainter`

### 3.2 `core/theme/app_theme.dart`
- Implements the full **Deep Purple / Lavender** Material 3 palette from the design system
- **Light theme:** primary `#800080`, primaryContainer `#E6E6FA` (Lavender), surface `#F3E5F5`
- **Dark theme:** primary `#C3B1E1`, primaryContainer `#483248` (Eggplant), surface `#301934` (Dark Plum)
- Cards: `elevation: 0.0`, `borderRadius: 16.0`
- Chips: `borderRadius: 8.0`
- Typography: Display/Headline at `w600`, Body at `w400` with `height: 1.5` for readability

### 3.3 `models/journal_entry.dart`
Maps exactly to `docs/JSON_CONTRACT.md` §1.1:

| Dart Field | JSON Key | Type |
|---|---|---|
| `id` | `id` | `String` |
| `userId` | `user_id` | `String` |
| `rawText` | `raw_text` | `String` |
| `sentimentScore` | `sentiment_score` | `double` (-1.0 to 1.0) |
| `tags` | `tags` | `List<String>` |
| `triggers` | `triggers` | `List<String>` |
| `createdAt` | `created_at` | `DateTime` (ISO 8601) |

### 3.4 `models/insight_model.dart`
Maps exactly to `docs/JSON_CONTRACT.md` §1.2:

- `InsightModel`: `id`, `userId`, `summary`, `correlations`, `suggestedAction`, `generatedAt`
- `InsightCorrelation` (nested): `trigger`, `impact`, `confidenceScore`

### 3.5 `services/mock_journal_service.dart`
- `getHistoricalEntries()` → Returns 2 dummy `JournalEntry` objects with realistic data (800ms delay)
- `submitEntry(String rawText)` → Returns a new mock `JournalEntry` with the provided text (1s delay)

### 3.6 `services/mock_insight_service.dart`
- `getCurrentInsight()` → Returns a single `InsightModel` with the example from the JSON contract: *"Your mood consistently drops on days with less than 6 hours of sleep."* (800ms delay)

### 3.7 `controllers/journal_provider.dart`
- Extends `ChangeNotifier`
- Owns: `List<JournalEntry> entries`, `bool isLoading`
- Actions: `fetchEntries()`, `addEntry(String text)`
- Consumes `MockJournalService` internally

### 3.8 `controllers/insight_provider.dart`
- Extends `ChangeNotifier`
- Owns: `InsightModel? currentInsight`, `bool isLoading`
- Actions: `fetchCurrentInsight()`
- Consumes `MockInsightService` internally

### 3.9 `modules/dashboard/widgets/insight_card.dart`
- **Hero component** — Uses `primaryContainer` color as mandated by design system
- Wraps content in `AnimatedSwitcher` (300ms cross-fade)
- Uses `RichText` with a parser that dynamically bolds trigger words found in the summary text
- Displays `Icons.auto_awesome` header and `Icons.lightbulb_outline` for the suggested action

### 3.10 `modules/dashboard/widgets/sentiment_chart.dart`
- **Pure Dart `CustomPainter`** — zero external dependencies
- Animated spline that draws itself in over 900ms using `AnimationController`
- Purple gradient fill under the curve
- Dot markers at each data point with hover/tap detection stub
- Horizontal gridlines at -1.0, -0.5, 0.0, 0.5, 1.0 with a stronger zero line
- Tooltip widget for hovered data points

### 3.11 `modules/dashboard/widgets/journal_input_field.dart`
- Minimalist text field with `InputBorder.none`
- `minLines: 3`, `maxLines: null` for multiline
- Save button uses `primary` color, shows `CircularProgressIndicator` while loading
- Uses isolated `Consumer<JournalProvider>` so only the button rebuilds on state change

### 3.12 `modules/dashboard/widgets/historical_entries_feed.dart`
- `ListView.builder` with `shrinkWrap: true` + `NeverScrollableScrollPhysics` (nested in `SingleChildScrollView`)
- Each entry rendered as a `Card` with `surfaceContainerHighest` color
- Tags and triggers combined and displayed as `Chip` widgets
- Date displayed at top of each card

### 3.13 `modules/dashboard/screens/dashboard_screen.dart`
Assembles the full dashboard layout in a `SingleChildScrollView`:
1. `InsightCard` (via `Consumer<InsightProvider>`)
2. `SentimentChart` (via `Consumer<JournalProvider>`)
3. `JournalInputField` (stateful, reads `JournalProvider`)
4. "Your Reflections" heading
5. `HistoricalEntriesFeed` (via `Consumer<JournalProvider>`)

Data is fetched on `initState` via `addPostFrameCallback`.

### 3.14 `main.dart`
- `MultiProvider` wrapping `MindMirrorApp` with `JournalProvider` and `InsightProvider`
- `MaterialApp` with `AppTheme.lightTheme`, `AppTheme.darkTheme`, `ThemeMode.system`
- Home set to `DashboardScreen`

---

## 4. Verification Status

| Check | Result |
|---|---|
| `flutter analyze` | ✅ **No issues found** |
| `flutter run -d windows` | ✅ **Builds and runs successfully** |
| All `withOpacity` deprecations | ✅ Replaced with `.withValues(alpha:)` |
| JSON contract compliance | ✅ Models match `docs/JSON_CONTRACT.md` exactly |
| MVC architecture compliance | ✅ Views are declarative, logic in Providers |
| Design system compliance | ✅ No hardcoded colors, all via `Theme.of(context)` |

---

## 5. Known Limitations & Technical Debt

1. **Sentiment Chart hover** — The `_indexFromX` method in `sentiment_chart.dart` currently returns `null` (the hit-testing stub). Full hover interaction requires access to the `RenderBox` size to map pixel coordinates to data indices.
2. **Mock data is thin** — Only 2 journal entries returned by `MockJournalService`. For a demo, expanding to 7–10 entries across a week would make the chart more visually compelling.
3. **`dio` is unused** — The package is declared but no real HTTP service exists yet. This is intentional per the Mock-First protocol.
4. **No error UI** — When a mock service throws, the Providers catch silently via `debugPrint`. A proper error state + fallback UI card should be added before the demo.
