# Architecture Foundations & Reactive SQLite with Drift

Established the Feature-First Clean Architecture structure with Flutter Riverpod and Drift (SQLite ORM). Designed normalized relational schemas (`Collections` and `VaultMediaItems`) with foreign-key cascades, composite indexes on `shortcode`, `collectionId`, and `watchProgress`, and relative document file path sandboxing to survive iOS container UUID mutations.

## Implications
- Any UI component in ReelVault can listen to real-time database changes via reactive Streams (`watchFeedQueue`, `watchAllCollections`) without manual refresh callbacks or polling.
- All stored media references are stored as relative sandbox paths (`vault_media/...`) preventing file not found errors when iOS updates its app container UUID between launches.
