# Speedread

A mobile-first Flutter learning app (Blinkist-style, Gen Z 16–30) that turns major nonfiction books into simplified, checkpoint-based reading experiences. Fully offline — no auth, no backend, no internet required.

## What it does

- 9 launch books across **Science**, **Business**, and **Personal Development**
- 4–8 checkpoints per book (hook → core idea → modern example → reflection)
- Per-book typographic covers and accent palettes (Speedread cinematic dark design)
- Tag-based recommendation engine driven by onboarding answers
- Streak tracking, bookmark/quote saving, local daily reminders
- Native mind map renderer (responsive: outline on phones, tree on tablets)

## Tech stack

| Layer | Choice |
|---|---|
| Framework | Flutter (Dart SDK ^3.11.0) |
| Database | `sqflite` (raw SQL, plain Dart models with manual `toMap`/`fromMap`) |
| State | `setState` + service classes (no Riverpod / Bloc) |
| Navigation | Built-in `Navigator` (no GoRouter) |
| Fonts | `google_fonts`: Space Grotesk (display) + Inter (body) |
| Notifications | `flutter_local_notifications` |
| Network | None (fully offline) |

## Run

```bash
flutter pub get
flutter run

# Tests / lint
flutter test
flutter analyze

# Release builds
flutter build apk
flutter build ios
```

## Repo structure

```
lib/
  app/             theme, app shell, main shell
  core/            storage (sqflite + seed loader), notifications, shared widgets
  domain/          plain Dart models + services (content, progress, bookmarks, streak, recs)
  features/        screens grouped by feature (onboarding, home, library, reader, profile…)
assets/
  seed/            categories.json, books.json, checkpoints.json
  images/covers/   per-book cover images
  images/illustrations/  per-checkpoint illustrations
  mindmaps/        per-book mind map .md / .html files
```

## Reference docs

- [plan.md](plan.md) — build phases, progress, decisions log
- [db-loader-steps.md](db-loader-steps.md) — how to add categories, books, checkpoints, images, and `.md` explanations
- [visuals_plan.md](visuals_plan.md) — how mind maps and per-checkpoint illustrations are wired
- [ai_books_flutter_product_spec.md](ai_books_flutter_product_spec.md) — full product spec
- [CLAUDE.md](CLAUDE.md) — guidance for Claude Code in this repo
