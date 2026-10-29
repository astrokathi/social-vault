import 'package:flutter_test/flutter_test.dart';
import 'package:reel_vault/core/utils/url_sanitizer.dart';
import 'package:reel_vault/features/feed/providers/feed_queue_provider.dart';

void main() {
  group('UrlSanitizer Unit Tests', () {
    test('Correctly extracts shortcode and strips tracking query parameters', () {
      const rawUrl = 'https://www.instagram.com/reel/C9xLmP2oQ1z/?igsh=MWZ4Nm12&utm_source=qr';
      final result = UrlSanitizer.parseInstagramUrl(rawUrl);

      expect(result, isNotNull);
      expect(result!.shortcode, equals('C9xLmP2oQ1z'));
      expect(result.canonicalUrl, equals('https://www.instagram.com/reel/C9xLmP2oQ1z/'));
    });

    test('Correctly parses Instagram post/carousel URLs', () {
      const rawPostUrl = 'https://instagram.com/p/C8kPqR9vW4m/';
      final result = UrlSanitizer.parseInstagramUrl(rawPostUrl);

      expect(result, isNotNull);
      expect(result!.shortcode, equals('C8kPqR9vW4m'));
      expect(result.canonicalUrl, equals('https://www.instagram.com/reel/C8kPqR9vW4m/'));
    });

    test('Returns null for non-instagram URLs', () {
      expect(UrlSanitizer.parseInstagramUrl('https://google.com'), isNull);
      expect(UrlSanitizer.parseInstagramUrl(''), isNull);
    });

    test('Formats bytes to human-readable strings', () {
      expect(UrlSanitizer.formatBytes(0), equals('0 B'));
      expect(UrlSanitizer.formatBytes(1024), equals('1.0 KB'));
      expect(UrlSanitizer.formatBytes(14889779), equals('14.2 MB'));
      expect(UrlSanitizer.formatBytes(2147483648), equals('2.0 GB'));
    });

    test('Formats duration in milliseconds to mm:ss', () {
      expect(UrlSanitizer.formatDuration(0), equals('0:00'));
      expect(UrlSanitizer.formatDuration(34000), equals('0:34'));
      expect(UrlSanitizer.formatDuration(125000), equals('2:05'));
    });
  });

  group('FeedFilterNotifier Unit Tests', () {
    test('Toggles between sequence and shuffle playback modes', () {
      final notifier = FeedFilterNotifier();
      expect(notifier.state.orderMode, equals(PlaybackOrderMode.sequence));

      notifier.toggleOrderMode();
      expect(notifier.state.orderMode, equals(PlaybackOrderMode.random));

      notifier.toggleOrderMode();
      expect(notifier.state.orderMode, equals(PlaybackOrderMode.sequence));
    });

    test('Toggles hide watched filter', () {
      final notifier = FeedFilterNotifier();
      expect(notifier.state.hideWatched, isTrue);

      notifier.toggleHideWatched();
      expect(notifier.state.hideWatched, isFalse);

      notifier.toggleHideWatched();
      expect(notifier.state.hideWatched, isTrue);
    });
  });
}
