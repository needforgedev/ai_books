# AI Books - Flutter Product Spec

Working title only. Final product name and brand system are still open.

## 1. Product Summary

`AI Books` is a mobile-first learning app for Gen Z and younger adults who want the wisdom of important books without the friction of traditional reading. Think Blinkist, but designed for a younger audience (16-30) with visual, checkpoint-based content and personalized recommendations.

The product turns major books across categories such as philosophy, psychology, self-help, spirituality, business, science, history, and sociology into simplified, Gen Z-friendly reading experiences. Each book is rewritten as original simplified content — not full books, not PDFs, not ePubs. The content is broken into checkpoints so users can leave and return exactly where they left off.

The app should feel:

- modern
- intellectually aspirational
- visually rich
- beginner-friendly
- personalized from the first session

The current product direction is:

- user downloads the app
- user creates an account or logs in
- user completes a short onboarding
- onboarding captures interests, goals, areas to improve, reading comfort, and optional streak target
- app recommends a starter book plus alternate picks based on the user's profile
- the full library of categories and books is always accessible — recommendations are a starting point, not a gate
- user reads simplified book content with checkpoints and saved progress
- if the user leaves midway, they can always return to where they left off
- category difficulty rises over time so the user grows into harder books
- daily streaks and reminders keep users coming back

This is not a traditional ebook reader, not a full-book reproduction app, and not a heavy game. It is a guided intellectual growth app with light habit mechanics, similar to Blinkist in structure but built for Gen Z in tone, design, and experience.

## 2. Product Goals

### Primary Goals

- Help users understand major books quickly without needing to read dense original prose first.
- Reduce fear and intimidation around "serious" books.
- Personalize the first reading recommendation so the user gets immediate value.
- Make each book feel approachable through simple language, clean structure, and visual explanation.
- Create a repeatable habit through progress saves, continue-reading, and optional streak challenges.

### Secondary Goals

- Build a strong content system that can expand across many categories over time.
- Let users move from beginner-friendly books toward deeper, more difficult books.
- Support visual learning with artwork, concept cards, quote cards, and modern examples.
- Make the product feel premium and curated rather than like a generic summary database.

### Non-Goals

- Full book reproduction, PDF/ePub reader, or ebook storefront
- Open social networking or public discussion feeds in v1
- Heavy RPG-style mechanics, currencies, or loot systems
- Open-ended AI chat as the core reading experience in v1
- Academic exam prep or citation-heavy study tooling as the primary product identity
- Audiobook or narration pipeline

## 3. Audience

### Core User Segments

- `16-19`: curious students who want ideas for life, mindset, and identity but do not enjoy long reading sessions
- `20-24`: college students and early-career users seeking self-growth, mental clarity, and book recommendations that feel relevant
- `25-30`: secondary audience of young professionals who want fast access to ideas from classic and modern nonfiction

### User Context

- most sessions are on a phone
- user attention is short and fragmented
- user may want growth and wisdom but not "feel like a reader"
- user is likely familiar with short-form, visual-first apps
- user wants useful ideas with clear application to modern life

### User Motivations

- "I want to become smarter without forcing myself through dense books."
- "I want to know which book is right for me."
- "I want to improve my mindset, discipline, clarity, or understanding of people."
- "I want to learn important ideas in a way that feels modern."

### User Frictions

- books feel too long
- language feels intimidating
- unclear where to start
- low consistency with reading habits
- traditional reading apps feel dry

## 4. Design Principles

- `Simple before deep`: even difficult books should be explained in clear language first.
- `Personalized from day one`: onboarding must materially improve recommendations.
- `Visual explanation beats text walls`: images and layout should support understanding, not just decorate screens.
- `Progress without pressure`: checkpoints and streaks should motivate without punishing users.
- `Serious ideas, approachable delivery`: the app should feel smart, not childish.
- `One strong next action`: each screen should make the next step obvious.
- `Curated over crowded`: users should feel guided, not lost in a giant catalog.
- `Reading is the core behavior`: all supporting mechanics should strengthen reading, not compete with it.

## 5. Content Structure

### Content Model

All book content in this app is original simplified writing. Each book is rewritten into simple, visual, checkpoint-based content aimed at Gen Z readers. The app does not serve full books, PDFs, ePubs, or raw original text. Content is stored as structured data (not files) and seeded into the local SQLite database.

### Library Structure

The content model is category-led, but the exact number of categories and books is intentionally flexible. The full library is always accessible to all users — they can browse any category and any book at any time, independent of recommendations.

Long-term structure:

- multiple content categories or genres
- each category contains a curated progression of books
- books within a category move from easier to harder
- each book contains internal checkpoints for saving progress and organizing the reading flow
- users can leave a book at any checkpoint and return exactly where they left off

Launch recommendation:

- start with `4-6` categories
- start with `20-40` books total
- expand categories and depth only after engagement and retention data are visible

Possible categories:

- Philosophy
- Psychology
- Self Help
- Personal Development
- Spirituality
- Mindfulness
- Business
- Economics
- History
- Biography
- Sociology
- Religion
- Science
- Non-Fiction
- Poetry
- Science Fiction

Not every category needs to ship at launch.

### Category Structure

Each category should act as a guided lane, not a random list.

Rules:

- early books should be more accessible
- later books should introduce more nuance and complexity
- difficulty should increase in interpretation and depth, not in jargon
- categories should feel distinct in tone and promise

Example:

- Psychology starts with highly relatable, behavior-focused books
- Philosophy starts with accessible entry books before more abstract works
- Business starts with practical decision-making before denser strategy material

### Book Structure

Each book is a primary unit of progress in the app.

A book should contain:

- book title
- author
- category
- difficulty level
- estimated completion time
- short "why this matters" explanation
- simplified book overview
- key ideas broken into checkpoints
- memorable quotes or quote-inspired cards
- real-life applications
- next recommended books

### Checkpoint Structure

Checkpoints are progress markers inside a book. They are not a separate map hierarchy.

A typical book can be divided into `4-8` checkpoints depending on complexity.

Typical checkpoint types:

- `Hook`: what this section is about
- `Core Idea`: the main concept in simple language
- `Modern Example`: how the idea shows up today
- `Interpretation`: what the idea means at a deeper level
- `Application`: how the user can use it in life
- `Reflection`: optional prompt or quick thought question
- `Recap`: short summary before the next checkpoint

### Content Fields Per Category

- id
- title
- slug
- description
- icon or artwork
- theme color
- difficultyProfile
- launchOrder

### Content Fields Per Book

- id
- title
- subtitle
- author
- categoryId
- coverImage
- difficulty
- estimatedMinutes
- introHook
- whyItMatters
- shortDescription
- keyTakeaways[]
- goalsTags[]
- interestTags[]
- improvementTags[]
- readingLevelFit
- recommendedPrerequisites[]
- nextBookIds[]
- bookmarkCountHint
- isFeatured

### Content Fields Per Checkpoint

- id
- bookId
- order
- title
- checkpointType
- hookText
- explanationText
- modernExample
- reflectionPrompt
- keyQuote
- imageAssetOrUrl
- recapText
- estimatedMinutes

### Recommendation Metadata

Each book should be tagged for onboarding and recommendation matching.

Suggested tags:

- interests
- goals
- improvement areas
- reading comfort
- session length suitability
- tone: practical, reflective, intense, calming, analytical
- beginner-friendliness

## 6. Core Product Loop

1. User downloads the app.
2. User signs up or logs in.
3. User completes onboarding (interests, goals, improvement areas, reading comfort, streak challenge).
4. App recommends one best-fit starter book and two alternate picks based on the user's profile.
5. User can start the recommended book or browse the full library of categories and books.
6. User reads simplified book content, progressing through checkpoints in a visual format.
7. App saves position automatically at each checkpoint — user can leave and return where they left off.
8. Home screen offers continue-reading, category exploration, and next recommendations.
9. User completes a book and receives a new recommendation based on progress and profile.
10. Daily streaks and reminders encourage the user to return each day.
11. Over time, users move to more difficult books within chosen categories.

## 7. Brand, Theming, and Graphics

### Positioning

Do not position the app as:

- a plain ebook app or PDF reader
- a noisy self-help quote app
- a cartoon game
- a Blinkist clone for professionals

Position it as:

- a modern visual guide to important books, built for Gen Z
- an intellectual growth app
- a curated library that feels alive and relevant
- the easiest way for young people to understand great books

### Visual Strategy

Use two visual layers:

- `UI layer`: premium editorial UI with strong hierarchy, generous spacing, and modern card patterns
- `content layer`: conceptual illustrations, symbolic images, quote cards, and visual explainers tied to book ideas

This keeps the product engaging without turning it into a childish experience.

### Visual Tone

- confident
- clean
- cinematic
- modern
- warm rather than sterile

### Image Strategy

Images should support understanding.

Use:

- symbolic editorial illustrations
- concept-driven scenes
- metaphorical imagery
- clean book cover treatments
- pull-quote visual cards

Avoid:

- generic stock-photo feeling
- cluttered infographic screens
- childish mascot-heavy direction
- random decorative images with no learning value

### Typography Recommendation

- strong display type for headings
- readable sans-serif for body
- clear contrast between book titles, section labels, and reading text
- excellent readability at multiple text sizes

### Motion Recommendation

- subtle fades and card transitions
- progress and checkpoint transitions
- no constant animation
- reduced-motion mode support

### Category Art Direction

Categories can have distinct art moods without becoming separate themes.

Examples:

- Philosophy: restrained, sculptural, high-contrast
- Psychology: emotional, human-centered, layered
- Spirituality: calm, atmospheric, luminous
- Business: structured, clean, decision-focused
- History: textured, archival, cinematic

### UI Style

- portrait-first
- high-content clarity
- one primary action per screen
- comfortable spacing for long reading sessions
- bottom navigation for core areas
- card-based discovery for home and category browsing

## 8. Personalization and Retention Systems

### Personalization Inputs

The onboarding should collect only signals that improve recommendations.

Core inputs:

- interests
- goals
- areas to improve
- reading comfort
- preferred session length
- optional streak challenge

### Reading Difficulty Model

Books should be ordered by approachable-to-deep progression within each category.

Difficulty can be expressed across:

- idea complexity
- abstractness
- emotional intensity
- reading density
- expected prior knowledge

### Recommendation Model

Launch with rules-based recommendation logic using book tags.

Recommendations are shown after onboarding and on the home screen, but they do not restrict access. The full library is always browsable.

Inputs:

- interest match score (matched against book interestTags)
- goal match score (matched against book goalTags)
- improvement-area match score (matched against book improvementTags)
- reading comfort fit
- whether the book is beginner-friendly

Outputs:

- `Best Pick`
- `Alternate Pick 1`
- `Alternate Pick 2`

Later versions can add:

- behavior-based recommendations
- collaborative filtering
- completion-based difficulty adaptation

### Checkpoint Save Model

The app should automatically save:

- current book
- current checkpoint
- last opened timestamp
- completion percentage

This supports fast re-entry from the home screen.

### Streak and Reminder Model

Streaks and daily reminders are the primary retention mechanism in v1. Streaks should be optional and supportive, not punishing.

Suggested rules:

- streak counts a day with meaningful reading progress
- missing a day does not trigger aggressive guilt messaging
- optional streak targets can be `7`, `14`, or `30` days
- streak UI should feel like habit support, not pressure
- daily reminder notifications (opt-in) encourage users to return
- reminders should reference the user's current book or progress when possible

### Progress Model

Track:

- books started
- books completed
- checkpoint completion
- category progress
- streak days
- reading minutes
- saved highlights or bookmarks

### Difficulty Progression

As users progress in a category:

- early books should be easier and more broadly appealing
- middle books should demand more reflection
- later books should ask for deeper interpretation

The language inside the app should remain simple even when the ideas become more advanced.

## 9. App Modes and Navigation

### A. Personalized Home

Primary hub that shows:

- continue reading
- best recommendation
- alternate recommendations
- category shortcuts
- streak and recent progress

### B. Category Library

Browse all categories and featured books. The full library is always accessible to all users regardless of their recommendations.

Should support:

- visual discovery
- clear category descriptions
- difficulty cues
- featured starter books

### C. Category Detail

Show:

- category overview
- why this category matters
- beginner books
- progressing books
- advanced books

### D. Book Detail

Show:

- cover and metadata
- why this book is recommended
- what the user will learn
- estimated reading time
- checkpoint list
- start or continue action

### E. Reader Experience

The main reading surface.

Should support:

- segmented checkpoints
- clear typography
- visual cards
- bookmark support
- quick recap
- progress indicator

### F. Saved / Bookmarks

User can revisit:

- saved quotes
- bookmarked checkpoints
- favorite books

### G. Search and Discover

Useful once the library grows.

Support:

- search by title
- search by author
- search by category
- search by problem or goal tag

### H. Profile and Progress

Show:

- user profile
- interests and goals
- streak
- books completed
- category progress
- reading level preference

## 10. Interactive Learning Patterns

This product is not game-first, but it should still feel active rather than passive.

Launch with light interactions inside books.

### 1. Tap-to-Reveal Concept

- prompt: a concept headline or question
- action: tap to reveal explanation
- purpose: pace the reading and build curiosity

### 2. Quote Decode

- prompt: a quote or paraphrase from the book
- action: reveal its meaning in simple language
- purpose: bridge original tone and modern understanding

### 3. Modern Scenario

- prompt: short real-life situation
- action: choose or view how the book idea applies
- purpose: make abstract ideas practical

### 4. Reflection Prompt

- prompt: short self-directed question
- action: think, save, or skip
- purpose: turn reading into personal insight

### 5. Checkpoint Recap

- prompt: concise summary card
- action: continue or revisit
- purpose: reinforce retention without creating quiz fatigue

Optional later:

- quick comprehension checks
- comparison cards between books
- category mastery summaries

## 11. Progress and Motivation

### Motivation Signals

Use low-pressure reinforcement.

Suggested signals:

- reading streak
- completion ring
- category progress bar
- finished book markers
- "continue where you left off"
- gentle milestone moments after book completion

### Reward Design Rules

- progress should feel earned and calm
- avoid loud arcade-style rewards
- avoid variable-ratio reward loops
- avoid making the app feel like a points machine
- keep the meaning of progress tied to learning

### Completion Moments

When a user completes a book, show:

- what they understood
- what category progress changed
- recommended next books
- optional save/share quote or takeaway

## 12. Onboarding Flow

The onboarding should be short, high-signal, and useful.

Recommended sequence:

- splash
- welcome
- auth
- interests selection
- goals selection
- areas to improve
- reading comfort
- daily time preference
- optional streak challenge
- recommendation result
- enable reminders
- home

### Onboarding Questions

#### Interests

Examples:

- Philosophy
- Psychology
- Self Growth
- Spirituality
- Business
- History
- Science
- Sociology

#### Goals

Examples:

- build discipline
- reduce overthinking
- understand people better
- find purpose
- improve mindset
- become more knowledgeable
- think more clearly

#### Areas to Improve

Examples:

- focus
- confidence
- habits
- emotional control
- consistency
- productivity
- relationships

#### Reading Comfort

Examples:

- beginner
- moderate
- advanced

#### Daily Time Preference

Examples:

- 5 minutes
- 10 minutes
- 15 minutes
- 20+ minutes

#### Streak Challenge

Examples:

- no challenge
- 7-day start
- 14-day habit
- 30-day consistency

### Recommendation Result Rules

The result screen should always show:

- one primary recommendation
- two alternate recommendations
- a short explanation of why the primary book was selected

Example explanation:

- "Recommended because you chose psychology, reducing overthinking, and beginner reading level."

## 13. Screen-by-Screen Wireframes

These are low-fidelity wireframes for implementation planning, not final visual design.

### 13.1 Splash Screen

Purpose: brand preload and app initialization

```text
+--------------------------------------------------+
|                    AI BOOKS                      |
|            [animated wordmark / symbol]          |
|                                                  |
|                  Loading...                      |
+--------------------------------------------------+
```

### 13.2 Welcome Screen

Purpose: introduce the app promise

```text
+--------------------------------------------------+
| Learn the world's best books in simple language  |
|                                                  |
| [Editorial illustration / book collage]          |
|                                                  |
|        [Create Account]   [Log In]               |
+--------------------------------------------------+
```

### 13.3 Interests Screen

Purpose: capture broad category preference

```text
+--------------------------------------------------+
| What are you interested in?                      |
|                                                  |
| [Philosophy] [Psychology] [Business]             |
| [Spirituality] [History] [Science]               |
| [Self Growth] [Mindfulness]                      |
|                                                  |
|                     [Next]                       |
+--------------------------------------------------+
```

### 13.4 Goals Screen

Purpose: understand desired outcome

```text
+--------------------------------------------------+
| What do you want help with most?                 |
|                                                  |
| [Discipline] [Purpose] [Clarity]                 |
| [Mindset] [Relationships] [Overthinking]         |
|                                                  |
|                     [Next]                       |
+--------------------------------------------------+
```

### 13.5 Areas to Improve Screen

Purpose: refine recommendations further

```text
+--------------------------------------------------+
| Which areas do you want to improve?              |
|                                                  |
| [Focus] [Confidence] [Consistency]               |
| [Habits] [Emotional Control] [Productivity]      |
|                                                  |
|                     [Next]                       |
+--------------------------------------------------+
```

### 13.6 Reading Comfort Screen

Purpose: calibrate difficulty

```text
+--------------------------------------------------+
| How comfortable are you with reading?            |
|                                                  |
| [Beginner]                                       |
| [Moderate]                                       |
| [Advanced]                                       |
|                                                  |
|                     [Next]                       |
+--------------------------------------------------+
```

### 13.7 Daily Time Screen

Purpose: fit recommendations to available time

```text
+--------------------------------------------------+
| How much time can you usually give each day?     |
|                                                  |
| [5 min] [10 min] [15 min] [20+ min]              |
|                                                  |
|                     [Next]                       |
+--------------------------------------------------+
```

### 13.8 Streak Challenge Screen

Purpose: optional habit setup

```text
+--------------------------------------------------+
| Want a reading challenge?                        |
|                                                  |
| [No challenge]                                   |
| [7 days]                                         |
| [14 days]                                        |
| [30 days]                                        |
|                                                  |
|                     [Next]                       |
+--------------------------------------------------+
```

### 13.9 Recommendation Result Screen

Purpose: deliver first value

```text
+--------------------------------------------------+
| Your first book is ready                         |
|                                                  |
| [Cover art]                                      |
| The Courage to Be Disliked                       |
| Because you picked psychology + mindset +        |
| beginner-friendly reading                        |
|                                                  |
| [Start Reading]        [See 2 Other Picks]       |
+--------------------------------------------------+
```

### 13.10 Home Screen

Purpose: primary hub

```text
+--------------------------------------------------+
| Hello, Nabeel                                    |
| Streak 4   Books Finished 2                      |
|--------------------------------------------------|
| Continue Reading                                 |
| [Meditations - Checkpoint 3 of 6]                |
|                                                  |
| Best For You                                     |
| [Atomic Habits]                                  |
|                                                  |
| Categories                                       |
| [Philosophy] [Psychology] [Business]             |
|                                                  |
| Nav: Home | Library | Search | Saved | Profile   |
+--------------------------------------------------+
```

### 13.11 Library Screen

Purpose: browse all categories

```text
+--------------------------------------------------+
| Explore Categories                               |
|                                                  |
| [Philosophy]    Beginner to Deep Thinking        |
| [Psychology]    Behavior, emotion, self          |
| [Business]      Decisions, systems, execution    |
| [History]       People, patterns, power          |
|                                                  |
|                     [Open]                       |
+--------------------------------------------------+
```

### 13.12 Category Detail Screen

Purpose: show category progression

```text
+--------------------------------------------------+
| Psychology                                       |
| Understand people, habits, and behavior          |
|--------------------------------------------------|
| Start Here                                       |
| [Book 1] [Book 2]                                |
|                                                  |
| Next Depth                                       |
| [Book 3] [Book 4] [Book 5]                       |
|                                                  |
| Advanced                                         |
| [Book 6] [Book 7]                                |
+--------------------------------------------------+
```

### 13.13 Book Detail Screen

Purpose: explain why this book is worth starting

```text
+--------------------------------------------------+
| The Courage to Be Disliked                       |
| by Ichiro Kishimi, Fumitake Koga                 |
|                                                  |
| Why this book matters                            |
| Learn confidence, self-acceptance, and freedom   |
| from other people's opinions                     |
|                                                  |
| Time: 18 min    Difficulty: Beginner             |
| Checkpoints: 6                                   |
|                                                  |
| [Start Reading]                                  |
+--------------------------------------------------+
```

### 13.14 Reader Screen

Purpose: main reading experience

```text
+--------------------------------------------------+
| Meditations                     3/6              |
|--------------------------------------------------|
| Checkpoint: What You Can Control                 |
|                                                  |
| [Concept illustration]                           |
|                                                  |
| Simple explanation text...                       |
|                                                  |
| [Bookmark]   [Reflect]   [Next]                  |
+--------------------------------------------------+
```

### 13.15 Quote Decode Card

Purpose: explain a difficult quote clearly

```text
+--------------------------------------------------+
| "You have power over your mind..."               |
|                                                  |
| What this means                                  |
| You cannot control events, but you can train     |
| your response to them.                           |
|                                                  |
| [Save Quote]                    [Continue]       |
+--------------------------------------------------+
```

### 13.16 Checkpoint Complete Screen

Purpose: mark progress and encourage continuation

```text
+--------------------------------------------------+
| Checkpoint Complete                              |
| 3 of 6 finished                                  |
|                                                  |
| Key takeaway                                     |
| Focus on what is within your control             |
|                                                  |
| [Continue]                  [Return Home]        |
+--------------------------------------------------+
```

### 13.17 Book Complete Screen

Purpose: close a reading loop and recommend the next step

```text
+--------------------------------------------------+
| Book Complete                                    |
| You finished Meditations                         |
|                                                  |
| What you gained                                  |
| - Stoic emotional control                        |
| - Better response to adversity                   |
|                                                  |
| Next for you                                     |
| [Letters from a Stoic]                           |
|                                                  |
| [Read Next]                    [Explore]         |
+--------------------------------------------------+
```

### 13.18 Search Screen

Purpose: direct discovery

```text
+--------------------------------------------------+
| Search [______________]                          |
|                                                  |
| Filters: Books | Authors | Categories | Goals    |
|--------------------------------------------------|
| Atomic Habits                                    |
| Meditations                                      |
| Man's Search for Meaning                         |
+--------------------------------------------------+
```

### 13.19 Saved Screen

Purpose: revisit meaningful content

```text
+--------------------------------------------------+
| Saved                                            |
|                                                  |
| Quotes                                           |
| [You have power over your mind...]               |
|                                                  |
| Bookmarks                                        |
| [Meditations - Checkpoint 3]                     |
| [Atomic Habits - Habit loop]                     |
+--------------------------------------------------+
```

### 13.20 Profile Screen

Purpose: personal progress overview

```text
+--------------------------------------------------+
| Profile                                          |
| Reading Level: Beginner                          |
| Streak: 7 days                                   |
| Books Finished: 4                                |
| Favorite Categories: Psychology, Philosophy      |
|                                                  |
| [Edit Interests] [Reminder Settings]             |
+--------------------------------------------------+
```

### 13.21 Settings Screen

Purpose: app and reading controls

```text
+--------------------------------------------------+
| Settings                                         |
| Notifications    [on/off]                        |
| Text Size         [small/med/large]              |
| Reduced Motion    [on/off]                       |
| Dark Mode         [system/light/dark]            |
| Sign Out          [action]                       |
+--------------------------------------------------+
```

## 14. Flutter Technical Spec

### Target Platforms

- iPhone
- Android phones
- optional later: tablets with adjusted layouts

### Orientation

- primary: portrait
- optional later: tablet split-view for library and reader

### App Architecture

Use a clean layered architecture:

- `presentation`
- `application`
- `domain`
- `data`

### Suggested Flutter Stack

- `flutter_riverpod` for state management
- `go_router` for navigation
- `sqflite` or `drift` for SQLite offline persistence
- `dio` only if remote content sync is added
- `freezed` and `json_serializable` for typed models

### Suggested Project Structure

```text
lib/
  app/
    app.dart
    router.dart
    theme/
  core/
    analytics/
    content/
    storage/
    networking/
    widgets/
    utils/
  features/
    auth/
    onboarding/
    home/
    library/
    book_detail/
    reader/
    bookmarks/
    search/
    profile/
    settings/
  domain/
    models/
    repositories/
    services/
  data/
    local/
    remote/
    seed/
```

### State Strategy

Keep feature state isolated:

- auth state
- onboarding state
- recommendation state
- home feed state
- reader session state
- bookmarks state
- profile and progress state
- settings state

Use unidirectional state flow and explicit loading/error/ready states.

### Data Storage

Use offline-first storage with SQLite as the local database.

All book content (categories, books, checkpoints) is stored as structured data in SQLite, seeded from JSON files on first launch. No PDF/ePub file handling is needed.

Persist:

- account basics
- onboarding responses
- recommendation results cache
- current reading position per book (checkpoint-level save/resume)
- completed checkpoints
- completed books
- streak state
- bookmarks and saved quotes
- reminder preferences

### Recommended Runtime Data Objects

#### UserProfile

- id
- displayName
- emailOrAuthProvider
- selectedInterests[]
- selectedGoals[]
- selectedImprovementAreas[]
- readingComfort
- dailyTimePreference
- streakGoal
- notificationOptIn

#### CategoryEntry

- id
- title
- description
- themeColor
- iconAsset
- sortOrder

#### BookEntry

- id
- title
- subtitle
- author
- categoryId
- difficulty
- estimatedMinutes
- coverImage
- introHook
- whyItMatters
- shortDescription
- interestTags[]
- goalTags[]
- improvementTags[]
- isFeatured
- nextBookIds[]

#### CheckpointEntry

- id
- bookId
- order
- title
- checkpointType
- explanationText
- modernExample
- reflectionPrompt
- keyQuote
- imageAssetOrUrl
- recapText
- estimatedMinutes

#### ReadingProgress

- userId
- bookId
- currentCheckpointId
- completedCheckpointIds[]
- completionPercent
- startedAt
- lastOpenedAt
- finishedAt

#### SavedItem

- id
- userId
- type
- sourceBookId
- sourceCheckpointId
- savedText
- createdAt

#### RecommendationResult

- userId
- primaryBookId
- alternateBookIds[]
- reasonText
- generatedAt

### Authentication

For v1, support:

- email login
- Google login
- Apple login on iOS

Guest mode can be considered later, but current product direction assumes account creation before personalization.

### Content Ingestion Pipeline

Launch with a curated content dataset. All content is original simplified writing — not reproductions of full books.

Seed into:

- `categories.json`
- `books.json`
- `checkpoints.json`
- `recommendation_tags.json`

These JSON files are loaded into the local SQLite database on first launch. Later, content can move to a CMS or managed backend.

### Recommendation Engine Strategy

V1 should use deterministic rules-based matching using book tags (interestTags, goalTags, improvementTags).

Example steps:

1. match user's selected interests against book interestTags
2. match user's selected goals against book goalTags
3. match user's selected improvement areas against book improvementTags
4. filter by reading comfort
5. filter by beginner-friendliness when appropriate
6. rank candidate books by combined tag match score
7. return one primary and two alternates

### Image Strategy

- bundle core images for launch books
- lazy-load lower-priority images if the library expands
- optimize image sizes for mobile performance
- prefetch the first recommendation assets after onboarding

### Performance Targets

- cold launch under `3s` on modern mid-tier devices
- onboarding screens should feel instant
- home screen render under `1s` after local data is ready
- reader navigation between checkpoints should feel immediate
- scrolling should remain smooth on image-heavy screens

## 15. Accessibility

- support dynamic text sizing
- maintain strong contrast ratios
- make tap targets comfortable on phones
- support screen readers for core navigation
- provide reduced-motion mode
- avoid overly dense text blocks
- support dark mode without harming readability
- make illustrations supplementary rather than required for comprehension

## 16. Safety, Privacy, and Content Rights

- collect minimal user data
- do not expose public profiles in v1
- do not include open messaging
- make reminder notifications opt-in
- store sensitive auth details through platform-safe methods
- allow account deletion and sign-out flows

Content rights note:

- avoid reproducing copyrighted book text beyond compliant short excerpts
- write original summaries and explanations
- verify rights before using modern covers, long quotes, or publisher-owned assets

## 17. Analytics to Track

- onboarding start rate
- onboarding completion rate
- account creation conversion
- recommendation acceptance rate
- alternate recommendation selection rate
- book start rate
- checkpoint completion rate
- book completion rate
- day 1, day 7, and day 30 retention
- streak participation rate
- notification opt-in rate
- bookmark/save rate
- top categories selected in onboarding
- most-abandoned checkpoints
- average reading session length
- next-book recommendation click-through rate

## 18. MVP Definition

### MVP Scope

- account creation and login
- onboarding with interests, goals, improvement areas, reading comfort, time preference, and optional streak challenge
- rules-based starter recommendation
- home screen with continue-reading and recommended books
- category library
- category detail
- book detail
- checkpoint-based reader
- automatic progress saving
- bookmarks or saved quotes
- profile and streak display
- local content seed for launch categories and books

### Recommended Launch Scope

- `4-6` categories
- `20-30` books
- `4-8` checkpoints per book
- simple recommendation rules
- one polished reader format rather than many interaction types

### Not in MVP

- open social feeds
- comments or public discussion
- heavy gamified economy
- real-time AI chat on every page
- audiobook-scale narration pipeline
- marketplace or ebook purchases
- complex subscription tiers

## 19. Build Order

### Phase 1 - Foundations

- app shell
- router
- theme system
- auth setup
- local content seed structure

### Phase 2 - Onboarding and Profile

- onboarding question flow
- onboarding persistence
- profile model
- recommendation rules engine

### Phase 3 - Core Reading Experience

- category browsing
- book detail
- checkpoint reader
- progress saving
- continue-reading flow

### Phase 4 - Retention and Discovery

- home recommendation feed
- bookmarks
- search
- streak logic
- reminder preferences

### Phase 5 - Polish and Expansion

- analytics hooks
- accessibility pass
- image optimization
- content QA
- empty states and edge cases

## 20. Initialization Checklist

To initialize the Flutter app, build these first:

- router and app shell
- auth flow
- onboarding data model
- `UserProfile` model
- category, book, and checkpoint seed loaders
- rules-based recommendation service
- home screen scaffold
- book detail screen
- reader screen with checkpoint progress
- local persistence for reading state

## 21. Differentiation

### Competitive Landscape

Existing products (Blinkist, Shortform, Headway) serve the same general space: simplified book content. They all target 30+ working professionals with 15-minute text/audio summaries.

### How AI Books Is Different

- `Audience`: Built for 16-30 year olds, not busy professionals. The tone, design, language, and onboarding are designed for Gen Z — users who grew up on short-form, visual-first apps.
- `Personalization-first`: Competitors drop users into a massive catalog. AI Books starts with "tell me about you" and delivers a tailored first book recommendation. The app feels like it knows you from day one.
- `Visual reading experience`: Competitors are walls of text with an audio option. AI Books uses concept cards, quote decode, modern examples, and illustrations — content that feels native to how younger users consume information.
- `Guided progression`: Competitors treat every summary as standalone. AI Books builds a path: beginner to intermediate to advanced within each category. Users feel growth, not just consumption.
- `Checkpoint-based reading with save/resume`: Instead of "here is a 15-minute summary," content is broken into checkpoints. Users can leave at any point and return exactly where they left off — like Blinkist but with more granular progress tracking.
- `Identity play over productivity play`: Positioned as "become the person who understands great books" rather than "save time on reading." Gen Z responds to identity and growth, not time optimization.

### One-Line Differentiator

Blinkist is for professionals who do not have time to read. AI Books is for young people who want to grow through books but need a simpler, more visual way in.

## 22. Final Recommendation

Build the product around one identity:

- `personalized`
- `visual`
- `intellectually aspirational`
- `simple enough for non-readers`

The cleanest version of this app is not "an AI summary app" and not "a game about books."

It is:

- `the easiest way to understand great books and grow through them`

That identity should guide product decisions, UI tone, onboarding, content structure, and future expansion.
