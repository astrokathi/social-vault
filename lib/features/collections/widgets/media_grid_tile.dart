import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/url_sanitizer.dart';
import '../../../data/database/app_database.dart';

class MediaGridTile extends StatelessWidget {
  final VaultMediaEntity item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const MediaGridTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isWatched = item.watchProgress >= 0.98;

    return InkWell(
      onTap: onTap,
      onLongPress: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.charcoal,
            title: Text('Delete Reel', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
            content: Text(
              'Remove #${item.shortcode} from local vault? This deletes downloaded files.',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onDelete();
                },
                child: const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Thumbnail Image
            Image.network(
              item.localThumbnailRelPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppTheme.charcoal,
                child: const Center(
                  child: Icon(PhosphorIconsRegular.imageBroken, size: 24, color: Colors.white24),
                ),
              ),
            ),

            // 2. Subtle Gradient Overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // 3. Top Left Type Badge
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.mediaType == MediaType.carousel
                      ? PhosphorIconsFill.images
                      : PhosphorIconsFill.filmReel,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),

            // 4. Top Right Duration / Slide Badge
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.mediaType == MediaType.carousel
                      ? 'Slide'
                      : UrlSanitizer.formatDuration(item.durationMs),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // 5. Watched Checkmark Badge (If 100% Watched)
            if (isWatched)
              Positioned(
                bottom: 8,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    PhosphorIconsBold.check,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),

            // 6. Bottom Red/Orange Watch Progress Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 3,
                color: Colors.black.withValues(alpha: 0.4),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: item.watchProgress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.accentPillGradient,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
