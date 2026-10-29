import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/url_sanitizer.dart';
import '../../../core/widgets/vault_image.dart';
import '../../../data/database/app_database.dart';
import '../../../data/services/local_asset_manager.dart';

class ReelVideoItem extends ConsumerStatefulWidget {
  final VaultMediaEntity item;

  const ReelVideoItem({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<ReelVideoItem> createState() => _ReelVideoItemState();
}

class _ReelVideoItemState extends ConsumerState<ReelVideoItem> {
  VideoPlayerController? _controller;
  WebViewController? _webViewController;
  bool _isInitialized = false;
  bool _isPlaying = true;
  bool _isMuted = false;
  bool _isCaptionExpanded = false;
  bool _showWebPlayer = false;
  double _currentProgress = 0.0;
  DateTime _lastDbWrite = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _simulatedPlaybackTimer;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.item.watchProgress;
    _initVideo();
  }

  @override
  void didUpdateWidget(ReelVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _controller?.dispose();
      _simulatedPlaybackTimer?.cancel();
      _controller = null;
      _webViewController = null;
      _isInitialized = false;
      _showWebPlayer = false;
      _currentProgress = widget.item.watchProgress;
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    final assetManager = ref.read(localAssetManagerProvider);

    // If local video file exists
    if (widget.item.localVideoRelPath != null && widget.item.localVideoRelPath!.isNotEmpty) {
      final fullPath = await assetManager.resolveFullPath(widget.item.localVideoRelPath!);
      final file = File(fullPath);
      if (await file.exists()) {
        _controller = VideoPlayerController.file(file);
      }
    }

    if (_controller != null) {
      try {
        await _controller!.initialize();
        _controller!.setLooping(true);
        // Explicitly set volume to 100% unless muted
        await _controller!.setVolume(_isMuted ? 0.0 : 1.0);
        _controller!.addListener(_onVideoControllerTick);
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller!.play();
        }
      } catch (e) {
        debugPrint('Failed to initialize local video player: $e');
        _initWebPlayer();
        _startSimulatedProgress();
      }
    } else {
      // Local .mp4 file not present: prepare embedded player fallback for real video & audio
      _initWebPlayer();
      _startSimulatedProgress();
    }
  }

  void _initWebPlayer() {
    try {
      final embedUrl = 'https://www.instagram.com/reel/${widget.item.shortcode}/embed/captioned/';
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..loadRequest(Uri.parse(embedUrl));
    } catch (_) {}
  }

  void _startSimulatedProgress() {
    _simulatedPlaybackTimer?.cancel();
    final durationSec = widget.item.durationMs > 0 ? (widget.item.durationMs / 1000).round() : 30;

    _simulatedPlaybackTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (!mounted || !_isPlaying) return;

      setState(() {
        final step = 0.25 / durationSec;
        var next = _currentProgress + step;
        if (next >= 1.0) {
          next = 1.0;
          timer.cancel();
          _commitProgressToDb(1.0, widget.item.durationMs);
        } else {
          _currentProgress = next;
          final now = DateTime.now();
          if (now.difference(_lastDbWrite).inMilliseconds >= 1000) {
            _commitProgressToDb(next, (next * widget.item.durationMs).round());
          }
        }
      });
    });
  }

  void _onVideoControllerTick() {
    if (_controller == null) return;
    final value = _controller!.value;
    if (!value.isInitialized || value.duration.inMilliseconds <= 0) return;

    final ratio = value.position.inMilliseconds / value.duration.inMilliseconds;
    final normalized = ratio >= 0.95 ? 1.0 : ratio.clamp(0.0, 1.0);

    setState(() => _currentProgress = normalized);

    final now = DateTime.now();
    if (normalized >= 1.0 || now.difference(_lastDbWrite).inMilliseconds >= 1000) {
      _commitProgressToDb(normalized, value.position.inMilliseconds);
    }
  }

  void _commitProgressToDb(double progress, int positionMs) {
    _lastDbWrite = DateTime.now();
    ref.read(databaseProvider).updateWatchProgress(
      mediaId: widget.item.id,
      progress: progress,
      positionMs: positionMs,
    );
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_controller != null && _isInitialized) {
        if (_isPlaying) {
          _controller!.play();
        } else {
          _controller!.pause();
        }
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller?.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  void dispose() {
    _simulatedPlaybackTimer?.cancel();
    _controller?.removeListener(_onVideoControllerTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (_showWebPlayer && _webViewController != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.black,
            child: SafeArea(
              child: WebViewWidget(controller: _webViewController!),
            ),
          ),
          Positioned(
            top: 50,
            right: 16,
            child: InkWell(
              onTap: () => setState(() => _showWebPlayer = false),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(PhosphorIconsBold.arrowLeft, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Back to Vault',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Video or Fallback Thumbnail Backdrop (using VaultImage for proper local file resolution)
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            color: Colors.black,
            child: Center(
              child: (_isInitialized && _controller != null)
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : VaultImage(
                      imagePath: widget.item.localThumbnailRelPath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
            ),
          ),
        ),

        // Pause Overlay Indicator
        if (!_isPlaying)
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(PhosphorIconsFill.play, color: Colors.white, size: 36),
            ),
          ),

        // Floating Notice when local .mp4 is not present (prompts web audio streaming)
        if (_controller == null && _webViewController != null)
          Positioned(
            top: 70,
            left: 20,
            right: 20,
            child: Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _showWebPlayer = true;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(PhosphorIconsFill.speakerHigh, size: 14, color: AppTheme.accentCyan),
                      const SizedBox(width: 8),
                      Text(
                        'Tap for Live Audio & Video Player',
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
            ),
          ),

        // 2. Subtle Dark Gradients for contrast
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
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

        // 3. Right Action Bar
        Positioned(
          right: 14,
          bottom: 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Favorite Action (Adds/removes from default Favorites collection)
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

              // 2. Landscape / Fullscreen Rotation Toggle
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

              // 3. Audio / Web Player Toggle
              if (_controller != null) ...[
                _buildActionButton(
                  icon: _isMuted ? PhosphorIconsRegular.speakerSlash : PhosphorIconsRegular.speakerHigh,
                  color: _isMuted ? Colors.white54 : AppTheme.accentCyan,
                  label: _isMuted ? 'Muted' : 'Audio',
                  onTap: _toggleMute,
                ),
                const SizedBox(height: 18),
              ] else if (_webViewController != null) ...[
                _buildActionButton(
                  icon: PhosphorIconsFill.speakerHigh,
                  color: AppTheme.accentCyan,
                  label: 'Web Audio',
                  onTap: () {
                    setState(() {
                      _showWebPlayer = true;
                    });
                  },
                ),
                const SizedBox(height: 18),
              ],

              // 4. Storage Indicator
              _buildActionButton(
                icon: PhosphorIconsRegular.hardDrive,
                color: AppTheme.accentCyan,
                label: UrlSanitizer.formatBytes(widget.item.fileSizeBytes),
                onTap: () {},
              ),
            ],
          ),
        ),

        // 4. Bottom Info Overlay (Author Attribution, Anti-Plagiarism, Expandable Caption)
        Positioned(
          left: 16,
          right: 80,
          bottom: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Author Handle & Creator Badge
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
                            : 'R',
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
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '#${widget.item.shortcode}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: Colors.white70,
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

              // Duration & Status Tag
              Row(
                children: [
                  const Icon(PhosphorIconsRegular.clock, size: 13, color: AppTheme.accentCyan),
                  const SizedBox(width: 4),
                  Text(
                    UrlSanitizer.formatDuration(widget.item.durationMs),
                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.accentCyan),
                  ),
                  const SizedBox(width: 10),
                  if (_currentProgress >= 0.98)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        border: Border.all(color: Colors.green, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '100% WATCHED',
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

        // 5. Bottom Real-time Watch Progress Bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 3.5,
                color: Colors.white.withValues(alpha: 0.12),
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: MediaQuery.of(context).size.width * _currentProgress,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.accentPillGradient,
                  ),
                ),
              ),
            ],
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
