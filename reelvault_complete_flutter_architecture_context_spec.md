# ReelVault — Complete One-Shot Implementation Specification (`context.md`)

> **Target AI Agent / IDE:** Antigravity / Cursor / Flutter Agent  
> **Framework:** Flutter 3.24+ (Dart 3.5+)  
> **Architecture Pattern:** Feature-First Clean Architecture + Riverpod (`flutter_riverpod`) + Drift (`drift` SQLite ORM)  
> **Core Concept:** A local-first, offline-capable personal media player and curated library. Users share Instagram Reels, Videos, Photos, or Multi-Slide Carousels via the native iOS/Android Share Sheet directly to **ReelVault**. Before saving, a bottom sheet prompts for the target **Collection**. All media metadata, OpenGraph thumbnails, and video/image assets are downloaded locally so URLs never expire and playback works seamlessly inside the app.

---

## 1. System Architecture & End-to-End Data Flow

```
[Instagram / Social App]
       │  (User taps Share -> Selects "ReelVault")
       ▼
[Native OS Share Extension / Android Intent Filter (ACTION_SEND)]
       │  (Intercepts shared URL, strips tracking params like ?igsh=...)
       ▼
[Share Confirmation Bottom Sheet (UI)]
       │  ├─ Auto-fetches OpenGraph preview (`og:title`, `og:image`, media type)
       │  └─ Prompts user to select an existing Collection chip or "+ New Collection"
       ▼
[Media Extraction & Local Asset Pipeline]
       │  ├─ 1. Resolves canonical shortcode & media stream URLs (Video .mp4 or Carousel .jpg/.webp list)
       │  ├─ 2. Downloads thumbnail & media files into `getApplicationDocumentsDirectory()/vault_media/`
       │  └─ 3. Writes indexed record into local SQLite database (`drift`)
       ▼
[3-Tab Flutter Application (Mobile BottomNavigationBar / Tablet NavigationRail)]
  ├─ Tab 1: Endless Personalized Feed
  │    ├─ Sequence Mode (Ordered Loop) vs. Random Mode (Shuffled Endless Loop)
  │    ├─ "Hide Watched (100%)" toggle filter
  │    └─ Native Video Player (`media_kit` / `video_player`) + Carousel Slider (`PageView`)
  ├─ Tab 2: Saved Collections & IG-Style Library Grid
  │    ├─ 2x2 Mosaic Collection Folders View
  │    └─ 3-Column (Mobile) / 5-Column (Tablet) Thumbnail Grid with bottom Watch Progress Bars
  └─ Tab 3: Profile, Storage Telemetry & Settings
       ├─ SQLite & Media Cache usage analyzer
       ├─ Optional IG Cookie Bridge login (for private/age-gated reels)
       └─ Reset watch progress, Export ZIP backup, or Wipe local data
```

---

## 2. Complete `pubspec.yaml` Dependencies

Use the following production-tested packages to implement the project without native platform conflicts:

```yaml
name: reel_vault
description: Personal local-first Share-Sheet video & carousel vault with endless feed.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management & Dependency Injection
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Local SQLite Database (Indexed & Reactive)
  drift: ^2.20.0
  sqlite3_flutter_libs: ^0.5.24
  path_provider: ^2.1.4
  path: ^1.9.0

  # OS Share Sheet Receiver (Android ACTION_SEND & iOS Share Extension)
  receive_sharing_intent: ^1.8.0

  # Media Playback & Caching
  video_player: ^2.9.1
  chewie: ^1.8.3
  flutter_image_compress: ^2.3.0

  # Networking, HTML OpenGraph Parsing & File Downloads
  dio: ^5.6.0
  html: ^0.15.4
  webview_flutter: ^4.8.0 # Used for optional Instagram session cookie bridge & fallback DOM extraction

  # UI & Utilities
  phosphor_flutter: ^2.1.0
  google_fonts: ^6.2.1
  uuid: ^4.4.2
  archive: ^3.6.1 # For exporting SQLite + media backup zip

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.12
  drift_dev: ^2.20.0
  riverpod_generator: ^2.4.3
  flutter_lints: ^4.0.0
```

---

## 3. Directory Structure

Create the following modular directory layout inside `lib/`:

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/
│   │   └── app_theme.dart              # OLED Dark theme (#09090B), gradients, typography
│   ├── responsive/
│   │   └── adaptive_scaffold.dart      # Switches between Compact Mobile, Large Mobile, and Tablet Split-View
│   └── utils/
│       └── url_sanitizer.dart          # Strips ?igsh=... and extracts canonical shortcode
├── data/
│   ├── database/
│   │   ├── app_database.dart           # Drift SQLite tables, indexes, and queries
│   │   └── app_database.g.dart
│   └── services/
│       ├── share_intent_service.dart   # Listens to cold-start and warm-state shared URLs
│       ├── og_extractor_service.dart   # Parses OpenGraph, oEmbed, MP4 & Carousel slide URLs
│       └── local_asset_manager.dart    # Saves .mp4 and .webp files to local sandbox
└── features/
    ├── share_sheet/
    │   └── share_collection_sheet.dart # Modal popup asking for Collection name before saving
    ├── feed/
    │   ├── providers/
    │   │   └── feed_queue_provider.dart # Handles Sequence vs Random loop + Hide Watched (100%)
    │   ├── widgets/
    │   │   ├── reel_video_item.dart    # Vertical full-screen video player + live progress tracker
    │   │   ├── carousel_media_item.dart# Multi-slide interactive photo viewer + slide progress
    │   │   └── feed_top_controls.dart  # Sequence/Shuffle toggle + Hide Watched chip
    │   └── feed_screen.dart
    ├── collections/
    │   ├── widgets/
    │   │   ├── collection_mosaic_card.dart # 2x2 cover grid for each collection
    │   │   └── media_grid_tile.dart        # 3-column IG library tile with bottom progress bar
    │   └── collections_screen.dart
    └── profile/
        └── profile_settings_screen.dart    # Storage telemetry, reset progress, delete vault
```

---

## 4. Database Schema (`lib/data/database/app_database.dart`)

Use **Drift (SQLite)** with explicit indexes on `shortcode`, `collectionId`, `watchProgress`, and `createdAt` so filtering and sorting remain instantaneous even with 10,000+ saved records.

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

enum MediaType { video, photo, carousel }

@DataClassName('CollectionEntity')
class Collections extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('VaultMediaEntity')
@TableIndex(name: 'idx_media_shortcode', columns: {#shortcode}, unique: true)
@TableIndex(name: 'idx_media_collection', columns: {#collectionId})
@TableIndex(name: 'idx_media_progress', columns: {#watchProgress})
class VaultMediaItems extends Table {
  TextColumn get id => text()();
  TextColumn get shortcode => text()();
  TextColumn get canonicalUrl => text()();
  TextColumn get collectionId => text().references(Collections, #id, onDelete: KeyAction.cascade)();
  
  // Media Classification: 0 = video, 1 = photo, 2 = carousel
  IntColumn get mediaType => intEnum<MediaType>()();
  
  // OpenGraph & Author Metadata
  TextColumn get authorHandle => text().withDefault(const Constant('@instagram_user'))();
  TextColumn get caption => text().withDefault(const Constant(''))();
  
  // Local File Paths (Relative to AppDocumentsDirectory so iOS sandbox UUID changes don't break paths!)
  TextColumn get localThumbnailRelPath => text()();
  TextColumn get localVideoRelPath => text().nullable()();
  
  // JSON-encoded list of relative file paths for Photo Carousels: e.g. '["slides/1.webp", "slides/2.webp"]'
  TextColumn get localCarouselRelPathsJson => text().withDefault(const Constant('[]'))();
  
  // Playback Telemetry
  RealColumn get watchProgress => real().withDefault(const Constant(0.0))(); // 0.0 to 1.0 (1.0 == 100% watched)
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  IntColumn get lastPositionMs => integer().withDefault(const Constant(0))();
  IntColumn get fileSizeBytes => integer().withDefault(const Constant(0))();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastWatchedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Collections, VaultMediaItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Watch Feed Items with reactive filtering for "Hide 100% Watched"
  Stream<List<VaultMediaEntity>> watchFeedQueue({required bool hideCompleted}) {
    final query = select(vaultMediaItems);
    if (hideCompleted) {
      query.where((tbl) => tbl.watchProgress.isSmallerThanValue(0.98));
    }
    query.orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);
    return query.watch();
  }

  // Update watch progress in real-time as video plays or carousel is swiped
  Future<void> updateWatchProgress({
    required String mediaId,
    required double progress,
    required int positionMs,
  }) {
    final clamped = progress.clamp(0.0, 1.0);
    return (update(vaultMediaItems)..where((t) => t.id.equals(mediaId))).write(
      VaultMediaItemsCompanion(
        watchProgress: Value(clamped),
        lastPositionMs: Value(positionMs),
        lastWatchedAt: Value(DateTime.now()),
      ),
    );
  }

  // Reset all watch progress to 0%
  Future<void> resetAllProgress() {
    return update(vaultMediaItems).write(
      const VaultMediaItemsCompanion(
        watchProgress: Value(0.0),
        lastPositionMs: Value(0),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'reelvault.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
```

---

## 5. Native Share Sheet Configuration (Android & iOS)

### 5.1 Android (`android/app/src/main/AndroidManifest.xml`)
Add the `ACTION_SEND` intent filter inside your `<activity android:name=".MainActivity">` block so **ReelVault** appears directly in the Instagram Share Sheet:

```xml
<intent-filter>
    <action android:name="android.intent.action.SEND" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="text/plain" />
</intent-filter>
```
Also set `android:launchMode="singleTask"` on `MainActivity` so sharing from Instagram brings the existing Flutter instance forward and opens the Collection Picker popup immediately.

### 5.2 iOS (`ios/ShareExtension`)
1. In Xcode, add a **Share Extension** target named `ShareExtension`.
2. Enable **App Groups** (`group.com.yourcompany.reelvault`) on both `Runner` and `ShareExtension`.
3. Configure `receive_sharing_intent` in `ShareViewController.swift` so tapping **ReelVault** in the iOS Share Sheet deep-links into the main app and triggers `ShareCollectionSheet`.

---

## 6. URL Sanitizer & OpenGraph / Media Extractor Pipeline

### 6.1 `lib/core/utils/url_sanitizer.dart`
```dart
class UrlSanitizer {
  static final RegExp _igRegex = RegExp(
    r'instagram\.com\/(?:p|reel|reels|tv)\/([A-Za-z0-9_-]+)',
    caseSensitive: false,
  );

  /// Extracts shortcode (e.g. 'C9xLmP2oQ1z') and returns clean canonical URL
  static ({String shortcode, String canonicalUrl})? parseInstagramUrl(String rawSharedText) {
    final match = _igRegex.firstMatch(rawSharedText);
    if (match == null) return null;
    final shortcode = match.group(1)!;
    return (
      shortcode: shortcode,
      canonicalUrl: 'https://www.instagram.com/reel/$shortcode/',
    );
  }
}
```

### 6.2 `lib/data/services/og_extractor_service.dart`
> **Important Implementation Note on Instagram Scraping & Expiry:**  
> Instagram's `fbcdn.net` image and video URLs contain `oh=` and `oe=` cryptographic signatures that expire within 24–48 hours. Therefore, `OgExtractorService` **must** download the binary bytes of the thumbnail (`og:image`), video (`og:video`), or carousel images immediately upon share and save them locally via `LocalAssetManager`.

```dart
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import '../database/app_database.dart';

class ExtractedMediaMetadata {
  final String shortcode;
  final String canonicalUrl;
  final MediaType mediaType;
  final String authorHandle;
  final String caption;
  final String thumbnailRemoteUrl;
  final String? videoRemoteUrl;
  final List<String> carouselRemoteUrls;

  ExtractedMediaMetadata({
    required this.shortcode,
    required this.canonicalUrl,
    required this.mediaType,
    required this.authorHandle,
    required this.caption,
    required this.thumbnailRemoteUrl,
    this.videoRemoteUrl,
    this.carouselRemoteUrls = const [],
  });
}

class OgExtractorService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      // Crawler User-Agent allows reading OpenGraph tags without immediate login wall redirect
      'User-Agent': 'TelegramBot (like TwitterBot)',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    },
  ));

  Future<ExtractedMediaMetadata> extractFromUrl(String canonicalUrl, String shortcode) async {
    final response = await _dio.get<String>(canonicalUrl);
    final document = html_parser.parse(response.data ?? '');

    String? getMeta(String property) {
      return document
          .querySelector('meta[property="$property"]')
          ?.attributes['content'] ??
          document
          .querySelector('meta[name="$property"]')
          ?.attributes['content'];
    }

    final ogImage = getMeta('og:image') ?? '';
    final ogVideo = getMeta('og:video') ?? getMeta('og:video:secure_url');
    final ogTitle = getMeta('og:title') ?? '@instagram_creator';
    final ogDescription = getMeta('og:description') ?? '';

    // Parse author handle from og:title (e.g., "Username on Instagram: \"Caption...\"")
    final authorMatch = RegExp(r'^([^on]+)\s+on\s+Instagram').firstMatch(ogTitle);
    final author = authorMatch != null ? '@${authorMatch.group(1)!.trim()}' : '@creator';

    final isVideo = ogVideo != null && ogVideo.isNotEmpty;

    return ExtractedMediaMetadata(
      shortcode: shortcode,
      canonicalUrl: canonicalUrl,
      mediaType: isVideo ? MediaType.video : MediaType.photo,
      authorHandle: author,
      caption: ogDescription,
      thumbnailRemoteUrl: ogImage,
      videoRemoteUrl: ogVideo,
    );
  }
}
```

---

## 7. Endless Feed Queue Controller (Sequence vs. Shuffle + Hide 100% Watched)

### `lib/features/feed/providers/feed_queue_provider.dart`
This Riverpod controller manages:
1. **Sequence Mode:** Loops through the feed in deterministic chronological order (`index = (index + 1) % length`).
2. **Random / Shuffle Mode:** Uses a Fisher-Yates shuffled permutation of the active queue and reshuffles automatically at the end of each cycle so every unwatched item is seen before repeating.
3. **Hide Watched (100%) Toggle:** Dynamically filters out items where `watchProgress >= 0.98` unless the user toggles the filter off.

```dart
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';

enum PlaybackOrderMode { sequence, random }

class FeedFilterState {
  final PlaybackOrderMode orderMode;
  final bool hideWatched;

  const FeedFilterState({
    this.orderMode = PlaybackOrderMode.sequence,
    this.hideWatched = true,
  });

  FeedFilterState copyWith({
    PlaybackOrderMode? orderMode,
    bool? hideWatched,
  }) {
    return FeedFilterState(
      orderMode: orderMode ?? this.orderMode,
      hideWatched: hideWatched ?? this.hideWatched,
    );
  }
}

class FeedFilterNotifier extends StateNotifier<FeedFilterState> {
  FeedFilterNotifier() : super(const FeedFilterState());

  void toggleOrderMode() {
    state = state.copyWith(
      orderMode: state.orderMode == PlaybackOrderMode.sequence
          ? PlaybackOrderMode.random
          : PlaybackOrderMode.sequence,
    );
  }

  void toggleHideWatched() {
    state = state.copyWith(hideWatched: !state.hideWatched);
  }
}

final feedFilterProvider = StateNotifierProvider<FeedFilterNotifier, FeedFilterState>(
  (ref) => FeedFilterNotifier(),
);

/// Provides the ordered/shuffled list of VaultMediaEntity items for the endless PageView.builder
final activeFeedListProvider = StreamProvider.family<List<VaultMediaEntity>, FeedFilterState>((ref, filter) {
  final db = ref.watch(databaseProvider);
  return db.watchFeedQueue(hideCompleted: filter.hideWatched).map((items) {
    if (items.isEmpty) return [];
    final list = List<VaultMediaEntity>.from(items);
    if (filter.orderMode == PlaybackOrderMode.random) {
      list.shuffle(Random());
    }
    return list;
  });
});
```

---

## 8. Endless Loop `PageView.builder` & Real-Time Progress Bar Implementation

### 8.1 Endless Vertical Feed (`lib/features/feed/feed_screen.dart`)
To achieve an **endless feed** in Flutter where the user can swipe down forever:
* Do **not** pass `itemCount: items.length` to `PageView.builder`.
* Instead, leave `itemCount: null` (infinite scroll) and resolve the active item inside `itemBuilder` using modulo arithmetic:
  ```dart
  PageView.builder(
    scrollDirection: Axis.vertical,
    // itemCount is null -> infinite endless loop!
    itemBuilder: (context, rawIndex) {
      if (items.isEmpty) return const EmptyFeedPlaceholder();
      final item = items[rawIndex % items.length];
      return item.mediaType == MediaType.carousel
          ? CarouselMediaItem(item: item)
          : ReelVideoItem(item: item);
    },
  )
  ```

### 8.2 Video Watch Progress Listener (`lib/features/feed/widgets/reel_video_item.dart`)
Attach a listener to `VideoPlayerController` that throttles database writes to once every 1,000ms and marks the item `1.0` (100% watched) when playback reaches `>= 95%` of total duration:

```dart
void _onVideoControllerTick() {
  final value = _controller.value;
  if (!value.isInitialized || value.duration.inMilliseconds <= 0) return;

  final ratio = value.position.inMilliseconds / value.duration.inMilliseconds;
  final normalizedProgress = ratio >= 0.95 ? 1.0 : ratio.clamp(0.0, 1.0);

  // Update bottom progress bar UI smoothly
  setState(() => _currentProgress = normalizedProgress);

  // Persist to SQLite every 1 second or immediately on completion
  final now = DateTime.now();
  if (normalizedProgress >= 1.0 || now.difference(_lastDbWrite).inSeconds >= 1) {
    _lastDbWrite = now;
    ref.read(databaseProvider).updateWatchProgress(
      mediaId: widget.item.id,
      progress: normalizedProgress,
      positionMs: value.position.inMilliseconds,
    );
  }
}
```

---

## 9. Multi-Resolution Adaptive Layout Breakpoints

Implement `lib/core/responsive/adaptive_scaffold.dart` using `LayoutBuilder` to match the 3 target viewports demonstrated in the HTML UI prototype:

| Device Class | Width Breakpoint | Navigation Pattern | Feed Layout | Library Grid Columns |
|---|---|---|---|---|
| **Compact Mobile** *(iPhone SE / Mini)* | `< 390dp` | Compact 56dp `BottomNavigationBar` | Full-bleed single-column `PageView` | 3 Columns (`aspectRatio: 0.8`) |
| **Large Mobile** *(iPhone 16 Pro Max / Pixel 9 Pro)* | `390dp – 699dp` | Edge-to-edge `BottomNavigationBar` | Full-bleed single-column `PageView` | 3 Columns (`aspectRatio: 0.8`) |
| **Tablet / iPad** *(iPad Mini / Pro / Foldables)* | `>= 700dp` | Left `NavigationRail` (80dp width) | 2-Pane Split View: 7-col Player + 5-col Active Queue Inspector | 4 to 5 Columns + 3-Column Collection Folders |

---

## 10. Step-by-Step Verification Checklist for Antigravity

1. **Initialize Project & Codegen:**
   * Run `flutter pub get`
   * Run `dart run build_runner build --delete-conflicting-outputs` to generate Drift SQLite classes.
2. **Verify Share Sheet Flow:**
   * Trigger a simulated share intent or share a Reel URL from Instagram.
   * Confirm `ShareCollectionSheet` modal opens, parses the OpenGraph thumbnail, allows picking or creating a Collection, downloads the media to `vault_media/`, and inserts the row into `VaultMediaItems`.
3. **Verify Endless Feed & Filters:**
   * Toggle between **Sequence Mode** and **Random Mode** in the top floating bar.
   * Scrub or watch a video to 100% completion and confirm that when **Hide Watched** is enabled, the completed item is excluded from the next loop cycle.
4. **Verify Collections & IG Library Grid:**
   * Open Tab 2, verify 2x2 Mosaic Covers render for each Collection, and verify the 3-column Library Grid displays the red/orange watch progress bar at the bottom of every thumbnail.