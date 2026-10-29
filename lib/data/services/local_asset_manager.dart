import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'og_extractor_service.dart';

class SavedLocalMediaResult {
  final String thumbnailRelPath;
  final String? videoRelPath;
  final String carouselRelPathsJson;
  final int totalBytes;

  SavedLocalMediaResult({
    required this.thumbnailRelPath,
    this.videoRelPath,
    required this.carouselRelPathsJson,
    required this.totalBytes,
  });
}

class LocalAssetManager {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// Base directory for all downloaded vault media
  Future<Directory> get _vaultMediaDir async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docsDir.path, 'vault_media'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Resolves a stored relative path (e.g. "vault_media/C9xLm.../thumb.webp")
  /// to the current runtime absolute path in the device's sandbox.
  Future<String> resolveFullPath(String relPath) async {
    if (relPath.startsWith('http://') || relPath.startsWith('https://')) {
      return relPath; // Remote URL fallback
    }
    final docsDir = await getApplicationDocumentsDirectory();
    return p.join(docsDir.path, relPath);
  }

  /// Downloads binary files for an extracted Reel or Carousel, saving them
  /// directly into the device's sandbox to prevent link expiration.
  Future<SavedLocalMediaResult> downloadAndSaveMedia({
    required ExtractedMediaMetadata metadata,
    required String collectionId,
  }) async {
    final baseVault = await _vaultMediaDir;
    final itemDir = Directory(p.join(baseVault.path, metadata.shortcode));
    if (!await itemDir.exists()) {
      await itemDir.create(recursive: true);
    }

    int totalBytes = 0;
    String thumbnailRelPath = metadata.thumbnailRemoteUrl;
    String? videoRelPath;
    List<String> carouselRelPaths = [];

    // 1. Download and save thumbnail
    try {
      if (metadata.thumbnailRemoteUrl.isNotEmpty &&
          metadata.thumbnailRemoteUrl.startsWith('http')) {
        final thumbFile = File(p.join(itemDir.path, 'thumb.jpg'));
        await _dio.download(
          metadata.thumbnailRemoteUrl,
          thumbFile.path,
        );
        if (await thumbFile.exists()) {
          final size = await thumbFile.length();
          totalBytes += size;
          thumbnailRelPath = p.join('vault_media', metadata.shortcode, 'thumb.jpg');
        }
      }
    } catch (_) {
      // Fallback: keep remote URL if download fails (offline or blocked)
      thumbnailRelPath = metadata.thumbnailRemoteUrl;
    }

    // 2. Download and save Video if present
    if (metadata.videoRemoteUrl != null &&
        metadata.videoRemoteUrl!.startsWith('http')) {
      try {
        final videoFile = File(p.join(itemDir.path, 'video.mp4'));
        await _dio.download(metadata.videoRemoteUrl!, videoFile.path);
        if (await videoFile.exists()) {
          final size = await videoFile.length();
          totalBytes += size;
          videoRelPath = p.join('vault_media', metadata.shortcode, 'video.mp4');
        }
      } catch (_) {
        videoRelPath = null;
      }
    }

    // 3. Download and save Carousel slides if present
    for (int i = 0; i < metadata.carouselRemoteUrls.length; i++) {
      final slideUrl = metadata.carouselRemoteUrls[i];
      try {
        final slideFile = File(p.join(itemDir.path, 'slide_$i.jpg'));
        await _dio.download(slideUrl, slideFile.path);
        if (await slideFile.exists()) {
          final size = await slideFile.length();
          totalBytes += size;
          carouselRelPaths.add(p.join('vault_media', metadata.shortcode, 'slide_$i.jpg'));
        }
      } catch (_) {
        carouselRelPaths.add(slideUrl);
      }
    }

    if (totalBytes == 0) {
      totalBytes = metadata.estimatedSizeBytes;
    }

    return SavedLocalMediaResult(
      thumbnailRelPath: thumbnailRelPath,
      videoRelPath: videoRelPath,
      carouselRelPathsJson: jsonEncode(carouselRelPaths),
      totalBytes: totalBytes,
    );
  }

  /// Calculates actual on-disk bytes of the vault_media sandbox folder
  Future<int> calculateDiskUsageBytes() async {
    final baseVault = await _vaultMediaDir;
    int total = 0;
    if (await baseVault.exists()) {
      await for (final file in baseVault.list(recursive: true, followLinks: false)) {
        if (file is File) {
          total += await file.length();
        }
      }
    }
    return total;
  }

  /// Deletes a specific media item's sandbox directory
  Future<void> deleteMediaFolder(String shortcode) async {
    final baseVault = await _vaultMediaDir;
    final itemDir = Directory(p.join(baseVault.path, shortcode));
    if (await itemDir.exists()) {
      await itemDir.delete(recursive: true);
    }
  }

  /// Wipes all media folders from disk
  Future<void> wipeAllMedia() async {
    final baseVault = await _vaultMediaDir;
    if (await baseVault.exists()) {
      await baseVault.delete(recursive: true);
      await baseVault.create(recursive: true);
    }
  }
}

final localAssetManagerProvider = Provider<LocalAssetManager>((ref) {
  return LocalAssetManager();
});
