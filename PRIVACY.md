# Privacy Policy

**Last updated: 2026-05-11**

Speedread is a fully offline mobile learning app. This policy explains what data the app handles and what it doesn't.

## TL;DR

- We don't collect personal data.
- We don't send anything off your device.
- We don't use analytics, ads, or tracking.
- We don't have user accounts.

## What the app stores — and where

Everything Speedread stores lives **only on your device**, inside an SQLite database in the app's private storage. Nothing is uploaded to any server.

| What we store | Why |
|---|---|
| Your display name (from onboarding) | Greeting you on Home and on the share card. |
| Your interest / goal / improvement-area selections | Powering local book recommendations. |
| Your reading comfort level | Filtering book difficulty. |
| Reading progress (which checkpoints you've completed) | "Continue reading" + streak. |
| Saved quotes and bookmarks | The Saved tab. |
| Daily activity history | Showing your streak. |
| Notification opt-in | Remembering your preference. |

## What we do NOT do

- We do **not** create an account or profile on any server.
- We do **not** collect your email, phone number, location, contacts, or device identifiers.
- We do **not** use third-party analytics (no Firebase Analytics, no Crashlytics, no Amplitude, no Mixpanel).
- We do **not** show advertisements.
- We do **not** sell, share, or transmit your data to anyone.

## Network access

The app does not require an internet connection. It does not make network requests during normal use. Book content, mind maps, and illustrations are bundled inside the app.

The only optional networked component is **Google Fonts** (loaded via the `google_fonts` Flutter package). On first launch, your device may fetch font files from `fonts.gstatic.com` and cache them locally. Google's privacy policy applies to that request: <https://policies.google.com/privacy>.

## Notifications

If you opt in via Settings → Notifications, Speedread schedules a daily local reminder. These are **local** notifications scheduled on your own device — no notification server is involved. You can revoke the permission at any time through your device's system settings.

## Resetting / deleting your data

You can wipe everything Speedread has stored locally in two ways:

1. In the app: **Profile → Settings → Reset Profile**.
2. Uninstall the app — this deletes the app's private storage along with it.

Because nothing is stored off-device, no further deletion request is needed.

## Children's privacy

Speedread is designed for users 16+. We do not knowingly collect data from anyone, including children under 13.

## Changes to this policy

If we change how the app handles data, we'll update this file and bump the "Last updated" date above. Material changes will be called out in the app's release notes.

## Contact

For questions about this policy:

- **Email:** [needforge.dev@gmail.com](mailto:needforge.dev@gmail.com)
- **GitHub Issues:** <https://github.com/needforgedev/ai_books/issues>
