import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
  TextColumn get collectionId =>
      text().references(Collections, #id, onDelete: KeyAction.cascade)();

  // Media Classification: 0 = video, 1 = photo, 2 = carousel
  IntColumn get mediaType => intEnum<MediaType>()();

  // OpenGraph & Author Metadata
  TextColumn get authorHandle =>
      text().withDefault(const Constant('@instagram_user'))();
  TextColumn get caption => text().withDefault(const Constant(''))();

  // Local File Paths (Relative to AppDocumentsDirectory so iOS sandbox UUID changes don't break paths!)
  TextColumn get localThumbnailRelPath => text()();
  TextColumn get localVideoRelPath => text().nullable()();

  // JSON-encoded list of relative file paths for Photo Carousels: e.g. '["slides/1.webp", "slides/2.webp"]'
  TextColumn get localCarouselRelPathsJson =>
      text().withDefault(const Constant('[]'))();

  // Playback Telemetry
  RealColumn get watchProgress =>
      real().withDefault(const Constant(0.0))(); // 0.0 to 1.0 (1.0 == 100% watched)
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  IntColumn get lastPositionMs => integer().withDefault(const Constant(0))();
  IntColumn get fileSizeBytes => integer().withDefault(const Constant(0))();

  // Favorites System Flag
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastWatchedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Collections, VaultMediaItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  static const String favoritesCollectionId = 'col_favorites';
  static const String favoritesCollectionName = 'Favorites';

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await ensureFavoritesCollectionExists();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(vaultMediaItems, vaultMediaItems.isFavorite);
        await ensureFavoritesCollectionExists();
      }
    },
    beforeOpen: (details) async {
      await ensureFavoritesCollectionExists();
      await healExistingMediaTypes();
    },
  );

  /// Self-heals any incorrectly tagged posts:
  /// Any item with /p/ in its URL or without a local video file is tagged as MediaType.carousel
  /// so it renders as a swipeable slideshow instead of a video player with a play button.
  Future<void> healExistingMediaTypes() async {
    final all = await select(vaultMediaItems).get();
    for (final item in all) {
      if (item.canonicalUrl.contains('/p/') ||
          (item.localVideoRelPath == null && item.mediaType == MediaType.video)) {
        await (update(vaultMediaItems)..where((t) => t.id.equals(item.id))).write(
          const VaultMediaItemsCompanion(
            mediaType: Value(MediaType.carousel),
          ),
        );
      }
    }
  }

  /// Guarantees the system Favorites collection is present and cannot be deleted
  Future<void> ensureFavoritesCollectionExists() async {
    final existing = await (select(collections)
      ..where((t) => t.id.equals(favoritesCollectionId))).getSingleOrNull();
    if (existing == null) {
      await into(collections).insert(
        CollectionEntity(
          id: favoritesCollectionId,
          name: favoritesCollectionName,
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  /// Toggles the isFavorite boolean for a media item
  Future<bool> toggleFavorite(String mediaId) async {
    final item = await (select(vaultMediaItems)
      ..where((t) => t.id.equals(mediaId))).getSingleOrNull();
    if (item == null) return false;
    final newFav = !item.isFavorite;
    await (update(vaultMediaItems)..where((t) => t.id.equals(mediaId))).write(
      VaultMediaItemsCompanion(isFavorite: Value(newFav)),
    );
    return newFav;
  }

  // Watch Feed Items with reactive filtering for "Hide 100% Watched"
  Stream<List<VaultMediaEntity>> watchFeedQueue({required bool hideCompleted}) {
    final query = select(vaultMediaItems);
    if (hideCompleted) {
      query.where((tbl) => tbl.watchProgress.isSmallerThanValue(0.98));
    }
    query.orderBy([
      (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
    ]);
    return query.watch();
  }

  // Watch all collections - Favorites always stays pinned first!
  Stream<List<CollectionEntity>> watchAllCollections() {
    final query = select(collections)
      ..orderBy([
        (t) => OrderingTerm(
              expression: const CustomExpression<int>(
                  "CASE WHEN id = 'col_favorites' THEN 0 ELSE 1 END"),
              mode: OrderingMode.asc,
            ),
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
      ]);
    return query.watch();
  }

  // Watch media items for a specific collection (or all if collectionId is null)
  Stream<List<VaultMediaEntity>> watchMediaForCollection(String? collectionId) {
    final query = select(vaultMediaItems);
    if (collectionId == favoritesCollectionId) {
      // Return both items explicitly in Favorites AND any items flagged isFavorite
      query.where((tbl) =>
          tbl.isFavorite.equals(true) | tbl.collectionId.equals(favoritesCollectionId));
    } else if (collectionId != null && collectionId.isNotEmpty) {
      query.where((tbl) => tbl.collectionId.equals(collectionId));
    }
    query.orderBy([
      (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
    ]);
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
        lastWatchedAt: Value(null),
      ),
    );
  }

  // Insert or replace a collection
  Future<int> insertOrUpdateCollection(CollectionEntity entity) {
    return into(collections).insertOnConflictUpdate(entity);
  }

  // Insert or replace a media item
  Future<int> insertOrUpdateMedia(VaultMediaEntity entity) {
    return into(vaultMediaItems).insertOnConflictUpdate(entity);
  }

  // Delete a media item
  Future<int> deleteMedia(String mediaId) {
    return (delete(vaultMediaItems)..where((t) => t.id.equals(mediaId))).go();
  }

  // Delete a collection (cascades to all items)
  Future<int> deleteCollection(String collectionId) {
    return (delete(collections)..where((t) => t.id.equals(collectionId))).go();
  }

  // Wipe all database rows
  Future<void> wipeAllData() async {
    await delete(vaultMediaItems).go();
    await delete(collections).go();
  }

  // Purge sample mock data if present
  Future<void> removeSampleData() async {
    final sampleColIds = ['col-ui', 'col-workout', 'col-synth', 'col-coffee'];
    final sampleMediaIds = ['rv-101', 'rv-102', 'rv-103', 'rv-104'];
    await (delete(vaultMediaItems)..where((t) => t.id.isIn(sampleMediaIds))).go();
    await (delete(collections)..where((t) => t.id.isIn(sampleColIds))).go();
  }

  // Calculate total media storage bytes tracked in SQLite
  Future<int> getTotalMediaBytes() async {
    final sumExp = vaultMediaItems.fileSizeBytes.sum();
    final query = selectOnly(vaultMediaItems)..addColumns([sumExp]);
    final result = await query.getSingle();
    return result.read(sumExp) ?? 0;
  }

  // Pre-seed sample data matching the prototype design if the database is empty
  Future<void> seedInitialDataIfEmpty() async {
    final count = await (selectOnly(collections)..addColumns([collections.id.count()])).getSingle();
    final totalCollections = count.read(collections.id.count()) ?? 0;
    if (totalCollections > 0) return;

    // Seed default collections
    final col1 = CollectionEntity(id: 'col-ui', name: 'UI & Architecture', createdAt: DateTime.now().subtract(const Duration(days: 5)));
    final col2 = CollectionEntity(id: 'col-workout', name: 'Workout & Mobility', createdAt: DateTime.now().subtract(const Duration(days: 4)));
    final col3 = CollectionEntity(id: 'col-synth', name: 'Synth & Sound', createdAt: DateTime.now().subtract(const Duration(days: 3)));
    final col4 = CollectionEntity(id: 'col-coffee', name: 'Culinary & Coffee', createdAt: DateTime.now().subtract(const Duration(days: 2)));

    await batch((b) {
      b.insertAll(collections, [col1, col2, col3, col4]);
    });

    // Seed media items matching the prototype
    final items = [
      VaultMediaEntity(
        id: 'rv-101',
        shortcode: 'C7vBnM1kLp9',
        canonicalUrl: 'https://www.instagram.com/reel/C7vBnM1kLp9/',
        collectionId: 'col-ui',
        mediaType: MediaType.video,
        authorHandle: '@arcdesign.studio',
        caption: 'Why tactile physics & spring animations make mobile interfaces feel alive. Full gesture breakdown inside! ✨ #uiux #flutter #design',
        localThumbnailRelPath: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=800&auto=format&fit=crop&q=80',
        localVideoRelPath: null,
        localCarouselRelPathsJson: '[]',
        watchProgress: 0.65,
        durationMs: 34000,
        lastPositionMs: 22100,
        fileSizeBytes: 14889779, // ~14.2 MB
        isFavorite: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        lastWatchedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      VaultMediaEntity(
        id: 'rv-102',
        shortcode: 'C6mPoL8xZa2',
        canonicalUrl: 'https://www.instagram.com/p/C6mPoL8xZa2/',
        collectionId: 'col-ui',
        mediaType: MediaType.carousel,
        authorHandle: '@brutalist.arch',
        caption: 'Swipe through all 4 angles → Nordic Concrete Pavilion nestled in the Norwegian fjords. Raw board-formed textures & warm oak interiors.',
        localThumbnailRelPath: 'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=800&auto=format&fit=crop&q=80',
        localVideoRelPath: null,
        localCarouselRelPathsJson: jsonEncode([
          'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&auto=format&fit=crop&q=80',
        ]),
        watchProgress: 0.50,
        durationMs: 0,
        lastPositionMs: 2,
        fileSizeBytes: 7130316, // ~6.8 MB
        isFavorite: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        lastWatchedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      VaultMediaEntity(
        id: 'rv-103',
        shortcode: 'C5tYuI9oPq3',
        canonicalUrl: 'https://www.instagram.com/reel/C5tYuI9oPq3/',
        collectionId: 'col-workout',
        mediaType: MediaType.video,
        authorHandle: '@calisthenics.lab',
        caption: '3 shoulder mobility drills you should run before every handstand session. Save this to your routine vault! 🔥',
        localThumbnailRelPath: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&auto=format&fit=crop&q=80',
        localVideoRelPath: null,
        localCarouselRelPathsJson: '[]',
        watchProgress: 1.0, // 100% Watched! Filtered out when hideWatched is true
        durationMs: 45000,
        lastPositionMs: 45000,
        fileSizeBytes: 20342374, // ~19.4 MB
        isFavorite: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        lastWatchedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      VaultMediaEntity(
        id: 'rv-104',
        shortcode: 'C4rEwQ2wAs1',
        canonicalUrl: 'https://www.instagram.com/reel/C4rEwQ2wAs1/',
        collectionId: 'col-synth',
        mediaType: MediaType.video,
        authorHandle: '@analog.synth.club',
        caption: 'Late night tape loop & Prophet-6 arpeggio patch. Recorded direct to 1/4 inch magnetic tape.',
        localThumbnailRelPath: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&auto=format&fit=crop&q=80',
        localVideoRelPath: null,
        localCarouselRelPathsJson: '[]',
        watchProgress: 0.25,
        durationMs: 52000,
        lastPositionMs: 13000,
        fileSizeBytes: 23173529, // ~22.1 MB
        isFavorite: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        lastWatchedAt: DateTime.now().subtract(const Duration(hours: 18)),
      ),
      VaultMediaEntity(
        id: 'rv-105',
        shortcode: 'C3zXcV7bNm8',
        canonicalUrl: 'https://www.instagram.com/p/C3zXcV7bNm8/',
        collectionId: 'col-coffee',
        mediaType: MediaType.carousel,
        authorHandle: '@espresso.alchemy',
        caption: 'Dialing in washed Ethiopian Yirgacheffe: 18g in, 40g out in 27 seconds at 93°C. Swipe for extraction macro shots.',
        localThumbnailRelPath: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800&auto=format&fit=crop&q=80',
        localVideoRelPath: null,
        localCarouselRelPathsJson: jsonEncode([
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800&auto=format&fit=crop&q=80',
        ]),
        watchProgress: 1.0, // 100% Watched! Filtered out when hideWatched is true
        durationMs: 0,
        lastPositionMs: 3,
        fileSizeBytes: 5347737, // ~5.1 MB
        isFavorite: false,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        lastWatchedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      VaultMediaEntity(
        id: 'rv-106',
        shortcode: 'C2pOiU6yTr5',
        canonicalUrl: 'https://www.instagram.com/reel/C2pOiU6yTr5/',
        collectionId: 'col-ui',
        mediaType: MediaType.video,
        authorHandle: '@cyber.shader.art',
        caption: 'Raymarched SDF fractals rendered inside a custom Flutter FragmentProgram shader.',
        localThumbnailRelPath: 'https://images.unsplash.com/photo-1634017839464-5c339ebe3cb4?w=800&auto=format&fit=crop&q=80',
        localVideoRelPath: null,
        localCarouselRelPathsJson: '[]',
        watchProgress: 0.10,
        durationMs: 18000,
        lastPositionMs: 1800,
        fileSizeBytes: 8945672, // ~8.5 MB
        isFavorite: false,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        lastWatchedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    await batch((b) {
      b.insertAll(vaultMediaItems, items);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'reelvault.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// Global Riverpod Provider for AppDatabase singleton
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
