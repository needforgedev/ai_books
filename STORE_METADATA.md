# Store Metadata — Speedread

Source-of-truth copy for App Store Connect + Google Play Console.
Tweak before submitting; everything here is a draft you can paste in.

---

## App name

**Speedread**

> Both stores allow up to 30 characters. Check availability at the time of submission — "Speedread" is generic enough that someone may have it. Fallback names: *Speedread: Big Books*, *Speedread — Nonfiction in Minutes*.

---

## iOS — App Store Connect

### Subtitle (max 30 chars)

> Shown directly under the app name on the listing. Sells the value in one line.

```
Big books, in short reads.
```
*26 chars*

**Alternatives if the above feels generic:**
- `Nonfiction in 10 minutes.` *(24)*
- `Bite-sized big books.` *(21)*
- `Big ideas. Short reads.` *(23)*

### Promotional text (max 170 chars, can edit without resubmission)

```
Pick up a 10-minute checkpoint from the world's best nonfiction — fully offline, no ads, no account needed. New books added each month.
```
*135 chars*

### Description (max 4000 chars)

```
Speedread turns the world's most important nonfiction books into 10-minute reading checkpoints designed for the way you actually read on a phone.

Each book is broken into a handful of focused checkpoints — a hook, a core idea, a modern example you'll actually recognise, and a reflection prompt. You can finish a checkpoint on a coffee break, save the line that hit, and come back tomorrow without losing your place.

WHY SPEEDREAD

• Built for short attention windows — none of the 300-page commitment.
• Plain language — no jargon, no fluff. If a concept needs a fancy name, we explain it in normal words first.
• Modern examples — every idea is grounded in apps, school, work, relationships. Not 1950s analogies.
• Reflection over consumption — every checkpoint ends with a question, not a quiz.

WHAT'S INSIDE THE LAUNCH LIBRARY

• Science — A Brief History of Time · Sapiens · The Selfish Gene
• Business — Atomic Habits · The Lean Startup · Zero to One
• Personal Development — Man's Search for Meaning · Meditations · The Courage to Be Disliked

Nine books, thirty-six checkpoints, all curated. New books added each month based on what readers ask for.

KEY FEATURES

• 10-minute checkpoints — built for one-handed reading on the go
• Personalised picks — answer a few onboarding questions about your interests, goals, and reading comfort, and we suggest the right starting book
• Streak tracking — read one checkpoint per day to build a daily habit
• Quote saving — bookmark the lines that stuck and revisit them in the Saved tab
• Mind maps — see the whole shape of a book on one screen
• Daily reminders — opt-in, at a time you choose, delivered locally on your device
• Fully offline — no internet required after install. No ads. No tracking. No account.

PRIVACY-FIRST BY DESIGN

Speedread runs entirely on your device. There's no account to create, no server to log in to, and no data collection. Your reading history, saved quotes, and streaks live only in the app's private storage on your phone. We don't use third-party analytics or advertising.

Read our full policy at github.com/needforgedev/ai_books.

WHO IT'S FOR

Anyone between 16 and 35 who:
• Means to read more but never finishes the book
• Has saved a stack of bestsellers but can't get past page 40
• Wants the ideas without the publisher-padded word count
• Reads on a phone, in short bursts, between everything else

Download Speedread. Start a streak. Finish a book this week.
```
*≈ 2,500 chars — well under 4,000*

### Keywords (max 100 chars, comma-separated)

```
books,reading,nonfiction,selfhelp,habits,productivity,philosophy,psychology,learning,summary
```
*92 chars*

> Don't include "blinkist" or other competitor brand names — Apple rejects those. Don't repeat the app name. Don't include words already in the title/subtitle (they're already indexed).

### Categories

- **Primary:** Education
- **Secondary:** Books

### Age rating (App Store)

**12+**

Questionnaire answers:
- Cartoon or fantasy violence: **None**
- Realistic violence: **None**
- Prolonged graphic / sadistic realistic violence: **None**
- Profanity or crude humor: **None**
- Mature / suggestive themes: **None**
- Horror / fear themes: **None**
- Medical / treatment info: **None**
- Alcohol, tobacco, drug use or references: **None** *(mild references in self-help context — set to "Infrequent / Mild" only if Stoic/Frankl content quotes anything; otherwise None)*
- Sexual content or nudity: **None**
- Graphic sexual content: **None**
- Gambling: **None**
- Unrestricted web access: **No**
- Contests: **No**

### Privacy policy URL

```
https://github.com/needforgedev/ai_books/blob/main/PRIVACY.md
```

> Or, once GitHub Pages is enabled on the repo, use the cleaner Pages URL.

### Support URL

```
https://github.com/needforgedev/ai_books/blob/main/SUPPORT.md
```

> [SUPPORT.md](SUPPORT.md) covers contact email, GitHub Issues, FAQs. Apple requires this be a working URL at review time.

### Marketing URL (optional)

```
https://github.com/needforgedev/ai_books
```

### App Privacy "nutrition labels"

For every question in the App Privacy section in App Store Connect:

- **Data Used to Track You:** None
- **Data Linked to You:** None
- **Data Not Linked to You:** None

> **All three sections are "Data Not Collected".** Speedread doesn't send anything off the device.

### What's New (release notes, max 4000 chars)

For v1.0.0:

```
First release.

• 9 launch books across Science, Business, and Personal Development
• Personalised recommendations from your onboarding choices
• 10-minute checkpoints, streak tracking, daily reminders
• Saved quotes and bookmarks
• Mind maps for every book
• Fully offline — no account, no ads, no tracking
```

---

## Google Play — Play Console

### App name

**Speedread**

### Short description (max 80 chars)

```
Master the world's biggest books in 10-minute checkpoints. Fully offline.
```
*74 chars*

**Alternative:**
- `Bite-sized nonfiction. 10-minute checkpoints. Fully offline, ad-free.` *(70)*

### Full description (max 4000 chars)

> Same body as the iOS description above is fine. Play allows the same copy; you don't need to split it. Paste the iOS description body here verbatim.

### Application category

- **Primary category:** Education
- **Tags:** Books & Reference, Self-Improvement, Personal Growth, Productivity

### Content rating (Play Console questionnaire)

Target rating: **Teen** (13+) — appropriate for self-help / nonfiction content.

Questionnaire answers (all defaults are "No"):
- Violence: **No**
- Sexuality / nudity: **No**
- Profanity / crude humor: **No**
- Controlled substances: **No**
- Gambling: **No**
- User-generated content: **No**
- Shares user location: **No**
- Allows in-app purchases: **No** *(unless you re-enable the Premium card later)*
- Allows ads: **No**

### Data Safety form

For every question:

- **Does your app collect or share any of the required user data types?** No
- **Is all of the user data collected by your app encrypted in transit?** N/A *(no data is sent)*
- **Do you provide a way for users to request that their data be deleted?** Yes — *the Settings → Reset Profile option clears all local data; uninstalling removes everything.*

> Result: a clean "No data collected" Data Safety entry on the Play Store listing.

### Target audience and content

- **Target age groups:** 13–15, 16–17, 18 and over
- **Does your app appeal to children?** No
- **Does your app primarily target children?** No

### Privacy policy URL

```
https://github.com/needforgedev/ai_books/blob/main/PRIVACY.md
```

### Contact details

- **Email:** `needforge.dev@gmail.com` *(required and shown on the Play listing)*
- **Phone:** optional
- **Website:** `https://github.com/needforgedev/ai_books` (optional)

### News in this release (release notes, max 500 chars)

```
First release. 9 launch books across Science, Business, and Personal Development. 10-minute checkpoints, streaks, saved quotes, mind maps. Fully offline — no account, no ads, no tracking.
```
*190 chars*

---

## Screenshots

Required sizes:

| Platform | Size | Min count | Recommended |
|---|---|---|---|
| iPhone 6.7" (e.g. 14 Pro Max, 15 Pro Max) | 1290×2796 | 3 | 5–8 |
| iPhone 6.5" (e.g. 11 Pro Max, XS Max) | 1242×2688 | 3 | 5–8 |
| iPhone 5.5" (legacy — 8 Plus) | 1242×2208 | optional | 5 |
| iPad Pro 12.9" | 2048×2732 | optional but recommended | 5 |
| Android phone | 1080×1920 to 3840×2160 | 2 | 5–8 |
| Android tablet (7" and 10") | optional | optional | 3 each |

**Screens to capture, in order:**

1. **Home with continue-reading + best-for-you** — the hook
2. **Library / category detail** — shows breadth
3. **Book detail screen** — shows the book's commitment level
4. **Reader (mid-checkpoint with quote pull)** — shows the actual reading UX
5. **Book complete** — the payoff moment (medal + takeaway quote)
6. **Mind map** — visual feature unique to Speedread
7. **Profile / streak** — habit hook

**Capture command:**

```bash
flutter run -d "iPhone 15 Pro Max"
# In simulator: Cmd+S to save screenshots; place in store-assets/ios/6.7/
flutter run -d "iPhone 11 Pro Max"  # 6.5"
# etc.
```

For Android, use Android Studio's emulator or `adb shell screencap`.

---

## Promotional graphics (Play Store only)

**Feature graphic (1024×500 PNG, required)** — the banner above your app on the Play Store listing.

Suggested composition: cinematic dark `#0A0A0C` background, SpeedRead icon left-of-center, tagline "Big books, in short reads." in white Space Grotesk on the right. Crimson `#FF3B3B` accent rail bottom-edge. Can be generated when ready.

---

## Quick paste checklist (when submitting)

- [ ] App name
- [ ] Subtitle (iOS) / short description (Play)
- [ ] Promotional text (iOS)
- [ ] Full description
- [ ] Keywords (iOS)
- [ ] Primary + secondary category
- [ ] Age rating questionnaire complete
- [ ] Privacy policy URL hosted + linked
- [ ] Support URL hosted + linked
- [ ] App Privacy / Data Safety form filled in (both "no data collected")
- [ ] All required screenshots uploaded
- [ ] Play feature graphic uploaded
- [ ] What's New / release notes filled in
- [ ] Version + build number bumped (`pubspec.yaml`)
- [ ] Signed release build uploaded
