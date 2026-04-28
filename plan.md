# Speedread (ai_books) — Build Plan

> Fully offline MVP. No auth, no internet, no backend.
> 3 launch categories: Science, Business, Personal Development.
> Reference: [ai_books_flutter_product_spec.md](ai_books_flutter_product_spec.md)
> Companion docs: [db-loader-steps.md](db-loader-steps.md), [visuals_plan.md](visuals_plan.md)

---

## Phase 1 — Foundations

Goal: App shell runs, SQLite database works, seed content loads, theme skeleton in place.

- [x] 1.1 Create Flutter project (`ai_books`)
- [x] 1.2 Set up project folder structure — `lib/app/`, `lib/core/`, `lib/features/`, `lib/domain/`
- [x] 1.3 Add core dependencies to `pubspec.yaml` — `sqflite`, `path`, `google_fonts`, `flutter_local_notifications`
- [x] 1.4 Create theme — `app_colors.dart`, `app_typography.dart`, `app_theme.dart` (Speedread cinematic dark)
- [x] 1.5 Set up SQLite database helper — singleton `DatabaseHelper`, create/open DB, onboarding check, clearAllData
- [x] 1.6 Define all SQLite table creation scripts — 8 tables + 6 indexes in `database_helper.dart`
- [x] 1.7 Create seed JSON files — `categories.json` (3), `books.json` (9), `checkpoints.json` (36) with real content
- [x] 1.8 Build JSON → SQLite seed loader — `seed_loader.dart`, runs on first launch via `_onCreate`
- [x] 1.9 Create domain models (plain Dart) — 8 models with toMap/fromMap: `UserProfile`, `CategoryEntry`, `BookEntry`, `CheckpointEntry`, `ReadingProgress`, `SavedItem`, `StreakRecord`, `MindMapNode`
- [x] 1.10 Build app entry point with launch check — `app.dart` shows splash → checks onboarding state → OnboardingFlow or MainShell
- [x] 1.11 Set up bottom navigation shell — 4-tab floating glass pill: Home, Library, Saved, You

**Phase 1 — COMPLETE**

---

## Phase 2 — Onboarding and Profile

Goal: User completes onboarding, profile is saved, recommendation is generated.

- [x] 2.1 Splash screen — `splash_screen.dart`, accent rails + wordmark, ~1.8s display while DB inits
- [x] 2.2 Welcome screen — `welcome_screen.dart`, layered hero book covers, italic accent headline
- [x] 2.3 Onboarding flow container — `onboarding_flow.dart`, PageView with progress bar + back button
- [x] 2.4 Name input — `name_input_screen.dart`, text field, saves to `display_name`
- [x] 2.5 Generic question screen — `onboarding_question_screen.dart`, drives the 3 selection steps
- [x] 2.6 Interests selection — multi-select chips, 10 options
- [x] 2.7 Goals selection — multi-select chips, 8 options
- [x] 2.8 Reading comfort — single-select cards: Beginner / Moderate / Advanced
- [x] 2.9 Save onboarding to SQLite — `OnboardingService.saveOnboardingData()`, inserts user_profile row with display_name
- [x] 2.10 Recommendation engine — `RecommendationService`, tag-based scoring (+3 interest, +2 goal, +1 improvement, +5 difficulty match)
- [x] 2.11 Recommendation result screen — shows real book + reason from engine. No-match empty state routes to Library
- [x] 2.12 "See 2 other picks" — modal bottom sheet with alternates; tap to promote to primary
- [x] 2.13 Profile screen — wired to SQLite: real name, reading comfort, real streak (`StreakService.getCurrentStreak`), books finished count, week activity calendar, category progress bars
- [x] 2.14 Edit interests from profile — `edit_interests_screen.dart`, saves to SQLite, profile reloads on return

**Phase 2 — COMPLETE**

> Note: a separate "enable reminders" onboarding step was dropped — notifications are opt-in via Settings instead, which avoids forcing a permission prompt during onboarding.

---

## Phase 3 — Core Reading Experience

Goal: User can browse categories, open a book, read checkpoints, and resume where they left off.

- [x] 3.1 Library screen — `library_screen.dart`, real category list + featured grid, tappable search bar that pushes SearchScreen
- [x] 3.2 Category detail screen — `category_detail_screen.dart`, books grouped by difficulty
- [x] 3.3 Book detail screen — `book_detail_screen.dart`, cover, metadata, why-it-matters, "Start/Continue reading"
- [x] 3.4 Reading flow — `book_reader_flow.dart`, full reader: per-book palette, vertical progress rail, hook + explanation + image (if set) + modern example + accent quote pull + reflection prompt
- [x] 3.5 Auto-save reading progress — `ProgressService.completeCheckpoint()` called on each Next, with streak activity
- [x] 3.6 Continue reading from home — wired to SQLite via `ProgressService.getMostRecentProgress()`
- [x] 3.7 Quote Decode screen — `quote_decode_screen.dart`, scrollable, italic centered quote, "What this means" card, save / continue
- [x] 3.8 Checkpoint Complete screen — `checkpoint_complete_screen.dart`, shows real `recapText`
- [x] 3.9 Book Complete screen — `book_complete_screen.dart`, animated medal, takeaway quote, FLEX-WORTHY share card, NEXT book CTA, demoted "Back home · Save"
- [x] 3.10 Share Sheet — `share_sheet.dart`, modal bottom sheet with live poster preview, real `@handle` from display_name, editable caption, 5 platform tiles
- [x] 3.11 Update next recommendation after book completion — BookReaderFlow suggests next book from `nextBookIds`, "Back home" lands user on Home tab via `MainShell.goToTab`

**Phase 3 — COMPLETE**

---

## Phase 4 — Retention and Discovery

Goal: Home is the hub. Bookmarks, search, streaks, and reminders work.

- [x] 4.1 Home screen — `home_screen.dart`, wired to SQLite: real stats, continue reading, recommendations, categories
- [x] 4.2 Bookmark / save quotes — `BookmarkService` (toggle, saveQuote, getQuotes/Bookmarks, removeSaved). Wired in reader's bookmark icon + Quote Decode "Save quote"
- [x] 4.3 Saved screen — `bookmarks_screen.dart`, real quotes + bookmarks from SQLite, swipe-to-dismiss, refreshes when Saved tab is tapped (via ValueNotifier)
- [x] 4.4 Search screen — `search_screen.dart`, real SQLite search by title/author/category/goals; reachable from Library tab's search bar
- [x] 4.5 Streak tracking — `StreakService.recordActivity` per checkpoint completion, `getCurrentStreak` calculates consecutive days
- [x] 4.6 Local notification reminders — `NotificationService` with daily reminder via `periodicallyShow`, opt-in toggle in Settings (limitations noted in Phase 6)
- [x] 4.7 Settings screen — `settings_screen.dart`, notifications wired to DB + NotificationService, reset profile clears DB + restarts
- [x] 4.8 Reset profile — clears SQLite, re-seeds content, navigates to onboarding

**Phase 4 — COMPLETE**

---

## Phase 5 — Visuals Infrastructure (mind maps + per-checkpoint images)

Goal: A clean offline-only path to ship per-book mind maps and per-checkpoint illustrations whenever real assets are ready.

- [x] 5.1 Schema — `mindmap_asset_path` column on `books` table, `image_asset_or_url` already on `checkpoints`
- [x] 5.2 `BookEntry.mindmapAssetPath` field threaded through model, seed loader, ContentService
- [x] 5.3 Asset folders registered in `pubspec.yaml`: `assets/mindmaps/`, `assets/images/illustrations/`, `assets/images/covers/`
- [x] 5.4 `MindMapParser` — extracts the `<script type="text/template">` block from markmap-format HTML and parses headings + bullets into a `MindMapNode` tree (also accepts plain `.md`)
- [x] 5.5 `MindMapView` — native horizontal interactive tree using `InteractiveViewer` (pinch-zoom + pan), tap-to-expand, fork connectors, per-book accent color
- [x] 5.6 `MindMapOutlineView` — native vertical Notion-style outline, ideal for phones
- [x] 5.7 `MindMapScreen` — responsive: outline on phones (< 600dp), tree on tablets/desktop, with a top-bar toggle to switch
- [x] 5.8 Reader integration — checkpoint image renders below `explanationText` when `imageAssetOrUrl` is set; mind map teaser card appears on the last checkpoint when `mindmapAssetPath` is set
- [x] 5.9 Demo assets removed — infrastructure stays in place, real assets can be dropped in later (see [visuals_plan.md](visuals_plan.md))

**Phase 5 — COMPLETE** (infrastructure ready; real visual assets pending content)

---

## Phase 6 — Production Polish (NOT YET DONE)

Goal: App feels finished. Edge cases handled. Ready for store submission.

### Visible stubs to fix or remove

- [ ] 6.1 Premium "Go Gold" card on Profile — remove for v1 (no real subscription system) OR collect waitlist email
- [ ] 6.2 `+120 INSIGHT` on Book Complete — hardcoded fake. Either compute dynamically or remove the stat
- [ ] 6.3 Top-bar bookmark icon on Book Detail — currently `onTap: () {}` no-op. Wire up or hide
- [ ] 6.4 "Save win" demoted link on Book Complete — currently snackbar only. Either implement book-level bookmark or remove
- [ ] 6.5 Real share — `share_sheet.dart` Share to X currently snackbar. Needs `share_plus` + `RepaintBoundary.toImage` for poster export

### Platform / store readiness

- [ ] 6.6 App icon — replace default Flutter "F" on iOS + Android
- [ ] 6.7 Native splash — currently shows white Flutter splash before the custom `SplashScreen` widget. Use `flutter_native_splash` for consistency
- [ ] 6.8 Android `POST_NOTIFICATIONS` permission — declare in `AndroidManifest.xml` (silently fails on Android 13+)
- [ ] 6.9 iOS `NSUserNotificationsUsageDescription` — confirm in `Info.plist`
- [ ] 6.10 Real notification scheduling — replace `periodicallyShow` (24h interval from toggle-on) with `zonedSchedule` for true time-of-day delivery
- [ ] 6.11 Streak minutes — `recordActivity(additionalMinutes: 0)` is always 0 today. Track real minutes or remove the field from the model
- [ ] 6.12 App icon variants and adaptive icons (Android)

### Robustness

- [ ] 6.13 Empty states — fresh user with 0 saved items, 0 books finished, 0 streak, no continue reading
- [ ] 6.14 Loading states — beyond the splash, show skeletons / shimmers during async loads
- [ ] 6.15 Error states — DB open failure, missing book, missing checkpoint, corrupted seed
- [ ] 6.16 Accessibility pass — semantic labels, dynamic text scale, contrast on translucent overlays, tap-target sizes on demoted text buttons
- [ ] 6.17 Reduced-motion mode — respect `MediaQuery.disableAnimations`, freeze the rotating rays / particles
- [ ] 6.18 Performance — measure cold launch (target <3s), home render (<1s), scroll smoothness on book complete and reader

### Test coverage

- [ ] 6.19 Service unit tests — `OnboardingService`, `ProgressService`, `BookmarkService`, `StreakService`, `RecommendationService`
- [ ] 6.20 Database integration tests — seed loader, schema migrations, reset flow
- [ ] 6.21 Widget tests — at minimum onboarding flow, reader navigation, mind map rendering

### Store submission

- [ ] 6.22 Store metadata — title, subtitle, description, keywords, age rating
- [ ] 6.23 Screenshots — phone (6.7", 6.5", 5.5") + iPad (12.9", 11")
- [ ] 6.24 Privacy policy + privacy "nutrition labels" (App Store)
- [ ] 6.25 TestFlight / Play Console internal testing track

---

## Content Tracker

- [x] Science — 3 books, 12 checkpoints (Brief History of Time, Sapiens, The Selfish Gene)
- [x] Business — 3 books, 12 checkpoints (Atomic Habits, The Lean Startup, Zero to One)
- [x] Personal Development — 3 books, 12 checkpoints (Courage to Be Disliked, Meditations, Man's Search for Meaning)
- [ ] Real book content (replace seeded placeholder content) — on hold per user
- [ ] Per-book mind map HTML files in `assets/mindmaps/` — infrastructure ready, awaiting content
- [ ] Per-checkpoint illustration images in `assets/images/illustrations/` — infrastructure ready, awaiting content
- [ ] Per-book cover images in `assets/images/covers/` — infrastructure ready, awaiting content

---

## Decisions Log

| Date | Decision | Rationale |
|---|---|---|
| 2026-04-16 | Fully offline v1, no auth | Fastest to ship, no backend dependency, add accounts later |
| 2026-04-16 | Simplified book content, not full books | Core differentiator — Gen Z-friendly checkpoints, not ebook reader |
| 2026-04-16 | Full library always accessible | Recommendations guide but don't gate access |
| 2026-04-16 | SQLite with `sqflite` (no `drift`/`freezed`) | Simple, no code-gen overhead, raw SQL control. Plain Dart models with manual `toMap` / `fromMap` |
| 2026-04-16 | Drop `go_router`, use built-in `Navigator` | App navigation is simple — one launch check + tab bar |
| 2026-04-16 | 3 launch categories | Science, Business, Personal Development |
| 2026-04-16 | Local notifications only | No push server, no internet dependency |
| 2026-04-16 | Tag-based recommendation engine | Match onboarding answers against book interestTags, goalTags, improvementTags |
| 2026-04-22 | Speedread cinematic design | Claude Design HTML prototype: `#0A0A0C` surface, Crimson `#FF3B3B` default accent, per-book accent palettes, vertical progress rails, typographic book covers, floating glass pill tab bar |
| 2026-04-22 | Modern Streaming font pair | Space Grotesk for display, Inter for body. Replaced Fraunces + Space Grotesk |
| 2026-04-22 | 4-tab navigation (drop Search tab) | Home / Library / Saved / You. Search is reachable from Library |
| 2026-04-23 | Native mind map renderer (no WebView) | Better mobile UX, dark theme matched, no JS deps. Outline view on phones, horizontal tree on tablets |
| 2026-04-23 | Replaced 6 individual onboarding question screens with one generic `OnboardingQuestionScreen` | Less duplication, easier to maintain |

---

## Tech Stack Summary

| Layer | Choice |
|---|---|
| Framework | Flutter (Dart SDK ^3.11.0) |
| State Management | `setState` + service classes (no Riverpod, no Bloc) |
| Navigation | Flutter built-in `Navigator` (no GoRouter) |
| Database | `sqflite` (raw SQL, plain service classes acting as DAOs) |
| Models | Plain Dart classes with manual `toMap` / `fromMap` (no `freezed`, no codegen, no `.g.dart`) |
| Fonts | `google_fonts`: Space Grotesk (display), Inter (body) |
| Notifications | `flutter_local_notifications` |
| Network | None (fully offline) |
| Auth | None (v1) |
| Encryption | None (no `sqflite_sqlcipher`) |

---

## All Screens Built

### Onboarding (5)
- [x] Splash — `features/onboarding/screens/splash_screen.dart`
- [x] Welcome — `features/onboarding/screens/welcome_screen.dart`
- [x] Onboarding Flow (container) — `features/onboarding/screens/onboarding_flow.dart`
- [x] Name Input — `features/onboarding/screens/name_input_screen.dart`
- [x] Generic Onboarding Question — `features/onboarding/screens/onboarding_question_screen.dart` (drives Interests, Goals, Reading Comfort)
- [x] Recommendation Result — `features/onboarding/screens/recommendation_screen.dart` (with no-match empty state)

### Main shell (4 tabs)
- [x] Home — `features/home/screens/home_screen.dart`
- [x] Library — `features/library/screens/library_screen.dart`
- [x] Bookmarks / Saved — `features/bookmarks/screens/bookmarks_screen.dart`
- [x] Profile — `features/profile/screens/profile_screen.dart`

### Reading
- [x] Category Detail — `features/library/screens/category_detail_screen.dart`
- [x] Book Detail — `features/book_detail/screens/book_detail_screen.dart`
- [x] Book Reader Flow — `features/reader/screens/book_reader_flow.dart` (the actual reader)
- [x] Quote Decode — `features/reader/screens/quote_decode_screen.dart`
- [x] Checkpoint Complete — `features/reader/screens/checkpoint_complete_screen.dart`
- [x] Book Complete — `features/reader/screens/book_complete_screen.dart`
- [x] Share Sheet (modal) — `features/reader/screens/share_sheet.dart`
- [x] Mind Map — `features/reader/screens/mindmap_screen.dart` (responsive: outline on phones, tree on tablets)

### Other
- [x] Search — `features/search/screens/search_screen.dart`
- [x] Edit Interests — `features/profile/screens/edit_interests_screen.dart`
- [x] Settings — `features/settings/screens/settings_screen.dart`

## Reusable Widgets

- [x] `book_cover.dart` — typographic per-book cover with palette + spine rail option
- [x] `progress_rail.dart` — vertical/horizontal segmented spine
- [x] `floating_tab_bar.dart` — glass pill 4-tab nav
- [x] `radial_glow.dart` — atmospheric accent glow
- [x] `mindmap_view.dart` — horizontal interactive tree
- [x] `mindmap_outline_view.dart` — vertical Notion-style outline
- [x] `continue_reading_card.dart` — home tab card
- [x] `ai_chip.dart` — selection chip (used by edit interests)
- [x] `ai_progress_bar.dart` — used by continue_reading_card

## Theme Files

- [x] `app/theme/app_colors.dart` — Speedread cinematic dark palette
  - Surface `#0A0A0C`, default accent Crimson `#FF3B3B`, per-book palettes via `BookVisuals`
- [x] `app/theme/app_typography.dart` — Space Grotesk (display) + Inter (body) via `google_fonts`
- [x] `app/theme/app_theme.dart` — Dark `ThemeData`, rounded 16-22px corners, accent buttons, glass nav

## Domain Models

- [x] `book_entry.dart` (incl. `mindmapAssetPath`)
- [x] `category_entry.dart`
- [x] `checkpoint_entry.dart` (incl. `imageAssetOrUrl`)
- [x] `mindmap_node.dart`
- [x] `reading_progress.dart`
- [x] `saved_item.dart`
- [x] `streak_record.dart`
- [x] `user_profile.dart`
- [x] `models.dart` — barrel export

## Domain Services

- [x] `bookmark_service.dart` — quotes + checkpoint bookmarks
- [x] `content_service.dart` — categories / books / checkpoints reads
- [x] `mindmap_parser.dart` — markmap HTML/Markdown → tree
- [x] `onboarding_service.dart` — user_profile CRUD
- [x] `progress_service.dart` — reading_progress CRUD + queries
- [x] `recommendation_service.dart` — tag-match scoring engine
- [x] `streak_service.dart` — daily activity + consecutive streak

## Storage / Notifications

- [x] `core/storage/database_helper.dart` — singleton, 8 tables + 6 indexes
- [x] `core/storage/seed_loader.dart` — JSON → SQLite on first run
- [x] `core/notifications/notification_service.dart` — plugin wrapper

---

## Progress Summary

| Phase | Done | Total | % |
|---|---|---|---|
| Phase 1 — Foundations | 11 | 11 | 100% |
| Phase 2 — Onboarding | 14 | 14 | 100% |
| Phase 3 — Reading | 11 | 11 | 100% |
| Phase 4 — Retention | 8 | 8 | 100% |
| Phase 5 — Visuals Infrastructure | 9 | 9 | 100% |
| Phase 6 — Production Polish | 0 | 25 | 0% |
| **Total** | **53** | **78** | **~68%** |

Production readiness: ~75%. The user-facing app is feature-complete; the gap is platform polish (icons, splash, real notifications), visible stubs (premium card, "+120 insight"), and store-readiness (a11y, perf, tests). See Phase 6 for the punch list.
