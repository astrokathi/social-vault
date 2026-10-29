// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, CollectionEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(Insertable<CollectionEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollectionEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class CollectionEntity extends DataClass
    implements Insertable<CollectionEntity> {
  final String id;
  final String name;
  final DateTime createdAt;
  const CollectionEntity(
      {required this.id, required this.name, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory CollectionEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionEntity(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CollectionEntity copyWith({String? id, String? name, DateTime? createdAt}) =>
      CollectionEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  CollectionEntity copyWithCompanion(CollectionsCompanion data) {
    return CollectionEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class CollectionsCompanion extends UpdateCompanion<CollectionEntity> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    required String id,
    required String name,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<CollectionEntity> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CollectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VaultMediaItemsTable extends VaultMediaItems
    with TableInfo<$VaultMediaItemsTable, VaultMediaEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaultMediaItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shortcodeMeta =
      const VerificationMeta('shortcode');
  @override
  late final GeneratedColumn<String> shortcode = GeneratedColumn<String>(
      'shortcode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _canonicalUrlMeta =
      const VerificationMeta('canonicalUrl');
  @override
  late final GeneratedColumn<String> canonicalUrl = GeneratedColumn<String>(
      'canonical_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _collectionIdMeta =
      const VerificationMeta('collectionId');
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
      'collection_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES collections (id) ON DELETE CASCADE'));
  @override
  late final GeneratedColumnWithTypeConverter<MediaType, int> mediaType =
      GeneratedColumn<int>('media_type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<MediaType>($VaultMediaItemsTable.$convertermediaType);
  static const VerificationMeta _authorHandleMeta =
      const VerificationMeta('authorHandle');
  @override
  late final GeneratedColumn<String> authorHandle = GeneratedColumn<String>(
      'author_handle', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('@instagram_user'));
  static const VerificationMeta _captionMeta =
      const VerificationMeta('caption');
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
      'caption', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _localThumbnailRelPathMeta =
      const VerificationMeta('localThumbnailRelPath');
  @override
  late final GeneratedColumn<String> localThumbnailRelPath =
      GeneratedColumn<String>('local_thumbnail_rel_path', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localVideoRelPathMeta =
      const VerificationMeta('localVideoRelPath');
  @override
  late final GeneratedColumn<String> localVideoRelPath =
      GeneratedColumn<String>('local_video_rel_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localCarouselRelPathsJsonMeta =
      const VerificationMeta('localCarouselRelPathsJson');
  @override
  late final GeneratedColumn<String> localCarouselRelPathsJson =
      GeneratedColumn<String>(
          'local_carousel_rel_paths_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _watchProgressMeta =
      const VerificationMeta('watchProgress');
  @override
  late final GeneratedColumn<double> watchProgress = GeneratedColumn<double>(
      'watch_progress', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastPositionMsMeta =
      const VerificationMeta('lastPositionMs');
  @override
  late final GeneratedColumn<int> lastPositionMs = GeneratedColumn<int>(
      'last_position_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _fileSizeBytesMeta =
      const VerificationMeta('fileSizeBytes');
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
      'file_size_bytes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _lastWatchedAtMeta =
      const VerificationMeta('lastWatchedAt');
  @override
  late final GeneratedColumn<DateTime> lastWatchedAt =
      GeneratedColumn<DateTime>('last_watched_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        shortcode,
        canonicalUrl,
        collectionId,
        mediaType,
        authorHandle,
        caption,
        localThumbnailRelPath,
        localVideoRelPath,
        localCarouselRelPathsJson,
        watchProgress,
        durationMs,
        lastPositionMs,
        fileSizeBytes,
        isFavorite,
        createdAt,
        lastWatchedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vault_media_items';
  @override
  VerificationContext validateIntegrity(Insertable<VaultMediaEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shortcode')) {
      context.handle(_shortcodeMeta,
          shortcode.isAcceptableOrUnknown(data['shortcode']!, _shortcodeMeta));
    } else if (isInserting) {
      context.missing(_shortcodeMeta);
    }
    if (data.containsKey('canonical_url')) {
      context.handle(
          _canonicalUrlMeta,
          canonicalUrl.isAcceptableOrUnknown(
              data['canonical_url']!, _canonicalUrlMeta));
    } else if (isInserting) {
      context.missing(_canonicalUrlMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
          _collectionIdMeta,
          collectionId.isAcceptableOrUnknown(
              data['collection_id']!, _collectionIdMeta));
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('author_handle')) {
      context.handle(
          _authorHandleMeta,
          authorHandle.isAcceptableOrUnknown(
              data['author_handle']!, _authorHandleMeta));
    }
    if (data.containsKey('caption')) {
      context.handle(_captionMeta,
          caption.isAcceptableOrUnknown(data['caption']!, _captionMeta));
    }
    if (data.containsKey('local_thumbnail_rel_path')) {
      context.handle(
          _localThumbnailRelPathMeta,
          localThumbnailRelPath.isAcceptableOrUnknown(
              data['local_thumbnail_rel_path']!, _localThumbnailRelPathMeta));
    } else if (isInserting) {
      context.missing(_localThumbnailRelPathMeta);
    }
    if (data.containsKey('local_video_rel_path')) {
      context.handle(
          _localVideoRelPathMeta,
          localVideoRelPath.isAcceptableOrUnknown(
              data['local_video_rel_path']!, _localVideoRelPathMeta));
    }
    if (data.containsKey('local_carousel_rel_paths_json')) {
      context.handle(
          _localCarouselRelPathsJsonMeta,
          localCarouselRelPathsJson.isAcceptableOrUnknown(
              data['local_carousel_rel_paths_json']!,
              _localCarouselRelPathsJsonMeta));
    }
    if (data.containsKey('watch_progress')) {
      context.handle(
          _watchProgressMeta,
          watchProgress.isAcceptableOrUnknown(
              data['watch_progress']!, _watchProgressMeta));
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    }
    if (data.containsKey('last_position_ms')) {
      context.handle(
          _lastPositionMsMeta,
          lastPositionMs.isAcceptableOrUnknown(
              data['last_position_ms']!, _lastPositionMsMeta));
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
          _fileSizeBytesMeta,
          fileSizeBytes.isAcceptableOrUnknown(
              data['file_size_bytes']!, _fileSizeBytesMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('last_watched_at')) {
      context.handle(
          _lastWatchedAtMeta,
          lastWatchedAt.isAcceptableOrUnknown(
              data['last_watched_at']!, _lastWatchedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VaultMediaEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaultMediaEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      shortcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shortcode'])!,
      canonicalUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}canonical_url'])!,
      collectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collection_id'])!,
      mediaType: $VaultMediaItemsTable.$convertermediaType.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}media_type'])!),
      authorHandle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author_handle'])!,
      caption: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}caption'])!,
      localThumbnailRelPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}local_thumbnail_rel_path'])!,
      localVideoRelPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_video_rel_path']),
      localCarouselRelPathsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}local_carousel_rel_paths_json'])!,
      watchProgress: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}watch_progress'])!,
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      lastPositionMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_position_ms'])!,
      fileSizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size_bytes'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastWatchedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_watched_at']),
    );
  }

  @override
  $VaultMediaItemsTable createAlias(String alias) {
    return $VaultMediaItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MediaType, int, int> $convertermediaType =
      const EnumIndexConverter<MediaType>(MediaType.values);
}

class VaultMediaEntity extends DataClass
    implements Insertable<VaultMediaEntity> {
  final String id;
  final String shortcode;
  final String canonicalUrl;
  final String collectionId;
  final MediaType mediaType;
  final String authorHandle;
  final String caption;
  final String localThumbnailRelPath;
  final String? localVideoRelPath;
  final String localCarouselRelPathsJson;
  final double watchProgress;
  final int durationMs;
  final int lastPositionMs;
  final int fileSizeBytes;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? lastWatchedAt;
  const VaultMediaEntity(
      {required this.id,
      required this.shortcode,
      required this.canonicalUrl,
      required this.collectionId,
      required this.mediaType,
      required this.authorHandle,
      required this.caption,
      required this.localThumbnailRelPath,
      this.localVideoRelPath,
      required this.localCarouselRelPathsJson,
      required this.watchProgress,
      required this.durationMs,
      required this.lastPositionMs,
      required this.fileSizeBytes,
      required this.isFavorite,
      required this.createdAt,
      this.lastWatchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shortcode'] = Variable<String>(shortcode);
    map['canonical_url'] = Variable<String>(canonicalUrl);
    map['collection_id'] = Variable<String>(collectionId);
    {
      map['media_type'] = Variable<int>(
          $VaultMediaItemsTable.$convertermediaType.toSql(mediaType));
    }
    map['author_handle'] = Variable<String>(authorHandle);
    map['caption'] = Variable<String>(caption);
    map['local_thumbnail_rel_path'] = Variable<String>(localThumbnailRelPath);
    if (!nullToAbsent || localVideoRelPath != null) {
      map['local_video_rel_path'] = Variable<String>(localVideoRelPath);
    }
    map['local_carousel_rel_paths_json'] =
        Variable<String>(localCarouselRelPathsJson);
    map['watch_progress'] = Variable<double>(watchProgress);
    map['duration_ms'] = Variable<int>(durationMs);
    map['last_position_ms'] = Variable<int>(lastPositionMs);
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastWatchedAt != null) {
      map['last_watched_at'] = Variable<DateTime>(lastWatchedAt);
    }
    return map;
  }

  VaultMediaItemsCompanion toCompanion(bool nullToAbsent) {
    return VaultMediaItemsCompanion(
      id: Value(id),
      shortcode: Value(shortcode),
      canonicalUrl: Value(canonicalUrl),
      collectionId: Value(collectionId),
      mediaType: Value(mediaType),
      authorHandle: Value(authorHandle),
      caption: Value(caption),
      localThumbnailRelPath: Value(localThumbnailRelPath),
      localVideoRelPath: localVideoRelPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localVideoRelPath),
      localCarouselRelPathsJson: Value(localCarouselRelPathsJson),
      watchProgress: Value(watchProgress),
      durationMs: Value(durationMs),
      lastPositionMs: Value(lastPositionMs),
      fileSizeBytes: Value(fileSizeBytes),
      isFavorite: Value(isFavorite),
      createdAt: Value(createdAt),
      lastWatchedAt: lastWatchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastWatchedAt),
    );
  }

  factory VaultMediaEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaultMediaEntity(
      id: serializer.fromJson<String>(json['id']),
      shortcode: serializer.fromJson<String>(json['shortcode']),
      canonicalUrl: serializer.fromJson<String>(json['canonicalUrl']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      mediaType: $VaultMediaItemsTable.$convertermediaType
          .fromJson(serializer.fromJson<int>(json['mediaType'])),
      authorHandle: serializer.fromJson<String>(json['authorHandle']),
      caption: serializer.fromJson<String>(json['caption']),
      localThumbnailRelPath:
          serializer.fromJson<String>(json['localThumbnailRelPath']),
      localVideoRelPath:
          serializer.fromJson<String?>(json['localVideoRelPath']),
      localCarouselRelPathsJson:
          serializer.fromJson<String>(json['localCarouselRelPathsJson']),
      watchProgress: serializer.fromJson<double>(json['watchProgress']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      lastPositionMs: serializer.fromJson<int>(json['lastPositionMs']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastWatchedAt: serializer.fromJson<DateTime?>(json['lastWatchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shortcode': serializer.toJson<String>(shortcode),
      'canonicalUrl': serializer.toJson<String>(canonicalUrl),
      'collectionId': serializer.toJson<String>(collectionId),
      'mediaType': serializer.toJson<int>(
          $VaultMediaItemsTable.$convertermediaType.toJson(mediaType)),
      'authorHandle': serializer.toJson<String>(authorHandle),
      'caption': serializer.toJson<String>(caption),
      'localThumbnailRelPath': serializer.toJson<String>(localThumbnailRelPath),
      'localVideoRelPath': serializer.toJson<String?>(localVideoRelPath),
      'localCarouselRelPathsJson':
          serializer.toJson<String>(localCarouselRelPathsJson),
      'watchProgress': serializer.toJson<double>(watchProgress),
      'durationMs': serializer.toJson<int>(durationMs),
      'lastPositionMs': serializer.toJson<int>(lastPositionMs),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastWatchedAt': serializer.toJson<DateTime?>(lastWatchedAt),
    };
  }

  VaultMediaEntity copyWith(
          {String? id,
          String? shortcode,
          String? canonicalUrl,
          String? collectionId,
          MediaType? mediaType,
          String? authorHandle,
          String? caption,
          String? localThumbnailRelPath,
          Value<String?> localVideoRelPath = const Value.absent(),
          String? localCarouselRelPathsJson,
          double? watchProgress,
          int? durationMs,
          int? lastPositionMs,
          int? fileSizeBytes,
          bool? isFavorite,
          DateTime? createdAt,
          Value<DateTime?> lastWatchedAt = const Value.absent()}) =>
      VaultMediaEntity(
        id: id ?? this.id,
        shortcode: shortcode ?? this.shortcode,
        canonicalUrl: canonicalUrl ?? this.canonicalUrl,
        collectionId: collectionId ?? this.collectionId,
        mediaType: mediaType ?? this.mediaType,
        authorHandle: authorHandle ?? this.authorHandle,
        caption: caption ?? this.caption,
        localThumbnailRelPath:
            localThumbnailRelPath ?? this.localThumbnailRelPath,
        localVideoRelPath: localVideoRelPath.present
            ? localVideoRelPath.value
            : this.localVideoRelPath,
        localCarouselRelPathsJson:
            localCarouselRelPathsJson ?? this.localCarouselRelPathsJson,
        watchProgress: watchProgress ?? this.watchProgress,
        durationMs: durationMs ?? this.durationMs,
        lastPositionMs: lastPositionMs ?? this.lastPositionMs,
        fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
        isFavorite: isFavorite ?? this.isFavorite,
        createdAt: createdAt ?? this.createdAt,
        lastWatchedAt:
            lastWatchedAt.present ? lastWatchedAt.value : this.lastWatchedAt,
      );
  VaultMediaEntity copyWithCompanion(VaultMediaItemsCompanion data) {
    return VaultMediaEntity(
      id: data.id.present ? data.id.value : this.id,
      shortcode: data.shortcode.present ? data.shortcode.value : this.shortcode,
      canonicalUrl: data.canonicalUrl.present
          ? data.canonicalUrl.value
          : this.canonicalUrl,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      authorHandle: data.authorHandle.present
          ? data.authorHandle.value
          : this.authorHandle,
      caption: data.caption.present ? data.caption.value : this.caption,
      localThumbnailRelPath: data.localThumbnailRelPath.present
          ? data.localThumbnailRelPath.value
          : this.localThumbnailRelPath,
      localVideoRelPath: data.localVideoRelPath.present
          ? data.localVideoRelPath.value
          : this.localVideoRelPath,
      localCarouselRelPathsJson: data.localCarouselRelPathsJson.present
          ? data.localCarouselRelPathsJson.value
          : this.localCarouselRelPathsJson,
      watchProgress: data.watchProgress.present
          ? data.watchProgress.value
          : this.watchProgress,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      lastPositionMs: data.lastPositionMs.present
          ? data.lastPositionMs.value
          : this.lastPositionMs,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastWatchedAt: data.lastWatchedAt.present
          ? data.lastWatchedAt.value
          : this.lastWatchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaultMediaEntity(')
          ..write('id: $id, ')
          ..write('shortcode: $shortcode, ')
          ..write('canonicalUrl: $canonicalUrl, ')
          ..write('collectionId: $collectionId, ')
          ..write('mediaType: $mediaType, ')
          ..write('authorHandle: $authorHandle, ')
          ..write('caption: $caption, ')
          ..write('localThumbnailRelPath: $localThumbnailRelPath, ')
          ..write('localVideoRelPath: $localVideoRelPath, ')
          ..write('localCarouselRelPathsJson: $localCarouselRelPathsJson, ')
          ..write('watchProgress: $watchProgress, ')
          ..write('durationMs: $durationMs, ')
          ..write('lastPositionMs: $lastPositionMs, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastWatchedAt: $lastWatchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      shortcode,
      canonicalUrl,
      collectionId,
      mediaType,
      authorHandle,
      caption,
      localThumbnailRelPath,
      localVideoRelPath,
      localCarouselRelPathsJson,
      watchProgress,
      durationMs,
      lastPositionMs,
      fileSizeBytes,
      isFavorite,
      createdAt,
      lastWatchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaultMediaEntity &&
          other.id == this.id &&
          other.shortcode == this.shortcode &&
          other.canonicalUrl == this.canonicalUrl &&
          other.collectionId == this.collectionId &&
          other.mediaType == this.mediaType &&
          other.authorHandle == this.authorHandle &&
          other.caption == this.caption &&
          other.localThumbnailRelPath == this.localThumbnailRelPath &&
          other.localVideoRelPath == this.localVideoRelPath &&
          other.localCarouselRelPathsJson == this.localCarouselRelPathsJson &&
          other.watchProgress == this.watchProgress &&
          other.durationMs == this.durationMs &&
          other.lastPositionMs == this.lastPositionMs &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt &&
          other.lastWatchedAt == this.lastWatchedAt);
}

class VaultMediaItemsCompanion extends UpdateCompanion<VaultMediaEntity> {
  final Value<String> id;
  final Value<String> shortcode;
  final Value<String> canonicalUrl;
  final Value<String> collectionId;
  final Value<MediaType> mediaType;
  final Value<String> authorHandle;
  final Value<String> caption;
  final Value<String> localThumbnailRelPath;
  final Value<String?> localVideoRelPath;
  final Value<String> localCarouselRelPathsJson;
  final Value<double> watchProgress;
  final Value<int> durationMs;
  final Value<int> lastPositionMs;
  final Value<int> fileSizeBytes;
  final Value<bool> isFavorite;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastWatchedAt;
  final Value<int> rowid;
  const VaultMediaItemsCompanion({
    this.id = const Value.absent(),
    this.shortcode = const Value.absent(),
    this.canonicalUrl = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.authorHandle = const Value.absent(),
    this.caption = const Value.absent(),
    this.localThumbnailRelPath = const Value.absent(),
    this.localVideoRelPath = const Value.absent(),
    this.localCarouselRelPathsJson = const Value.absent(),
    this.watchProgress = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.lastPositionMs = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastWatchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaultMediaItemsCompanion.insert({
    required String id,
    required String shortcode,
    required String canonicalUrl,
    required String collectionId,
    required MediaType mediaType,
    this.authorHandle = const Value.absent(),
    this.caption = const Value.absent(),
    required String localThumbnailRelPath,
    this.localVideoRelPath = const Value.absent(),
    this.localCarouselRelPathsJson = const Value.absent(),
    this.watchProgress = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.lastPositionMs = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastWatchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        shortcode = Value(shortcode),
        canonicalUrl = Value(canonicalUrl),
        collectionId = Value(collectionId),
        mediaType = Value(mediaType),
        localThumbnailRelPath = Value(localThumbnailRelPath);
  static Insertable<VaultMediaEntity> custom({
    Expression<String>? id,
    Expression<String>? shortcode,
    Expression<String>? canonicalUrl,
    Expression<String>? collectionId,
    Expression<int>? mediaType,
    Expression<String>? authorHandle,
    Expression<String>? caption,
    Expression<String>? localThumbnailRelPath,
    Expression<String>? localVideoRelPath,
    Expression<String>? localCarouselRelPathsJson,
    Expression<double>? watchProgress,
    Expression<int>? durationMs,
    Expression<int>? lastPositionMs,
    Expression<int>? fileSizeBytes,
    Expression<bool>? isFavorite,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastWatchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shortcode != null) 'shortcode': shortcode,
      if (canonicalUrl != null) 'canonical_url': canonicalUrl,
      if (collectionId != null) 'collection_id': collectionId,
      if (mediaType != null) 'media_type': mediaType,
      if (authorHandle != null) 'author_handle': authorHandle,
      if (caption != null) 'caption': caption,
      if (localThumbnailRelPath != null)
        'local_thumbnail_rel_path': localThumbnailRelPath,
      if (localVideoRelPath != null) 'local_video_rel_path': localVideoRelPath,
      if (localCarouselRelPathsJson != null)
        'local_carousel_rel_paths_json': localCarouselRelPathsJson,
      if (watchProgress != null) 'watch_progress': watchProgress,
      if (durationMs != null) 'duration_ms': durationMs,
      if (lastPositionMs != null) 'last_position_ms': lastPositionMs,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
      if (lastWatchedAt != null) 'last_watched_at': lastWatchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaultMediaItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? shortcode,
      Value<String>? canonicalUrl,
      Value<String>? collectionId,
      Value<MediaType>? mediaType,
      Value<String>? authorHandle,
      Value<String>? caption,
      Value<String>? localThumbnailRelPath,
      Value<String?>? localVideoRelPath,
      Value<String>? localCarouselRelPathsJson,
      Value<double>? watchProgress,
      Value<int>? durationMs,
      Value<int>? lastPositionMs,
      Value<int>? fileSizeBytes,
      Value<bool>? isFavorite,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastWatchedAt,
      Value<int>? rowid}) {
    return VaultMediaItemsCompanion(
      id: id ?? this.id,
      shortcode: shortcode ?? this.shortcode,
      canonicalUrl: canonicalUrl ?? this.canonicalUrl,
      collectionId: collectionId ?? this.collectionId,
      mediaType: mediaType ?? this.mediaType,
      authorHandle: authorHandle ?? this.authorHandle,
      caption: caption ?? this.caption,
      localThumbnailRelPath:
          localThumbnailRelPath ?? this.localThumbnailRelPath,
      localVideoRelPath: localVideoRelPath ?? this.localVideoRelPath,
      localCarouselRelPathsJson:
          localCarouselRelPathsJson ?? this.localCarouselRelPathsJson,
      watchProgress: watchProgress ?? this.watchProgress,
      durationMs: durationMs ?? this.durationMs,
      lastPositionMs: lastPositionMs ?? this.lastPositionMs,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shortcode.present) {
      map['shortcode'] = Variable<String>(shortcode.value);
    }
    if (canonicalUrl.present) {
      map['canonical_url'] = Variable<String>(canonicalUrl.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<int>(
          $VaultMediaItemsTable.$convertermediaType.toSql(mediaType.value));
    }
    if (authorHandle.present) {
      map['author_handle'] = Variable<String>(authorHandle.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (localThumbnailRelPath.present) {
      map['local_thumbnail_rel_path'] =
          Variable<String>(localThumbnailRelPath.value);
    }
    if (localVideoRelPath.present) {
      map['local_video_rel_path'] = Variable<String>(localVideoRelPath.value);
    }
    if (localCarouselRelPathsJson.present) {
      map['local_carousel_rel_paths_json'] =
          Variable<String>(localCarouselRelPathsJson.value);
    }
    if (watchProgress.present) {
      map['watch_progress'] = Variable<double>(watchProgress.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (lastPositionMs.present) {
      map['last_position_ms'] = Variable<int>(lastPositionMs.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastWatchedAt.present) {
      map['last_watched_at'] = Variable<DateTime>(lastWatchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaultMediaItemsCompanion(')
          ..write('id: $id, ')
          ..write('shortcode: $shortcode, ')
          ..write('canonicalUrl: $canonicalUrl, ')
          ..write('collectionId: $collectionId, ')
          ..write('mediaType: $mediaType, ')
          ..write('authorHandle: $authorHandle, ')
          ..write('caption: $caption, ')
          ..write('localThumbnailRelPath: $localThumbnailRelPath, ')
          ..write('localVideoRelPath: $localVideoRelPath, ')
          ..write('localCarouselRelPathsJson: $localCarouselRelPathsJson, ')
          ..write('watchProgress: $watchProgress, ')
          ..write('durationMs: $durationMs, ')
          ..write('lastPositionMs: $lastPositionMs, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastWatchedAt: $lastWatchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $VaultMediaItemsTable vaultMediaItems =
      $VaultMediaItemsTable(this);
  late final Index idxMediaShortcode = Index('idx_media_shortcode',
      'CREATE UNIQUE INDEX idx_media_shortcode ON vault_media_items (shortcode)');
  late final Index idxMediaCollection = Index('idx_media_collection',
      'CREATE INDEX idx_media_collection ON vault_media_items (collection_id)');
  late final Index idxMediaProgress = Index('idx_media_progress',
      'CREATE INDEX idx_media_progress ON vault_media_items (watch_progress)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        collections,
        vaultMediaItems,
        idxMediaShortcode,
        idxMediaCollection,
        idxMediaProgress
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('collections',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('vault_media_items', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$CollectionsTableCreateCompanionBuilder = CollectionsCompanion
    Function({
  required String id,
  required String name,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$CollectionsTableUpdateCompanionBuilder = CollectionsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$CollectionsTableReferences
    extends BaseReferences<_$AppDatabase, $CollectionsTable, CollectionEntity> {
  $$CollectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VaultMediaItemsTable, List<VaultMediaEntity>>
      _vaultMediaItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.vaultMediaItems,
              aliasName: $_aliasNameGenerator(
                  db.collections.id, db.vaultMediaItems.collectionId));

  $$VaultMediaItemsTableProcessedTableManager get vaultMediaItemsRefs {
    final manager =
        $$VaultMediaItemsTableTableManager($_db, $_db.vaultMediaItems).filter(
            (f) => f.collectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_vaultMediaItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> vaultMediaItemsRefs(
      Expression<bool> Function($$VaultMediaItemsTableFilterComposer f) f) {
    final $$VaultMediaItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vaultMediaItems,
        getReferencedColumn: (t) => t.collectionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VaultMediaItemsTableFilterComposer(
              $db: $db,
              $table: $db.vaultMediaItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> vaultMediaItemsRefs<T extends Object>(
      Expression<T> Function($$VaultMediaItemsTableAnnotationComposer a) f) {
    final $$VaultMediaItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vaultMediaItems,
        getReferencedColumn: (t) => t.collectionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VaultMediaItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.vaultMediaItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CollectionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CollectionsTable,
    CollectionEntity,
    $$CollectionsTableFilterComposer,
    $$CollectionsTableOrderingComposer,
    $$CollectionsTableAnnotationComposer,
    $$CollectionsTableCreateCompanionBuilder,
    $$CollectionsTableUpdateCompanionBuilder,
    (CollectionEntity, $$CollectionsTableReferences),
    CollectionEntity,
    PrefetchHooks Function({bool vaultMediaItemsRefs})> {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CollectionsCompanion(
            id: id,
            name: name,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CollectionsCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CollectionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({vaultMediaItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (vaultMediaItemsRefs) db.vaultMediaItems
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (vaultMediaItemsRefs)
                    await $_getPrefetchedData<CollectionEntity,
                            $CollectionsTable, VaultMediaEntity>(
                        currentTable: table,
                        referencedTable: $$CollectionsTableReferences
                            ._vaultMediaItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CollectionsTableReferences(db, table, p0)
                                .vaultMediaItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.collectionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CollectionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CollectionsTable,
    CollectionEntity,
    $$CollectionsTableFilterComposer,
    $$CollectionsTableOrderingComposer,
    $$CollectionsTableAnnotationComposer,
    $$CollectionsTableCreateCompanionBuilder,
    $$CollectionsTableUpdateCompanionBuilder,
    (CollectionEntity, $$CollectionsTableReferences),
    CollectionEntity,
    PrefetchHooks Function({bool vaultMediaItemsRefs})>;
typedef $$VaultMediaItemsTableCreateCompanionBuilder = VaultMediaItemsCompanion
    Function({
  required String id,
  required String shortcode,
  required String canonicalUrl,
  required String collectionId,
  required MediaType mediaType,
  Value<String> authorHandle,
  Value<String> caption,
  required String localThumbnailRelPath,
  Value<String?> localVideoRelPath,
  Value<String> localCarouselRelPathsJson,
  Value<double> watchProgress,
  Value<int> durationMs,
  Value<int> lastPositionMs,
  Value<int> fileSizeBytes,
  Value<bool> isFavorite,
  Value<DateTime> createdAt,
  Value<DateTime?> lastWatchedAt,
  Value<int> rowid,
});
typedef $$VaultMediaItemsTableUpdateCompanionBuilder = VaultMediaItemsCompanion
    Function({
  Value<String> id,
  Value<String> shortcode,
  Value<String> canonicalUrl,
  Value<String> collectionId,
  Value<MediaType> mediaType,
  Value<String> authorHandle,
  Value<String> caption,
  Value<String> localThumbnailRelPath,
  Value<String?> localVideoRelPath,
  Value<String> localCarouselRelPathsJson,
  Value<double> watchProgress,
  Value<int> durationMs,
  Value<int> lastPositionMs,
  Value<int> fileSizeBytes,
  Value<bool> isFavorite,
  Value<DateTime> createdAt,
  Value<DateTime?> lastWatchedAt,
  Value<int> rowid,
});

final class $$VaultMediaItemsTableReferences extends BaseReferences<
    _$AppDatabase, $VaultMediaItemsTable, VaultMediaEntity> {
  $$VaultMediaItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CollectionsTable _collectionIdTable(_$AppDatabase db) =>
      db.collections.createAlias($_aliasNameGenerator(
          db.vaultMediaItems.collectionId, db.collections.id));

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<String>('collection_id')!;

    final manager = $$CollectionsTableTableManager($_db, $_db.collections)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$VaultMediaItemsTableFilterComposer
    extends Composer<_$AppDatabase, $VaultMediaItemsTable> {
  $$VaultMediaItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shortcode => $composableBuilder(
      column: $table.shortcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get canonicalUrl => $composableBuilder(
      column: $table.canonicalUrl, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<MediaType, MediaType, int> get mediaType =>
      $composableBuilder(
          column: $table.mediaType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get authorHandle => $composableBuilder(
      column: $table.authorHandle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localThumbnailRelPath => $composableBuilder(
      column: $table.localThumbnailRelPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localVideoRelPath => $composableBuilder(
      column: $table.localVideoRelPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localCarouselRelPathsJson => $composableBuilder(
      column: $table.localCarouselRelPathsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get watchProgress => $composableBuilder(
      column: $table.watchProgress, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastPositionMs => $composableBuilder(
      column: $table.lastPositionMs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastWatchedAt => $composableBuilder(
      column: $table.lastWatchedAt, builder: (column) => ColumnFilters(column));

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectionId,
        referencedTable: $db.collections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionsTableFilterComposer(
              $db: $db,
              $table: $db.collections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VaultMediaItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $VaultMediaItemsTable> {
  $$VaultMediaItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shortcode => $composableBuilder(
      column: $table.shortcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get canonicalUrl => $composableBuilder(
      column: $table.canonicalUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorHandle => $composableBuilder(
      column: $table.authorHandle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localThumbnailRelPath => $composableBuilder(
      column: $table.localThumbnailRelPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localVideoRelPath => $composableBuilder(
      column: $table.localVideoRelPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localCarouselRelPathsJson => $composableBuilder(
      column: $table.localCarouselRelPathsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get watchProgress => $composableBuilder(
      column: $table.watchProgress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastPositionMs => $composableBuilder(
      column: $table.lastPositionMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastWatchedAt => $composableBuilder(
      column: $table.lastWatchedAt,
      builder: (column) => ColumnOrderings(column));

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectionId,
        referencedTable: $db.collections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionsTableOrderingComposer(
              $db: $db,
              $table: $db.collections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VaultMediaItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VaultMediaItemsTable> {
  $$VaultMediaItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shortcode =>
      $composableBuilder(column: $table.shortcode, builder: (column) => column);

  GeneratedColumn<String> get canonicalUrl => $composableBuilder(
      column: $table.canonicalUrl, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MediaType, int> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get authorHandle => $composableBuilder(
      column: $table.authorHandle, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<String> get localThumbnailRelPath => $composableBuilder(
      column: $table.localThumbnailRelPath, builder: (column) => column);

  GeneratedColumn<String> get localVideoRelPath => $composableBuilder(
      column: $table.localVideoRelPath, builder: (column) => column);

  GeneratedColumn<String> get localCarouselRelPathsJson => $composableBuilder(
      column: $table.localCarouselRelPathsJson, builder: (column) => column);

  GeneratedColumn<double> get watchProgress => $composableBuilder(
      column: $table.watchProgress, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<int> get lastPositionMs => $composableBuilder(
      column: $table.lastPositionMs, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastWatchedAt => $composableBuilder(
      column: $table.lastWatchedAt, builder: (column) => column);

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectionId,
        referencedTable: $db.collections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionsTableAnnotationComposer(
              $db: $db,
              $table: $db.collections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VaultMediaItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VaultMediaItemsTable,
    VaultMediaEntity,
    $$VaultMediaItemsTableFilterComposer,
    $$VaultMediaItemsTableOrderingComposer,
    $$VaultMediaItemsTableAnnotationComposer,
    $$VaultMediaItemsTableCreateCompanionBuilder,
    $$VaultMediaItemsTableUpdateCompanionBuilder,
    (VaultMediaEntity, $$VaultMediaItemsTableReferences),
    VaultMediaEntity,
    PrefetchHooks Function({bool collectionId})> {
  $$VaultMediaItemsTableTableManager(
      _$AppDatabase db, $VaultMediaItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaultMediaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaultMediaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaultMediaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> shortcode = const Value.absent(),
            Value<String> canonicalUrl = const Value.absent(),
            Value<String> collectionId = const Value.absent(),
            Value<MediaType> mediaType = const Value.absent(),
            Value<String> authorHandle = const Value.absent(),
            Value<String> caption = const Value.absent(),
            Value<String> localThumbnailRelPath = const Value.absent(),
            Value<String?> localVideoRelPath = const Value.absent(),
            Value<String> localCarouselRelPathsJson = const Value.absent(),
            Value<double> watchProgress = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<int> lastPositionMs = const Value.absent(),
            Value<int> fileSizeBytes = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastWatchedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VaultMediaItemsCompanion(
            id: id,
            shortcode: shortcode,
            canonicalUrl: canonicalUrl,
            collectionId: collectionId,
            mediaType: mediaType,
            authorHandle: authorHandle,
            caption: caption,
            localThumbnailRelPath: localThumbnailRelPath,
            localVideoRelPath: localVideoRelPath,
            localCarouselRelPathsJson: localCarouselRelPathsJson,
            watchProgress: watchProgress,
            durationMs: durationMs,
            lastPositionMs: lastPositionMs,
            fileSizeBytes: fileSizeBytes,
            isFavorite: isFavorite,
            createdAt: createdAt,
            lastWatchedAt: lastWatchedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String shortcode,
            required String canonicalUrl,
            required String collectionId,
            required MediaType mediaType,
            Value<String> authorHandle = const Value.absent(),
            Value<String> caption = const Value.absent(),
            required String localThumbnailRelPath,
            Value<String?> localVideoRelPath = const Value.absent(),
            Value<String> localCarouselRelPathsJson = const Value.absent(),
            Value<double> watchProgress = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<int> lastPositionMs = const Value.absent(),
            Value<int> fileSizeBytes = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastWatchedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VaultMediaItemsCompanion.insert(
            id: id,
            shortcode: shortcode,
            canonicalUrl: canonicalUrl,
            collectionId: collectionId,
            mediaType: mediaType,
            authorHandle: authorHandle,
            caption: caption,
            localThumbnailRelPath: localThumbnailRelPath,
            localVideoRelPath: localVideoRelPath,
            localCarouselRelPathsJson: localCarouselRelPathsJson,
            watchProgress: watchProgress,
            durationMs: durationMs,
            lastPositionMs: lastPositionMs,
            fileSizeBytes: fileSizeBytes,
            isFavorite: isFavorite,
            createdAt: createdAt,
            lastWatchedAt: lastWatchedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$VaultMediaItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({collectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (collectionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.collectionId,
                    referencedTable:
                        $$VaultMediaItemsTableReferences._collectionIdTable(db),
                    referencedColumn: $$VaultMediaItemsTableReferences
                        ._collectionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$VaultMediaItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VaultMediaItemsTable,
    VaultMediaEntity,
    $$VaultMediaItemsTableFilterComposer,
    $$VaultMediaItemsTableOrderingComposer,
    $$VaultMediaItemsTableAnnotationComposer,
    $$VaultMediaItemsTableCreateCompanionBuilder,
    $$VaultMediaItemsTableUpdateCompanionBuilder,
    (VaultMediaEntity, $$VaultMediaItemsTableReferences),
    VaultMediaEntity,
    PrefetchHooks Function({bool collectionId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$VaultMediaItemsTableTableManager get vaultMediaItems =>
      $$VaultMediaItemsTableTableManager(_db, _db.vaultMediaItems);
}
