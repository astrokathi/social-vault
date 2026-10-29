import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../features/collections/collections_screen.dart';
import '../../features/feed/feed_screen.dart';
import '../../features/feed/providers/feed_queue_provider.dart';
import '../../features/feed/widgets/carousel_media_item.dart';
import '../../features/feed/widgets/feed_top_controls.dart';
import '../../features/feed/widgets/reel_video_item.dart';
import '../../features/profile/profile_settings_screen.dart';
import '../../features/share_sheet/share_collection_sheet.dart';
import '../../data/database/app_database.dart';
import '../theme/app_theme.dart';
import '../utils/url_sanitizer.dart';

class AdaptiveScaffold extends ConsumerStatefulWidget {
  const AdaptiveScaffold({super.key});

  @override
  ConsumerState<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends ConsumerState<AdaptiveScaffold> {
  int _currentTabIndex = 0;
  int _selectedQueueIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 700;

        if (isTablet) {
          return _buildTabletLayout(context, constraints);
        } else {
          return _buildMobileLayout(context);
        }
      },
    );
  }

  // Mobile Layout: BottomNavigationBar
  Widget _buildMobileLayout(BuildContext context) {
    final screens = [
      const FeedScreen(),
      const CollectionsScreen(),
      const ProfileSettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.oled,
      body: IndexedStack(
        index: _currentTabIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.oled,
          border: Border(top: BorderSide(color: AppTheme.borderDark, width: 0.8)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (idx) => setState(() => _currentTabIndex = idx),
          backgroundColor: AppTheme.oled,
          selectedItemColor: AppTheme.accentPink,
          unselectedItemColor: const Color(0xFF71717A),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(PhosphorIconsRegular.filmReel),
              activeIcon: Icon(PhosphorIconsFill.filmReel),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIconsRegular.bookmarksSimple),
              activeIcon: Icon(PhosphorIconsFill.bookmarksSimple),
              label: 'Collections',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIconsRegular.userCircleGear),
              activeIcon: Icon(PhosphorIconsFill.userCircleGear),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  // Tablet Layout: NavigationRail + 2-Pane Split View for Feed
  Widget _buildTabletLayout(BuildContext context, BoxConstraints constraints) {
    return Scaffold(
      backgroundColor: AppTheme.oled,
      body: Row(
        children: [
          // Left NavigationRail
          NavigationRail(
            selectedIndex: _currentTabIndex,
            onDestinationSelected: (idx) => setState(() => _currentTabIndex = idx),
            backgroundColor: AppTheme.charcoal,
            minWidth: 80,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.instagramGradient,
                ),
                child: const Icon(PhosphorIconsBold.filmReel, color: Colors.white, size: 22),
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        gradient: AppTheme.accentPillGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(PhosphorIconsBold.plus, color: Colors.white, size: 18),
                    ),
                    tooltip: 'Intake Reel Link',
                    onPressed: () {
                      ShareCollectionSheet.show(
                        context,
                        'https://www.instagram.com/reel/C9xLmP2oQ1z/?igsh=tablet123',
                      );
                    },
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(PhosphorIconsRegular.filmReel),
                selectedIcon: Icon(PhosphorIconsFill.filmReel),
                label: Text('Feed'),
              ),
              NavigationRailDestination(
                icon: Icon(PhosphorIconsRegular.bookmarksSimple),
                selectedIcon: Icon(PhosphorIconsFill.bookmarksSimple),
                label: Text('Library'),
              ),
              NavigationRailDestination(
                icon: Icon(PhosphorIconsRegular.userCircleGear),
                selectedIcon: Icon(PhosphorIconsFill.userCircleGear),
                label: Text('Telemetry'),
              ),
            ],
          ),

          const VerticalDivider(width: 1, color: AppTheme.borderDark),

          // Main Center Stage
          Expanded(
            child: _currentTabIndex == 0
                ? _buildTabletFeedSplitView(context)
                : (_currentTabIndex == 1
                    ? const CollectionsScreen()
                    : const ProfileSettingsScreen()),
          ),
        ],
      ),
    );
  }

  // Tablet 2-Pane Split View (Player + Active Queue Inspector)
  Widget _buildTabletFeedSplitView(BuildContext context) {
    final filter = ref.watch(feedFilterProvider);
    final feedAsync = ref.watch(activeFeedListProvider(filter));

    return feedAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const FeedScreen();
        }

        final safeIndex = _selectedQueueIndex.clamp(0, items.length - 1);
        final activeItem = items[safeIndex];

        return Row(
          children: [
            // Left Pane: Full-height Video Player
            Expanded(
              flex: 7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  activeItem.mediaType == MediaType.carousel
                      ? CarouselMediaItem(key: ValueKey(activeItem.id), item: activeItem)
                      : ReelVideoItem(key: ValueKey(activeItem.id), item: activeItem),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: FeedTopControls(
                          onSimulateShare: () {
                            ShareCollectionSheet.show(
                              context,
                              'https://www.instagram.com/reel/C8kPqR9vW4m/?igsh=demo',
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const VerticalDivider(width: 1, color: AppTheme.borderDark),

            // Right Pane: Active Queue Inspector
            Expanded(
              flex: 5,
              child: Container(
                color: AppTheme.charcoal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Queue Header
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          const Icon(PhosphorIconsBold.listNumbers, color: AppTheme.accentPink, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Active Feed Queue',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.elevated,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppTheme.borderDark),
                            ),
                            child: Text(
                              '${items.length} Reels',
                              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.accentCyan),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: AppTheme.borderDark, height: 1),

                    // Queue List
                    Expanded(
                      child: ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(color: AppTheme.borderDark, height: 1),
                        itemBuilder: (context, idx) {
                          final it = items[idx];
                          final isSelected = idx == safeIndex;

                          return InkWell(
                            onTap: () {
                              setState(() => _selectedQueueIndex = idx);
                            },
                            child: Container(
                              color: isSelected ? AppTheme.accentPink.withValues(alpha: 0.12) : Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Row(
                                children: [
                                  // Index or Playing indicator
                                  SizedBox(
                                    width: 24,
                                    child: isSelected
                                        ? const Icon(PhosphorIconsFill.speakerHigh, color: AppTheme.accentPink, size: 16)
                                        : Text(
                                            '${idx + 1}',
                                            style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 12),
                                          ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Thumbnail
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      it.localThumbnailRelPath,
                                      width: 48,
                                      height: 64,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          it.authorHandle,
                                          style: GoogleFonts.inter(
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          it.caption,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFA1A1AA)),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Text(
                                              '${(it.watchProgress * 100).round()}% watched',
                                              style: GoogleFonts.jetBrainsMono(
                                                fontSize: 10,
                                                color: it.watchProgress >= 0.98 ? Colors.greenAccent : AppTheme.accentAmber,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              UrlSanitizer.formatBytes(it.fileSizeBytes),
                                              style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.white38),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentPink)),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.redAccent))),
    );
  }
}
