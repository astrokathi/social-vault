# Mission: Architecting and Building ReelVault (Production Local-First Flutter App)

## Why
Master production Flutter engineering by building **ReelVault**—a local-first, offline-capable Instagram Reels & Carousels vault with OS Share Sheet interception, reactive Drift SQLite persistence, endless media playback loops, and multi-device adaptive layouts. By implementing this real-world application, the learner will bridge the gap between UI prototypes and resilient production mobile architectures.

## Success looks like
- Understand and implement **Feature-First Clean Architecture** with Flutter & Riverpod.
- Master local-first persistence using **Drift (reactive SQLite)** with custom indexes, stream queries, and foreign-key cascades.
- Build native OS Share Sheet interception (Android `ACTION_SEND` and iOS Share Extension) to intake links directly into the app.
- Build an OpenGraph scraper and binary asset caching pipeline that saves media before temporary CDN URLs expire.
- Implement an endless vertical media feed using **modulo arithmetic on `PageView.builder`** with real-time watch progress throttling.
- Create an adaptive multi-device UI supporting Compact Mobile, Large Mobile, and Tablet Split-View (`NavigationRail` + 2-pane inspector).

## Constraints
- Target Flutter 3.24+ / Dart 3.5+ with OLED dark aesthetic (`#09090B`).
- Clean, non-crashing code with zero placeholders or shortcuts.
- Each milestone must pair implementation with crystal-clear pedagogical explanation.

## Out of scope
- Cloud user authentication (Supabase/Firebase)—ReelVault is intentionally 100% local-first and private.
- Commercial app store monetization or in-app purchases.
