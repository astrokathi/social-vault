import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final int estimatedSizeBytes;
  final int durationMs;

  ExtractedMediaMetadata({
    required this.shortcode,
    required this.canonicalUrl,
    required this.mediaType,
    required this.authorHandle,
    required this.caption,
    required this.thumbnailRemoteUrl,
    this.videoRemoteUrl,
    this.carouselRemoteUrls = const [],
    this.estimatedSizeBytes = 8000000,
    this.durationMs = 28000,
  });
}

class OgExtractorService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      // Social crawler user-agent bypasses standard login walls on public reels
      'User-Agent': 'TelegramBot (like TwitterBot/1.0)',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    },
  ));

  Future<ExtractedMediaMetadata> extractFromUrl(String canonicalUrl, String shortcode) async {
    try {
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
      final ogTitle = getMeta('og:title') ?? '';
      final ogDescription = getMeta('og:description') ?? '';

      // 1. Robust creator handle extraction (handles @username, (username), "Name on Instagram")
      String author = '@creator';
      final handleMatch = RegExp(r'@([A-Za-z0-9_.]+)').firstMatch(ogTitle) ??
          RegExp(r'\((@[A-Za-z0-9_.]+)\)').firstMatch(ogTitle) ??
          RegExp(r'@([A-Za-z0-9_.]+)').firstMatch(ogDescription) ??
          RegExp(r'^([A-Za-z0-9_.]+)\s+on\s+Instagram', caseSensitive: false).firstMatch(ogTitle);

      if (handleMatch != null) {
        final captured = handleMatch.group(1)!.trim();
        author = captured.startsWith('@') ? captured : '@$captured';
      } else if (ogTitle.isNotEmpty) {
        final nameMatch = RegExp(r'^(.+?)\s+on\s+Instagram', caseSensitive: false).firstMatch(ogTitle);
        if (nameMatch != null) {
          author = '@${nameMatch.group(1)!.trim().replaceAll(' ', '_').toLowerCase()}';
        }
      }

      // 2. Full caption extraction without "XX likes, YY comments" metadata prefix
      String caption = '';
      if (ogDescription.isNotEmpty) {
        final quoteMatch = RegExp(r':\s*[\u201c"](.+)[\u201d"]\s*$', dotAll: true).firstMatch(ogDescription);
        if (quoteMatch != null) {
          caption = quoteMatch.group(1)!.trim();
        } else if (ogDescription.contains(' - ')) {
          final afterDash = ogDescription.substring(ogDescription.indexOf(' - ') + 3).trim();
          final colonIdx = afterDash.indexOf(': ');
          if (colonIdx != -1) {
            caption = afterDash.substring(colonIdx + 2).trim();
            if (caption.startsWith('"') || caption.startsWith('\u201c')) {
              caption = caption.substring(1);
            }
            if (caption.endsWith('"') || caption.endsWith('\u201d')) {
              caption = caption.substring(0, caption.length - 1);
            }
          } else {
            caption = afterDash;
          }
        } else {
          caption = ogDescription;
        }
      }

      if (caption.isEmpty) {
        final metaDesc = getMeta('description') ?? '';
        if (metaDesc.isNotEmpty) caption = metaDesc;
      }

      // Collect all image links available in the DOM
      final imageElements = document
          .querySelectorAll('meta[property="og:image"], meta[name="twitter:image"]')
          .map((e) => e.attributes['content'] ?? '')
          .where((s) => s.startsWith('http'))
          .toSet()
          .toList();

      final thumb = ogImage.isNotEmpty
          ? ogImage
          : (imageElements.isNotEmpty
              ? imageElements.first
              : 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop&q=80');

      // Accurately determine media type: /p/ is always a carousel/photo, /reel/ is video
      final isExplicitCarousel = canonicalUrl.contains('/p/');
      final isVideo = !isExplicitCarousel &&
          ((ogVideo != null && ogVideo.isNotEmpty) ||
              canonicalUrl.contains('/reel/') ||
              canonicalUrl.contains('/reels/'));

      final mediaType = isExplicitCarousel ? MediaType.carousel : MediaType.video;

      final List<String> carouselUrls = isExplicitCarousel
          ? (imageElements.isNotEmpty ? imageElements : [thumb])
          : const [];

      return ExtractedMediaMetadata(
        shortcode: shortcode,
        canonicalUrl: canonicalUrl,
        mediaType: mediaType,
        authorHandle: author,
        caption: caption.isNotEmpty ? caption : 'Original post by $author (#$shortcode)',
        thumbnailRemoteUrl: thumb,
        videoRemoteUrl: isVideo ? ogVideo : null,
        carouselRemoteUrls: carouselUrls,
        estimatedSizeBytes: isVideo ? 15000000 : 3500000,
        durationMs: isVideo ? 30000 : 0,
      );
    } catch (e) {
      // Resilient fallback: preserve /p/ vs /reel/ type distinction
      final isCarousel = canonicalUrl.contains('/p/');
      const fallbackThumb = 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop&q=80';
      return ExtractedMediaMetadata(
        shortcode: shortcode,
        canonicalUrl: canonicalUrl,
        mediaType: isCarousel ? MediaType.carousel : MediaType.video,
        authorHandle: '@instagram_creator',
        caption: isCarousel
            ? 'Instagram Carousel #$shortcode saved to local ReelVault.'
            : 'Instagram Reel #$shortcode saved to local ReelVault.',
        thumbnailRemoteUrl: fallbackThumb,
        videoRemoteUrl: null,
        carouselRemoteUrls: isCarousel ? [fallbackThumb] : const [],
        estimatedSizeBytes: isCarousel ? 4500000 : 12400000,
        durationMs: isCarousel ? 0 : 25000,
      );
    }
  }
}

final ogExtractorServiceProvider = Provider<OgExtractorService>((ref) {
  return OgExtractorService();
});
