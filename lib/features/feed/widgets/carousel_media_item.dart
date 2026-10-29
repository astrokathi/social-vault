import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/url_sanitizer.dart';
import '../../../core/widgets/vault_image.dart';
import '../../../data/database/app_database.dart';

class CarouselMediaItem extends ConsumerStatefulWidget {
  final VaultMediaEntity item;

  const CarouselMediaItem({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<CarouselMediaItem> createState() => _CarouselMediaItemState();
}

class _CarouselMediaItemState extends ConsumerState<CarouselMediaItem> {
  late final PageController _pageController;
  int _currentSlide = 0;
  List<String> _slides = [];
  bool _isCaptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _parseSlides();
  }

  void _parseSlides() {
    try {
      final decoded = jsonDecode(widget.item.localCarouselRelPathsJson);
      if (decoded is List) {
        _slides = decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {
      _slides = [];
    }

    if (_slides.isEmpty && widget.item.localThumbnailRelPath.isNotEmpty) {
      _slides = [widget.item.localThumbnailRelPath];
    }
  }

  @override
  void didUpdateWidget(CarouselMediaItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _parseSlides();
      _currentSlide = 0;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSlideChanged(int index) {
    setState(() => _currentSlide = index);
    final total = _slides.length;
    if (total <= 0) return;

    final progress = (index + 1) / total;
    final normalized = progress >= 0.99 ? 1.0 : progress;

    ref.read(databaseProvider).updateWatchProgress(
      mediaId: widget.item.id,
      progress: normalized,
      positionMs: index + 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSlides = _slides.length;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Horizontal PageView for Slides (with VaultImage for local files)
        PageView.builder(
          controller: _pageController,
          itemCount: totalSlides,
          onPageChanged: _onSlideChanged,
          itemBuilder: (context, index) {
            final slideUrl = _slides[index];
            return Container(
              color: Colors.black,
              child: Center(
                child: VaultImage(
                  imagePath: slideUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            );
          },
        ),

        // 2. Dark Gradient Overlay
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.25, 0.6, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),

        // 3. Top Slide Dots / Counter Pill
        Positioned(
          top: 70,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(PhosphorIconsFill.images, size: 13, color: AppTheme.accentCyan),
                const SizedBox(width: 5),
                Text(
                  '${_currentSlide + 1} / $totalSlides',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 4. Right Action Rail
        Positioned(
          right: 14,
          bottom: 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Favorite Action (Toggles Favorites system collection)
              _buildActionButton(
                icon: widget.item.isFavorite ? PhosphorIconsFill.star : PhosphorIconsRegular.star,
                color: widget.item.isFavorite ? AppTheme.accentAmber : Colors.white,
                label: widget.item.isFavorite ? 'Favorited' : 'Favorite',
                onTap: () async {
                  final db = ref.read(databaseProvider);
                  final isFav = await db.toggleFavorite(widget.item.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppTheme.charcoal,
                        duration: const Duration(seconds: 2),
                        content: Row(
                          children: [
                            Icon(
                              isFav ? PhosphorIconsFill.star : PhosphorIconsRegular.star,
                              color: isFav ? AppTheme.accentAmber : Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isFav ? 'Added to Favorites' : 'Removed from Favorites',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 18),

              // Landscape Rotation Toggle
              _buildActionButton(
                icon: isLandscape
                    ? PhosphorIconsBold.deviceMobile
                    : PhosphorIconsBold.cornersOut,
                color: isLandscape ? AppTheme.accentCyan : Colors.white,
                label: isLandscape ? 'Portrait' : 'Rotate',
                onTap: () {
                  if (isLandscape) {
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                    ]);
                  } else {
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.landscapeLeft,
                      DeviceOrientation.landscapeRight,
                    ]);
                  }
                },
              ),
              const SizedBox(height: 18),

              // Storage Indicator
              _buildActionButton(
                icon: PhosphorIconsRegular.hardDrive,
                color: AppTheme.accentCyan,
                label: UrlSanitizer.formatBytes(widget.item.fileSizeBytes),
                onTap: () {},
              ),
            ],
          ),
        ),

        // 5. Bottom Info Overlay (Attribution, Anti-Plagiarism, Expandable Caption)
        Positioned(
          left: 16,
          right: 80,
          bottom: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.instagramGradient,
                    ),
                    padding: const EdgeInsets.all(1.5),
                    child: CircleAvatar(
                      backgroundColor: AppTheme.charcoal,
                      child: Text(
                        widget.item.authorHandle.isNotEmpty
                            ? widget.item.authorHandle.substring(1, 2).toUpperCase()
                            : 'C',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.item.authorHandle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(PhosphorIconsFill.checkCircle, size: 14, color: Color(0xFF3897F0)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPink.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'CAROUSEL',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentPink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Expandable Caption & Attribution
              GestureDetector(
                onTap: () => setState(() => _isCaptionExpanded = !_isCaptionExpanded),
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _isCaptionExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.92),
                            height: 1.35,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'more',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentPink,
                        ),
                      ),
                    ],
                  ),
                  secondChild: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.caption,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(PhosphorIconsFill.shieldCheck, size: 14, color: AppTheme.accentCyan),
                            const SizedBox(width: 4),
                            Text(
                              'Original Creator: ${widget.item.authorHandle}',
                              style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppTheme.accentCyan, fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Text(
                              'Tap to collapse ▲',
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Swipe to advance slide progress',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
                  ),
                  const SizedBox(width: 10),
                  if (widget.item.watchProgress >= 0.98)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        border: Border.all(color: Colors.green, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '100% COMPLETE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // 6. Bottom Progress Bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 3.5,
            color: Colors.white.withValues(alpha: 0.12),
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: MediaQuery.of(context).size.width * ((_currentSlide + 1) / totalSlides),
              decoration: const BoxDecoration(
                gradient: AppTheme.accentPillGradient,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
