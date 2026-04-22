# AI Books — Build Plan

> Fully offline MVP. No auth, no internet, no backend.
> 3 launch categories: Science, Business, Personal Development.
> Reference: [ai_books_flutter_product_spec.md](ai_books_flutter_product_spec.md)

---

## Phase 1 — Foundations

Goal: App shell runs, SQLite database works, seed content loads, theme skeleton in place.

- [x] 1.1 Create Flutter project (`ai_books`)
- [x] 1.2 Set up project folder structure — `lib/app/`, `lib/core/`, `lib/features/`, `lib/domain/`, `lib/data/`
- [x] 1.3 Add core dependencies to `pubspec.yaml` — `sqflite`, `path`, `flutter_riverpod`, `google_fonts`
- [x] 1.4 Create theme skeleton — `app_colors.dart`, `app_typography.dart`, `app_theme.dart` (light + dark)
- [x] 1.5 Set up SQLite database helper — singleton `DatabaseHelper`, create/open DB, onboarding check, clearAllData
- [x] 1.6 Define all SQLite table creation scripts — 8 tables + 6 indexes in `database_helper.dart`
- [x] 1.7 Create seed JSON files — `categories.json` (3), `books.json` (9), `checkpoints.json` (36) with real content
- [x] 1.8 Build JSON → SQLite seed loader — `seed_loader.dart`, runs on first launch via `_onCreate`
- [x] 1.9 Create domain models (plain Dart) — 7 models with toMap/fromMap: `UserProfile`, `CategoryEntry`, `BookEntry`, `CheckpointEntry`, `ReadingProgress`, `SavedItem`, `StreakRecord`
- [x] 1.10 Build app entry point with launch check — `app.dart` checks onboarding state → OnboardingFlow or MainShell
- [x] 1.11 Set up bottom navigation shell — 5 tabs wired to actual screens

**Phase 1 — COMPLETE**

---

## Phase 2 — Onboarding and Profile

Goal: User completes onboarding, profile is saved, recommendation is generated.

- [x] 2.1 Build onboarding flow container — `onboarding_flow.dart`, PageView with progress bar, back button, data collection
- [x] 2.2 Welcome screen — black bg, hero headline, "Get Started" button
- [x] 2.3 Interests selection screen — multi-select AiChip wrap, 8 options
- [x] 2.4 Goals selection screen — multi-select AiChip wrap, 7 options
- [x] 2.5 Areas to improve screen — multi-select AiChip wrap, 7 options
- [x] 2.6 Reading comfort screen — single-select cards: Beginner, Moderate, Advanced
- [x] 2.7 Daily time preference screen — single-select: 5, 10, 15, 20+ min
- [x] 2.8 Streak challenge screen — single-select: No challenge, 7, 14, 30 days
- [x] 2.9 Save onboarding to SQLite — `OnboardingService.saveOnboardingData()`, inserts user_profile row
- [x] 2.10 Build recommendation engine — `RecommendationService`, tag-based scoring (+3 interest, +2 goal, +1 improvement, +5 difficulty match)
- [x] 2.11 Recommendation result screen — now shows real book from recommendation engine
- [ ] 2.12 Enable reminders screen — deferred to Phase 4 (needs `flutter_local_notifications` platform setup)
- [x] 2.13 Profile screen — wired to SQLite, loads real interests/goals/improvements/stats
- [x] 2.14 Edit interests from profile — `EditInterestsScreen`, saves to SQLite, profile reloads on return

**Phase 2 — COMPLETE** (2.12 deferred to Phase 4)

---

## Phase 3 — Core Reading Experience

Goal: User can browse categories, open a book, read checkpoints, and resume where they left off.

- [x] 3.1 Library screen — category list with AiCategoryCard widgets
- [x] 3.2 Category detail screen — books grouped by difficulty sections
- [x] 3.3 Book detail screen — cover, metadata pills, why it matters, Start/Continue button
- [x] 3.4 Checkpoint reader screen — title, illustration, explanation, key quote, modern example, reflection
- [x] 3.5 Reader navigation — next button, progress indicator (3/6), bookmark button in fixed bottom bar
- [x] 3.6 Auto-save reading progress — `ProgressService.completeCheckpoint()` called on each "Next" tap in BookReaderFlow
- [x] 3.7 Continue reading from home — wired to SQLite via `ProgressService.getMostRecentProgress()`, navigates to BookDetailScreen
- [x] 3.8 Checkpoint complete card — shows real `recapText` from checkpoint data
- [x] 3.9 Book complete screen — shows checkpoint titles as gains, next book from `nextBookIds`
- [x] 3.10 Quote decode card in reader — shows real `keyQuote` from checkpoint data
- [x] 3.11 Update next recommendation after book completion — BookReaderFlow suggests next book from `nextBookIds`

**Phase 3 — COMPLETE**

---

## Phase 4 — Retention and Discovery

Goal: Home screen is the hub. Bookmarks, search, streaks, and reminders work.

- [x] 4.1 Home screen — wired to SQLite: real stats, continue reading, recommendations, categories
- [x] 4.2 Bookmark / save quotes — `BookmarkService` with toggle, save quote, remove. Wired in reader + bookmarks screen
- [x] 4.3 Saved screen — wired to SQLite, loads real quotes + bookmarks, swipe-to-dismiss
- [x] 4.4 Search screen — wired to SQLite, real search by title/author/category/goals
- [x] 4.5 Streak tracking — `StreakService` records daily activity, calculates consecutive streak days
- [x] 4.6 Local notification reminders — `NotificationService` with daily periodic reminders, opt-in toggle in settings
- [x] 4.7 Settings screen — notifications wired to DB + NotificationService, reset profile clears DB + restarts
- [x] 4.8 Reset profile — clears all SQLite data, re-seeds content, navigates to onboarding

**Phase 4 — COMPLETE**

---

## Phase 5 — Polish and Expansion

Goal: App feels finished. Edge cases handled. Ready for store submission.

- [ ] 5.1 Empty states — no books started, no bookmarks, no search results, fresh profile
- [ ] 5.2 Loading states — database loading, seed loading on first launch
- [ ] 5.3 Error handling — corrupted DB recovery, missing seed data graceful fallback
- [ ] 5.4 Accessibility pass — dynamic text sizing, contrast ratios, screen reader labels, tap targets
- [x] 5.5 Dark mode support (theme) — dark theme defined in `app_theme.dart`. Needs toggle wiring
- [ ] 5.6 Reduced motion mode — respect system setting, disable animations
- [ ] 5.7 Image optimization — compress bundled assets, device density variants
- [ ] 5.8 Content QA — proofread all seed content, verify checkpoint flow per book
- [ ] 5.9 Performance testing — cold launch < 3s, home render < 1s, smooth scrolling
- [ ] 5.10 App icon and splash screen — final branding assets
- [ ] 5.11 Store metadata — screenshots, description, keywords

---

## Content Tracker

- [x] Science — 3 books, 12 checkpoints (Brief History of Time, Sapiens, The Selfish Gene)
- [x] Business — 3 books, 12 checkpoints (Atomic Habits, The Lean Startup, Zero to One)
- [x] Personal Development — 3 books, 12 checkpoints (Courage to Be Disliked, Meditations, Man's Search for Meaning)

---

## Blocked / Waiting

- [x] ~~Seed content~~ — done with placeholder data (9 books, 36 checkpoints)
- [ ] Image assets (covers, icons, illustrations) — waiting on user (since 2026-04-16)
- [ ] App icon and splash — waiting on user (since 2026-04-16)

---

## Decisions Log

| Date | Decision | Rationale |
|---|---|---|
| 2026-04-16 | Fully offline v1, no auth | Fastest to ship, no backend dependency, add accounts later |
| 2026-04-16 | Simplified book content, not full books | Core differentiator — Gen Z-friendly checkpoints, not ebook reader |
| 2026-04-16 | Full library always accessible | Recommendations guide but don't gate access |
| 2026-04-16 | SQLite with sqflite | Simple, no code gen overhead, raw SQL control |
| 2026-04-16 | Drop GoRouter, use built-in Navigator | App navigation is simple — one launch check + tab bar |
| 2026-04-16 | 3 launch categories | Science, Business, Personal Development |
| 2026-04-16 | Local notifications only | No push server, no internet dependency |
| 2026-04-16 | Tag-based recommendation engine | Match onboarding answers against book interestTags, goalTags, improvementTags |
| 2026-04-16 | Apple-inspired design system | DESIGN.md: dark/light sections, Apple Blue accent, SF Pro typography, pill CTAs |
| 2026-04-16 | Switched to Luxury dark design | SKILL.md: pure black surface, #FAFAFA primary, Oswald headings, sharp edges, monochromatic, gold accent |
| 2026-04-22 | Switched to Speedread cinematic design | Claude Design HTML prototype: deep cinematic dark #0A0A0C, Fraunces serif + Space Grotesk, per-book accent palettes, vertical progress rails, typographic book covers, floating glass pill tab bar |

---

## Tech Stack Summary

| Layer | Choice |
|---|---|
| Framework | Flutter |
| State Management | flutter_riverpod |
| Navigation | Flutter built-in Navigator |
| Database | sqflite (SQLite) |
| Fonts | google_fonts (Oswald) |
| Notifications | flutter_local_notifications |
| Models | freezed + json_serializable |
| Network | None (fully offline) |
| Auth | None (v1) |

---

## All Screens Built

- [x] Welcome — `features/onboarding/screens/welcome_screen.dart`
- [x] Interests — `features/onboarding/screens/interests_screen.dart`
- [x] Goals — `features/onboarding/screens/goals_screen.dart`
- [x] Areas to Improve — `features/onboarding/screens/improve_screen.dart`
- [x] Reading Comfort — `features/onboarding/screens/reading_comfort_screen.dart`
- [x] Daily Time — `features/onboarding/screens/daily_time_screen.dart`
- [x] Streak Challenge — `features/onboarding/screens/streak_screen.dart`
- [x] Recommendation — `features/onboarding/screens/recommendation_screen.dart`
- [x] Onboarding Flow — `features/onboarding/screens/onboarding_flow.dart`
- [x] Home — `features/home/screens/home_screen.dart`
- [x] Library — `features/library/screens/library_screen.dart`
- [x] Category Detail — `features/library/screens/category_detail_screen.dart`
- [x] Book Detail — `features/book_detail/screens/book_detail_screen.dart`
- [x] Reader — `features/reader/screens/reader_screen.dart`
- [x] Checkpoint Complete — `features/reader/screens/checkpoint_complete_screen.dart`
- [x] Book Complete — `features/reader/screens/book_complete_screen.dart`
- [x] Search — `features/search/screens/search_screen.dart`
- [x] Bookmarks / Saved — `features/bookmarks/screens/bookmarks_screen.dart`
- [x] Profile — `features/profile/screens/profile_screen.dart`
- [x] Settings — `features/settings/screens/settings_screen.dart`

## Reusable Widgets

- [x] AiChip — `core/widgets/ai_chip.dart`
- [x] AiBookCard — `core/widgets/ai_book_card.dart`
- [x] AiCategoryCard — `core/widgets/ai_category_card.dart`
- [x] AiProgressBar — `core/widgets/ai_progress_bar.dart`
- [x] ContinueReadingCard — `features/home/widgets/continue_reading_card.dart`

## Theme Files

- [x] `app/theme/app_colors.dart` — Luxury dark color palette (surface #000, primary #FAFAFA, accent gold)
- [x] `app/theme/app_typography.dart` — Oswald display font, bold headings, uppercase labels
- [x] `app/theme/app_theme.dart` — Dark-only ThemeData with sharp edges, monochromatic

---

## Progress Summary

| Phase | Done | Total | % |
|---|---|---|---|
| Phase 1 — Foundations | 11 | 11 | 100% |
| Phase 2 — Onboarding | 13 | 14 | 93% |
| Phase 3 — Reading | 11 | 11 | 100% |
| Phase 4 — Retention | 9 | 9 | 100% |
| Phase 5 — Polish | 1 | 11 | 9% |
| **Total** | **45** | **56** | **80%** |
