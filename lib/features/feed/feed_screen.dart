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
    ShareCollectionSheet.showWithClipboardOrInput(context);
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
                  final isSlideshow = item.mediaType == MediaType.carousel ||
                      item.mediaType == MediaType.photo ||
                      item.canonicalUrl.contains('/p/') ||
                      (item.localVideoRelPath == null &&
                          item.localCarouselRelPathsJson.isNotEmpty &&
                          item.localCarouselRelPathsJson != '[]');

                  return isSlideshow
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
    if (filter.hideWatched) {
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
                'All items in your vault have reached 100% watched. Toggle "Hide Watched" off to loop again, or save new Reels!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFFA1A1AA),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(feedFilterProvider.notifier).setHideWatched(false);
                },
                icon: const Icon(PhosphorIconsRegular.eye, size: 16),
                label: const Text('Show Watched Reels'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty Vault Banner
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top ambient icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentPink.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                  radius: 0.9,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accentPink.withValues(alpha: 0.4), width: 1.5),
              ),
              child: const Icon(
                PhosphorIconsFill.filmReel,
                size: 48,
                color: AppTheme.accentPink,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Your ReelVault is Empty',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save Instagram Reels & Carousels for distraction-free offline looping.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFFA1A1AA),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Instructional Banner Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.charcoal,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(PhosphorIconsFill.info, color: AppTheme.accentPink, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'How to Save from Instagram',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStepRow('1', 'Tap the Share (airplane) icon on any Reel in Instagram.'),
                  const SizedBox(height: 8),
                  _buildStepRow('2', 'Tap "Copy link".'),
                  const SizedBox(height: 8),
                  _buildStepRow('3', 'Open ReelVault and tap "Paste Reel Link" below.'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            ElevatedButton.icon(
              onPressed: () => ShareCollectionSheet.showWithClipboardOrInput(context),
              icon: const Icon(PhosphorIconsBold.clipboardText, size: 18),
              label: const Text('Paste Instagram Link', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPink,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ShareCollectionSheet.show(context, 'https://www.instagram.com/reel/C8kPqR9vW4m/');
              },
              icon: const Icon(PhosphorIconsRegular.sparkle, size: 16),
              label: const Text('Test with Demo Reel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(String stepNumber, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.elevated,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            stepNumber,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.accentPink,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFFD4D4D8),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
