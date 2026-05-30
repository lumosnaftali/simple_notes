# AGENTS.md

Operational guide for Claude Code Agent in this project.

---

## Mandatory Rules

1. **Always read AGENTS.md** at the start of every session before doing any task.
2. **Always update AGENTS.md** after making changes or important decisions.
3. **Compress to CHANGE_HISTORY.md** when the "Change History" section grows large (>50 entries or file >200 lines). Move older entries there, keeping only the 5 most recent in AGENTS.md.

---

## Project Context

- **Project Name:** simple_notes
- **Platform:** Windows 11, PowerShell
- **Repo:** `C:\Users\Lumos\Project\simple_notes`
- **Main branch:** `main`
- **Git user:** lumosnaftali

### Description

A Flutter notes application with encrypted local storage, tag-based organization, and share-to-WhatsApp/Telegram support. Built with Material 3 and ViewModel architecture.

### GitHub Issues

- [#1 Plan: Flutter Simple Notes App with Encrypted Storage, Tags & Share](https://github.com/lumosnaftali/simple_notes/issues/1)

### Planned Tech Stack

| Layer | Choice |
|---|---|
| UI | Flutter + Material 3 |
| State | flutter_riverpod + ViewModel |
| Storage | hive (AES encrypted) + flutter_secure_storage |
| Share | share_plus |

### Implementation Order (from Issue #1)

1. Flutter project setup & dependencies
2. Material 3 theme (light + dark)
3. Encrypted storage service
4. Tag model + repository + ViewModel
5. Note model + repository + ViewModel
6. NotesList screen (filter chips, search)
7. NoteEditor screen (auto-save, tag picker)
8. NoteDetail screen (read-only + share)
9. Share via share_plus
10. Polish: empty/loading/error states
11. Test on Android & iOS

---

## Change History

| Date       | Description                                                         | Files Affected |
|------------|---------------------------------------------------------------------|----------------|
| 2026-05-30 | Initialized AGENTS.md. New project, only README.md exists.         | AGENTS.md      |
| 2026-05-30 | Converted AGENTS.md and change history language to English.         | AGENTS.md      |
| 2026-05-30 | Created GitHub Issue #1 with full Flutter app plan. Updated project context, tech stack, and implementation order in AGENTS.md. Rewrote README.md. | AGENTS.md, README.md |
| 2026-05-30 | Scaffolded Flutter project and resolved dependency conflicts. Implemented custom AppTheme (light/dark Material 3), EncryptedStorage (Hive + AES secure storage service), Note and Tag domains (Models, Repositories, ViewModels, and fully styled UI screens). Compiles with zero analyzer warnings. | pubspec.yaml, lib/main.dart, lib/core/theme/app_theme.dart, lib/core/storage/..., lib/features/notes/..., lib/features/tags/..., lib/shared/widgets/... |
| 2026-05-30 | Created comprehensive .gitignore for Flutter app and excluded agent/local files. | .gitignore, AGENTS.md |
| 2026-05-30 | Replaced default counter widget test with proper Note and Tag model unit tests. | test/widget_test.dart, AGENTS.md |


