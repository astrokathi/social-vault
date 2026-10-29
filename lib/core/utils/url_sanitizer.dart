class UrlSanitizer {
  static final RegExp _igRegex = RegExp(
    r'instagram\.com\/(?:p|reel|reels|tv)\/([A-Za-z0-9_-]+)',
    caseSensitive: false,
  );

  /// Extracts shortcode (e.g. 'C9xLmP2oQ1z') and returns clean canonical URL
  /// Strips query tracking parameters (?igsh=..., ?utm_source=..., etc.)
  static ({String shortcode, String canonicalUrl})? parseInstagramUrl(String rawSharedText) {
    if (rawSharedText.isEmpty) return null;

    final match = _igRegex.firstMatch(rawSharedText);
    if (match == null) return null;

    final shortcode = match.group(1)!;
    return (
      shortcode: shortcode,
      canonicalUrl: 'https://www.instagram.com/reel/$shortcode/',
    );
  }

  /// Formats byte numbers into clean human readable strings (e.g. 14.2 MB)
  static String formatBytes(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double count = bytes.toDouble();
    while (count >= 1024 && i < suffixes.length - 1) {
      count /= 1024;
      i++;
    }
    return '${count.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// Formats millisecond duration into mm:ss
  static String formatDuration(int ms) {
    if (ms <= 0) return '0:00';
    final totalSec = (ms / 1000).round();
    final minutes = totalSec ~/ 60;
    final seconds = totalSec % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
