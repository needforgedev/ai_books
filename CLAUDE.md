# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AI Books is a mobile-first Flutter learning app (Blinkist-style, targeted at Gen Z ages 16-30) that turns major nonfiction books into simplified, checkpoint-based reading experiences. Currently in early scaffolding — only the default counter demo exists in `lib/main.dart`. The full product spec is in `ai_books_flutter_product_spec.md`.

## Build & Development Commands

```bash
# Run the app
flutter run

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze code (linting)
flutter analyze

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

## Tech Stack & Configuration

- **Dart SDK**: ^3.11.0, **Flutter SDK**: >=3.18.0
- **Linting**: `flutter_lints` (v6) via `analysis_options.yaml`
- **State management**: None yet (only `setState` in demo)
- **Code generation**: None yet (no build_runner/freezed)
- **Android namespace**: `com.example.ai_books`
- **All platforms enabled**: Android, iOS, Web, Linux, macOS, Windows

## Architecture

The app is scaffolding-only. No architecture pattern has been established yet. The product spec calls for: user auth, onboarding flow, content library with categories/books/checkpoints, reading progress tracking, personalized recommendations, and streak/habit mechanics. These will need a state management solution and likely a local database.
