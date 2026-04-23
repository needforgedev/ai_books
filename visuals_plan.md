# Visuals Plan — Mind Maps, Images, and Long Books

> How to add visual content (book covers, illustrations, mind map HTMLs) to the app while keeping it **fully offline** on both iOS and Android.
> Companion to [db-loader-steps.md](db-loader-steps.md) and [plan.md](plan.md).

---

## The Approach — Option A: Fully Offline Bundled Assets

All content ships inside the app binary. No server, no downloads, no internet required at any point.

- **Images** (covers, illustrations) → bundled in `assets/images/`
- **Mind map HTMLs** → bundled in `assets/mindmaps/`
- **PDFs** → **not shipping**. Long-book content is handled via expanded checkpoints + mind maps (see below)

---

## Asset Layout

```
assets/
  seed/
    categories.json
    books.json
    checkpoints.json
  images/
    covers/
      atomic_habits.jpg
      meditations.jpg
      ...
    illustrations/
      atomic_habits_cp1.jpg
      meditations_cp3.jpg
      ...
  mindmaps/
    lib/                              ← shared JS engine (one-time vendoring)
      d3.min.js                       (~270 KB)
      markmap-view.min.js             (~80 KB)
      markmap-autoloader.min.js       (~10 KB)
    atomic_habits.html                ← one HTML per book
    meditations.html
    psych_money.html
    ...
```

Register all of these in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/seed/
    - assets/images/covers/
    - assets/images/illustrations/
    - assets/mindmaps/
    - assets/mindmaps/lib/
```

---

## Part 1 — Book Cover Images

### Specs

| Property | Value |
|---|---|
| Format | JPG or PNG |
| Size per file | Under 200 KB |
| Dimensions | ~400x600px (2:3 portrait ratio) |
| Naming | Must match the book `id` in `books.json`. e.g. `atomic_habits.jpg` |
| Location | `assets/images/covers/` |

### Wiring to the book

In `books.json`, set the `cover_image` field to the asset path:

```json
{
  "id": "atomic_habits",
  "cover_image": "assets/images/covers/atomic_habits.jpg",
  ...
}
```

If `cover_image` is `null`, the app falls back to a typographic cover generated from the book's palette (which is what ships today for seeded books without real covers).

### Fallback behavior

The `BookCover` widget already handles both cases. Leave `cover_image` null for any book without a real cover — the generated typographic cover looks good on its own.

---

## Part 2 — Checkpoint Illustrations

Per-checkpoint images that appear in the reader alongside the explanation.

### Specs

| Property | Value |
|---|---|
| Format | JPG or PNG (PNG for transparent backgrounds) |
| Size per file | Under 300 KB |
| Dimensions | ~1200x800px (3:2 landscape) |
| Naming | `{book_id}_cp{number}.jpg` — matches the checkpoint id pattern |
| Location | `assets/images/illustrations/` |

### Wiring to the checkpoint

In `checkpoints.json`, set the `image_asset_or_url` field:

```json
{
  "id": "atomic_habits_cp1",
  "image_asset_or_url": "assets/images/illustrations/atomic_habits_cp1.jpg",
  ...
}
```

Leave `null` for checkpoints without an illustration — the reader already handles both cases.

### Total size budget

For a full library (10 books × 4-12 checkpoints × 300 KB) = ~15-35 MB worst case. Acceptable for a content-first app.

---

## Part 3 — Mind Maps (The Interesting Part)

Each book can optionally have a mind map — an interactive HTML file that shows the book's structure as an expandable tree. Users pan, zoom, and click nodes to expand.

### What a mind map HTML looks like

Each file is a self-contained HTML document (similar to the Harry Potter example) with:
- Embedded CSS for typography + colors
- An inline `<script type="text/template">` block containing the outline in Markdown
- A `<script src>` tag that loads the **markmap** library (the engine that turns the outline into a drawn mind map)

The library does all the rendering — you only write the outline content.

### The JS Vendoring Step (one-time)

Mind map HTMLs as-written point to `cdn.jsdelivr.net` for the JS engine. That breaks offline. You must **vendor** the JS:

1. **Download these 3 files once** (from your browser, save as):
   - `https://cdn.jsdelivr.net/npm/d3@7` → `d3.min.js`
   - `https://cdn.jsdelivr.net/npm/markmap-view@0.18` → `markmap-view.min.js`
   - `https://cdn.jsdelivr.net/npm/markmap-autoloader@0.18` → `markmap-autoloader.min.js`

2. **Put them in `assets/mindmaps/lib/`** and commit.

3. **In every mind map HTML**, replace this line:
   ```html
   <script src="https://cdn.jsdelivr.net/npm/markmap-autoloader@0.18"></script>
   ```
   with this:
   ```html
   <script src="./lib/markmap-autoloader.min.js"></script>
   ```

One ritual, done forever. Every future mind map you add just drops into `assets/mindmaps/{book_id}.html` with that line already corrected.

### Why vendoring is necessary

- The HTML file bundled in your app is just text
- That text contains an **instruction** telling the WebView to fetch the JS engine from the internet
- No internet = no engine download = blank screen
- Vendoring = replace the "fetch from internet" instruction with "load from my own assets folder"

### Adding a mind map for a book

1. Write or generate the mind map HTML file (the outline structure — see the Harry Potter example)
2. Rewrite the `<script src>` tag to the local path (see vendoring step 3)
3. Drop it in `assets/mindmaps/{book_id}.html`
4. Add a `mindmap_asset_path` field to the book in `books.json`:
   ```json
   {
     "id": "atomic_habits",
     "mindmap_asset_path": "assets/mindmaps/atomic_habits.html",
     ...
   }
   ```
   (This field doesn't exist in the schema yet — see "Schema changes needed" below)

### Rendering in the app

The app will need:

- **Package**: `flutter_inappwebview`
  - Renders in-app on both iOS (WKWebView) and Android (WebView)
  - Supports direct asset loading via `loadFile('assets/mindmaps/xxx.html')` — no copy-to-disk step
  - Maintained, MIT-licensed, standard choice for this use case

- **A new screen**: `MindMapScreen(assetPath: String)`
  - Full-screen `Scaffold` with back button overlay + book title
  - `InAppWebView` fills the body
  - Loads the HTML from assets — WebView resolves relative paths to `./lib/*.js` automatically

- **A button on Book Detail**: "View mind map" — only shown if `mindmap_asset_path != null`

- **A safety net**: Use `shouldOverrideUrlLoading` to block any non-`file://` navigation so stray links can never leave the app

### iOS + Android behavior

| Concern | iOS | Android |
|---|---|---|
| Renders in-app (no Safari/Chrome jump) | ✓ WKWebView | ✓ WebView |
| Loads local JS from assets | ✓ | ✓ |
| JavaScript enabled by default | ✓ | ✓ |
| Airplane mode works | ✓ (after vendoring) | ✓ (after vendoring) |
| App Transport Security / cleartext | Not relevant (`file://` only) | Not relevant (`file://` only) |
| Min version | iOS 12+ (your min) | Android 5+ (your min) |

### Size cost

- Shared JS engine: ~360 KB total (one copy for all mind maps)
- Each mind map HTML: ~15-40 KB
- For 10 books: ~400 + (10 × 25) = **~650 KB total**

Negligible compared to images.

---

## Part 4 — Long Books (30-40+ pages) Without PDFs

We're skipping PDFs. Here's how long books fit the checkpoint model instead.

### The model

**A long book = more checkpoints with longer content per checkpoint.**

- Today: ~4-8 checkpoints × 5 sentences each = ~15 min total read
- For long books: ~10-15 checkpoints × 3-5 paragraphs each = ~45 min total read

The `explanation_text` column in SQLite is `TEXT` with no practical length limit. The reader's `SingleChildScrollView` handles long content with no UI changes.

### Pattern — when to break a book into more checkpoints

- A 200-page non-fiction book (e.g. *Atomic Habits*) → 8-10 checkpoints, 3-4 paragraphs each
- A 300-page memoir (e.g. *Can't Hurt Me*) → 10-12 checkpoints, 4-5 paragraphs each
- A dense classic (e.g. *Meditations*) → 10-15 checkpoints mapped to thematic clusters (not chapter-by-chapter)
- A giant work (e.g. *Sapiens*) → 12-15 checkpoints, each covering one of the book's big arguments

### The reader + mind map combo

The winning UX for long books is **both** checkpoint content AND a mind map:

- **Checkpoints** = the guided walking tour — simplified content, read in sequence, 3-5 min per stop
- **Mind map** = the full outline/bird's-eye view — user taps the "View mind map" button any time to see the whole book's structure, then returns to where they left off

Together these cover both "I want to learn the ideas" and "I want to see the whole picture" — without needing a 400-page PDF.

---

## Schema Changes Needed

### `books` table — add one nullable column

```sql
ALTER TABLE books ADD COLUMN mindmap_asset_path TEXT;
```

And in the `books.json` seed:

```json
{
  "id": "atomic_habits",
  "mindmap_asset_path": "assets/mindmaps/atomic_habits.html",
  ...
}
```

### `seed_loader.dart` — no change required

The loader maps every JSON field to the matching column; adding `mindmap_asset_path` to both sides "just works."

### `BookEntry` model — add one field

```dart
final String? mindmapAssetPath;
```

Update `fromMap` / `toMap` to read/write the new column.

### That's it

Covers and illustrations use existing columns (`cover_image`, `image_asset_or_url`). Only mind maps need a new column.

---

## Step-by-Step — Adding a Real Book with All Visuals

Suppose you're adding *Atomic Habits* with a real cover, checkpoint illustrations, and a mind map.

1. **Cover image**
   - Save `atomic_habits.jpg` (400x600, under 200 KB) to `assets/images/covers/`
   - Set `"cover_image": "assets/images/covers/atomic_habits.jpg"` in `books.json`

2. **Checkpoint illustrations**
   - Save `atomic_habits_cp1.jpg`, `_cp2.jpg`, ... to `assets/images/illustrations/`
   - Set `"image_asset_or_url": "assets/images/illustrations/atomic_habits_cp1.jpg"` in each checkpoint in `checkpoints.json`

3. **Mind map**
   - Write or generate `atomic_habits.html` (follow the Harry Potter example's structure)
   - **Rewrite the `<script src>` tag** to `./lib/markmap-autoloader.min.js`
   - Save to `assets/mindmaps/atomic_habits.html`
   - Set `"mindmap_asset_path": "assets/mindmaps/atomic_habits.html"` in `books.json`
   - (Make sure the `lib/` JS files are already in place from the one-time vendoring step)

4. **Expand checkpoint content**
   - Update `checkpoints.json` entries for this book
   - Aim for 3-5 paragraphs in `explanation_text` per checkpoint
   - Increase the number of checkpoints for longer books (8-12 instead of 4-6)

5. **`pubspec.yaml`**
   - Ensure `assets/images/covers/`, `assets/images/illustrations/`, `assets/mindmaps/`, `assets/mindmaps/lib/` are all listed

6. **Test**
   - Delete and reinstall the app (so the seed re-runs with your new data)
   - Open the book in the app — verify cover, checkpoint illustrations, and mind map all load **with airplane mode ON**

---

## What the App Needs to Support This (Engineering TODOs)

Not done yet. Implementation tasks when you're ready:

- [ ] Add `flutter_inappwebview` to `pubspec.yaml`
- [ ] Add `mindmap_asset_path` column to `books` table in `database_helper.dart`
- [ ] Add `mindmapAssetPath` field to `BookEntry` model
- [ ] Update `ContentService._bookFromRow` to include the new field
- [ ] Create `lib/features/reader/screens/mindmap_screen.dart` — full-screen `InAppWebView` with back button
- [ ] Add "View mind map" button to Book Detail screen — show only when `book.mindmapAssetPath != null`
- [ ] Vendor the 3 markmap JS files into `assets/mindmaps/lib/` (one-time developer task)

All of these are fully offline changes. No server, no internet, no third-party auth.

---

## App Size Budget (Fully Offline)

| Asset type | Size |
|---|---|
| Flutter framework + Dart VM | ~12 MB |
| Code + theme + icons | ~3 MB |
| `flutter_inappwebview` native | ~2 MB |
| Mind map shared JS engine | ~360 KB |
| Mind map HTMLs (10 books) | ~250 KB |
| Book covers (20 books × 200 KB) | ~4 MB |
| Checkpoint illustrations (150 × 300 KB) | ~45 MB |
| **Estimated total install** | **~65-70 MB** |

Under the App Store's 150 MB Wi-Fi download threshold with comfortable margin. Google Play compresses further.

If this gets too big later, Option B (hybrid — bundle metadata + download heavy images on demand) is always available as an escape hatch.

---

## Content Rights Reminder

From `ai_books_flutter_product_spec.md`:

- **Use original artwork only** for covers and illustrations (commissioned, licensed, or generated). Book publishers own official covers; don't use them without a license
- **Write original mind map outlines.** Structures and headings are fine; don't copy the original book text verbatim
- **Short quotes (< 300 characters) are generally fair use** with attribution, but if in doubt, paraphrase

---

## Quick Reference

| I want to... | Do this |
|---|---|
| Add a book cover | Drop JPG in `assets/images/covers/`, set `cover_image` in `books.json` |
| Add a checkpoint illustration | Drop JPG in `assets/images/illustrations/`, set `image_asset_or_url` in `checkpoints.json` |
| Add a mind map for a book | Save HTML in `assets/mindmaps/`, rewrite `<script src>` to local path, set `mindmap_asset_path` in `books.json` |
| Add a long book (30-40+ pages) | Write 10-15 checkpoints with 3-5 paragraphs each, plus a mind map |
| Update an existing book's content | Edit the JSON files, delete app, reinstall — seed re-runs |
| Handle long books without PDFs | Expanded checkpoints + mind map button. No PDF viewer needed |
