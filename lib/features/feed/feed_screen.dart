import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../data/database/app_database.dart';
import '../share_sheet/share_collection_sheet.dart';
import 'providers/feed_queue_provider.dart';
import 'widgets/carousel_media_item.dart';
import 'widgets/feed_top_controls.dart';
import 'widgets/reel_video_item.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  void _showSimulateShareSheet(BuildContext context) {
    ShareCollectionSheet.show(
      context,
      'https://www.instagram.com/reel/C9xLmP2oQ1z/?igsh=MWZ4Nm12',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(feedFilterProvider);
    final feedAsync = ref.watch(activeFeedListProvider(filter));

    return Scaffold(
      backgroundColor: AppTheme.oled,
      body: Stack(
        children: [
          // 1. Endless Feed View
          feedAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return _buildEmptyState(context, ref, filter);
              }

              return PageView.builder(
                scrollDirection: Axis.vertical,
                // Infinite vertical endless loop! itemCount is null
                itemBuilder: (context, rawIndex) {
                  final item = items[rawIndex % items.length];
                  return item.mediaType == MediaType.carousel
                      ? CarouselMediaItem(key: ValueKey(item.id), item: item)
                      : ReelVideoItem(key: ValueKey(item.id), item: item);
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.accentPink),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Feed error: $err',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.redAccent),
                ),
              ),
            ),
          ),

          // 2. Floating Top Controls (Sequence/Shuffle + Hide Watched)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: FeedTopControls(
                  onSimulateShare: () => _showSimulateShareSheet(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, FeedFilterState filter) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.elevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: const Icon(
                PhosphorIconsFill.checkCircle,
                size: 48,
                color: AppTheme.accentPink,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'All Caught Up!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filter.hideWatched
                  ? 'All items in your vault have reached 100% watched. Toggle "Hide Watched" off to loop again, or share new Reels!'
                  : 'Your ReelVault is empty. Share an Instagram Reel to start your endless loop.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFFA1A1AA),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (filter.hideWatched)
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(feedFilterProvider.notifier).setHideWatched(false);
                    },
                    icon: const Icon(PhosphorIconsRegular.eye, size: 16),
                    label: const Text('Show Watched'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showSimulateShareSheet(context),
                  icon: const Icon(PhosphorIconsBold.plus, size: 16),
                  label: const Text('Add Reel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
