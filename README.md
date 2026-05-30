# Simple Notes

A Flutter application for creating, organizing, and sharing text-based notes — privately and securely.

## Features

- **Encrypted local storage** — all notes stored on-device with AES encryption, no cloud required
- **Tags** — organize notes with colored tags and filter by them
- **Share** — export any note as plain text to WhatsApp, Telegram, or any other app
- **Emoji support** — full Unicode emoji, compatible with WhatsApp and Telegram
- **Material 3** — modern adaptive UI with light and dark theme
- **ViewModel architecture** — clean separation of UI and business logic via Riverpod

## Tech Stack

| Layer | Choice |
|---|---|
| UI | Flutter + Material 3 |
| State Management | flutter_riverpod + ViewModel |
| Local Storage | hive (AES) + flutter_secure_storage |
| Share | share_plus |

## Project Status

Planning phase. See [Issue #1](https://github.com/lumosnaftali/simple_notes/issues/1) for the full implementation plan.

## Getting Started

```bash
flutter pub get
flutter run
```

## Out of Scope (v1)

- Cloud sync
- Image or file attachments
- Reminders / notifications
- Password lock screen
- Export to PDF
