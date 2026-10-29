import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/feed_queue_provider.dart';

class FeedTopControls extends ConsumerWidget {
  final VoidCallback onSimulateShare;

  const FeedTopControls({
    super.key,
    required this.onSimulateShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(feedFilterProvider);
    final notifier = ref.read(feedFilterProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.oled.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sequence / Shuffle Toggle Button
          InkWell(
            onTap: () => notifier.toggleOrderMode(),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: filter.orderMode == PlaybackOrderMode.sequence
                    ? AppTheme.accentPink.withValues(alpha: 0.18)
                    : AppTheme.accentPurple.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: filter.orderMode == PlaybackOrderMode.sequence
                      ? AppTheme.accentPink.withValues(alpha: 0.5)
                      : AppTheme.accentPurple.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter.orderMode == PlaybackOrderMode.sequence
                        ? PhosphorIconsBold.arrowsClockwise
                        : PhosphorIconsBold.shuffle,
                    size: 14,
                    color: filter.orderMode == PlaybackOrderMode.sequence
                        ? AppTheme.accentPink
                        : AppTheme.accentPurple,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    filter.orderMode == PlaybackOrderMode.sequence ? 'Sequence' : 'Shuffle',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Hide Watched Toggle Chip
          InkWell(
            onTap: () => notifier.toggleHideWatched(),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: filter.hideWatched
                    ? Colors.white.withValues(alpha: 0.14)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: filter.hideWatched ? Colors.white38 : Colors.white12,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter.hideWatched
                        ? PhosphorIconsFill.eyeSlash
                        : PhosphorIconsRegular.eye,
                    size: 13,
                    color: filter.hideWatched ? AppTheme.accentAmber : Colors.white54,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Hide Watched',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: filter.hideWatched ? FontWeight.w700 : FontWeight.w500,
                      color: filter.hideWatched ? Colors.white : Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Quick Share Simulation Button
          InkWell(
            onTap: onSimulateShare,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: AppTheme.accentPillGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(PhosphorIconsBold.plus, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
