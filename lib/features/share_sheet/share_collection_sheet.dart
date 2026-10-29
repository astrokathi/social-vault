import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/url_sanitizer.dart';
import '../../core/widgets/vault_image.dart';
import '../../data/database/app_database.dart';
import '../../data/services/local_asset_manager.dart';
import '../../data/services/og_extractor_service.dart';

class ShareCollectionSheet extends ConsumerStatefulWidget {
  final String rawSharedUrl;

  const ShareCollectionSheet({
    super.key,
    required this.rawSharedUrl,
  });

  static Future<void> show(BuildContext context, String rawUrl) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ShareCollectionSheet(rawSharedUrl: rawUrl),
    );
  }

  /// Checks the system clipboard for an Instagram URL and opens the sheet immediately.
  /// If no valid Instagram URL is on the clipboard, displays the manual input dialog.
  static Future<void> showWithClipboardOrInput(BuildContext context) async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      final parsed = UrlSanitizer.parseInstagramUrl(text);
      if (parsed != null && context.mounted) {
        return show(context, parsed.canonicalUrl);
      }
    } catch (_) {}

    if (context.mounted) {
      return showManualInputDialog(context);
    }
  }

  /// Shows a modal dialog allowing the user to paste or enter any Instagram reel URL
  static Future<void> showManualInputDialog(BuildContext context) async {
    final controller = TextEditingController();
    String? errorText;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppTheme.charcoal,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: AppTheme.borderDark, width: 1.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(PhosphorIconsFill.instagramLogo, color: AppTheme.accentPink, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Paste Instagram Reel Link',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Paste any Instagram Reel or Carousel URL to extract and save it to your vault.',
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFFA1A1AA)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'https://www.instagram.com/reel/...',
                    hintStyle: GoogleFonts.inter(color: Colors.white38),
                    errorText: errorText,
                    suffixIcon: IconButton(
                      icon: const Icon(PhosphorIconsBold.clipboardText, color: AppTheme.accentPink),
                      onPressed: () async {
                        final data = await Clipboard.getData(Clipboard.kTextPlain);
                        if (data?.text != null) {
                          controller.text = data!.text!.trim();
                        }
                      },
                      tooltip: 'Paste from clipboard',
                    ),
                    filled: true,
                    fillColor: AppTheme.elevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.borderDark),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.accentPink, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentPink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final input = controller.text.trim();
                          final parsed = UrlSanitizer.parseInstagramUrl(input);
                          if (parsed == null && !input.contains('instagram.com/')) {
                            setModalState(() {
                              errorText = 'Please enter a valid Instagram reel link';
                            });
                            return;
                          }
                          Navigator.of(ctx).pop();
                          show(context, parsed?.canonicalUrl ?? input);
                        },
                        icon: const Icon(PhosphorIconsBold.downloadSimple, size: 16),
                        label: const Text('Import Reel', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  ConsumerState<ShareCollectionSheet> createState() => _ShareCollectionSheetState();
}

class _ShareCollectionSheetState extends ConsumerState<ShareCollectionSheet> {
  bool _isLoadingOg = true;
  bool _isSaving = false;
  ExtractedMediaMetadata? _metadata;
  String? _selectedCollectionId;
  String _customCollectionName = '';
  bool _showCustomInput = false;
  MediaType _selectedMediaType = MediaType.video;
  List<String> _carouselUrls = [];
  bool _showAddSlideInput = false;
  final TextEditingController _newSlideController = TextEditingController();
  final TextEditingController _customColController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _parseAndFetchOg();
  }

  @override
  void dispose() {
    _newSlideController.dispose();
    _customColController.dispose();
    _authorController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _parseAndFetchOg() async {
    final parsed = UrlSanitizer.parseInstagramUrl(widget.rawSharedUrl);
    final shortcode = parsed?.shortcode ?? 'rv_${DateTime.now().millisecondsSinceEpoch % 100000}';
    final canonical = parsed?.canonicalUrl ?? widget.rawSharedUrl;

    final ogService = ref.read(ogExtractorServiceProvider);
    final meta = await ogService.extractFromUrl(canonical, shortcode);

    if (mounted) {
      final isCarousel = parsed?.isCarouselPost == true ||
          canonical.contains('/p/') ||
          meta.mediaType == MediaType.carousel;

      _authorController.text = meta.authorHandle;
      _captionController.text = meta.caption;

      _carouselUrls = meta.carouselRemoteUrls.isNotEmpty
          ? List.from(meta.carouselRemoteUrls)
          : (meta.thumbnailRemoteUrl.isNotEmpty ? [meta.thumbnailRemoteUrl] : []);

      setState(() {
        _metadata = meta;
        _selectedMediaType = isCarousel ? MediaType.carousel : MediaType.video;
        _isLoadingOg = false;
      });
    }
  }

  Future<void> _saveMedia(List<CollectionEntity> existingCollections) async {
    if (_metadata == null) return;
    setState(() => _isSaving = true);

    try {
      final db = ref.read(databaseProvider);
      final assetManager = ref.read(localAssetManagerProvider);

      String targetCollectionId = _selectedCollectionId ?? '';

      // Create new collection if user entered a custom name
      if (_showCustomInput && _customCollectionName.trim().isNotEmpty) {
        final newId = 'col_${DateTime.now().millisecondsSinceEpoch}';
        await db.insertOrUpdateCollection(
          CollectionEntity(
            id: newId,
            name: _customCollectionName.trim(),
            createdAt: DateTime.now(),
          ),
        );
        targetCollectionId = newId;
      } else if (targetCollectionId.isEmpty && existingCollections.isNotEmpty) {
        targetCollectionId = existingCollections.first.id;
      } else if (targetCollectionId.isEmpty) {
        // Fallback default collection
        targetCollectionId = 'col_default';
        await db.insertOrUpdateCollection(
          CollectionEntity(
            id: targetCollectionId,
            name: 'Saved Reels',
            createdAt: DateTime.now(),
          ),
        );
      }

      final finalAuthor = _authorController.text.trim().isNotEmpty
          ? (_authorController.text.trim().startsWith('@')
              ? _authorController.text.trim()
              : '@${_authorController.text.trim()}')
          : _metadata!.authorHandle;
      final finalCaption = _captionController.text.trim().isNotEmpty
          ? _captionController.text.trim()
          : _metadata!.caption;

      // Effective metadata using user's chosen media type and slides
      final effectiveMeta = ExtractedMediaMetadata(
        shortcode: _metadata!.shortcode,
        canonicalUrl: _metadata!.canonicalUrl,
        mediaType: _selectedMediaType,
        authorHandle: finalAuthor,
        caption: finalCaption,
        thumbnailRemoteUrl: _metadata!.thumbnailRemoteUrl,
        videoRemoteUrl: _selectedMediaType == MediaType.video ? _metadata!.videoRemoteUrl : null,
        carouselRemoteUrls: _selectedMediaType == MediaType.carousel ? _carouselUrls : const [],
        estimatedSizeBytes: _metadata!.estimatedSizeBytes,
        durationMs: _selectedMediaType == MediaType.video ? _metadata!.durationMs : 0,
      );

      // Download binary assets to local documents sandbox
      final savedAssets = await assetManager.downloadAndSaveMedia(
        metadata: effectiveMeta,
        collectionId: targetCollectionId,
      );

      final isFav = targetCollectionId == AppDatabase.favoritesCollectionId;

      // Write row to SQLite
      final mediaEntity = VaultMediaEntity(
        id: const Uuid().v4(),
        shortcode: effectiveMeta.shortcode,
        canonicalUrl: effectiveMeta.canonicalUrl,
        collectionId: targetCollectionId,
        mediaType: _selectedMediaType,
        authorHandle: finalAuthor,
        caption: finalCaption,
        localThumbnailRelPath: savedAssets.thumbnailRelPath,
        localVideoRelPath: _selectedMediaType == MediaType.video ? savedAssets.videoRelPath : null,
        localCarouselRelPathsJson: savedAssets.carouselRelPathsJson,
        watchProgress: 0.0,
        durationMs: _selectedMediaType == MediaType.video ? effectiveMeta.durationMs : 0,
        lastPositionMs: 0,
        fileSizeBytes: savedAssets.totalBytes,
        isFavorite: isFav,
        createdAt: DateTime.now(),
        lastWatchedAt: null,
      );

      await db.insertOrUpdateMedia(mediaEntity);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.elevated,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppTheme.accentPink, width: 1),
            ),
            content: Row(
              children: [
                const Icon(PhosphorIconsRegular.checkCircle, color: AppTheme.accentPink, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saved to ReelVault',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      Text(
                        'Stored locally in target collection.',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade900,
            content: Text('Failed to save media: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final collectionsStream = db.watchAllCollections();

    return StreamBuilder<List<CollectionEntity>>(
      stream: collectionsStream,
      builder: (context, snapshot) {
        final collections = snapshot.data ?? [];
        if (_selectedCollectionId == null && collections.isNotEmpty) {
          _selectedCollectionId = collections.first.id;
        }

        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 16,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.charcoal,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: AppTheme.borderDark, width: 1.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentPillGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(PhosphorIconsBold.filmReel, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Save to ReelVault',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Select folder & cache local assets',
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFA1A1AA)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIconsRegular.x, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Preview Card
              if (_isLoadingOg)
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppTheme.elevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderDark),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppTheme.accentPink),
                  ),
                )
              else if (_metadata != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.elevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderDark),
                  ),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: VaultImage(
                          imagePath: _metadata!.thumbnailRemoteUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Details (Editable Creator Credit & Full Caption)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Icon(PhosphorIconsFill.at, size: 14, color: AppTheme.accentPink),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: TextField(
                                    controller: _authorController,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      hintText: '@creator_handle',
                                      hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const Icon(PhosphorIconsFill.shieldCheck, size: 14, color: AppTheme.accentCyan),
                              ],
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _captionController,
                              maxLines: 2,
                              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFD4D4D8)),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintText: 'Original description / caption...',
                                hintStyle: TextStyle(color: Colors.white38, fontSize: 11),
                                border: InputBorder.none,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(PhosphorIconsRegular.hardDrive, size: 13, color: AppTheme.accentCyan),
                                const SizedBox(width: 4),
                                Text(
                                  UrlSanitizer.formatBytes(_metadata!.estimatedSizeBytes),
                                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.accentCyan),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '#${_metadata!.shortcode}',
                                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.white38),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Media Classification Selector: Reel Video vs Slideshow Carousel
              Text(
                'CONTENT TYPE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: const Color(0xFF71717A),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedMediaType = MediaType.video;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedMediaType == MediaType.video
                              ? AppTheme.accentPink.withValues(alpha: 0.25)
                              : AppTheme.elevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedMediaType == MediaType.video
                                ? AppTheme.accentPink
                                : AppTheme.borderDark,
                            width: _selectedMediaType == MediaType.video ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              PhosphorIconsFill.videoCamera,
                              size: 16,
                              color: _selectedMediaType == MediaType.video
                                  ? AppTheme.accentPink
                                  : Colors.white60,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Reel (Video)',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: _selectedMediaType == MediaType.video
                                    ? Colors.white
                                    : Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedMediaType = MediaType.carousel;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedMediaType == MediaType.carousel
                              ? AppTheme.accentCyan.withValues(alpha: 0.25)
                              : AppTheme.elevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedMediaType == MediaType.carousel
                                ? AppTheme.accentCyan
                                : AppTheme.borderDark,
                            width: _selectedMediaType == MediaType.carousel ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              PhosphorIconsFill.images,
                              size: 16,
                              color: _selectedMediaType == MediaType.carousel
                                  ? AppTheme.accentCyan
                                  : Colors.white60,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Slideshow (Carousel)',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: _selectedMediaType == MediaType.carousel
                                    ? Colors.white
                                    : Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Carousel Slides Manager (Only shown when Carousel is selected)
              if (_selectedMediaType == MediaType.carousel) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.elevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(PhosphorIconsFill.images, size: 14, color: AppTheme.accentCyan),
                              const SizedBox(width: 6),
                              Text(
                                '${_carouselUrls.length} Carousel Slide${_carouselUrls.length == 1 ? '' : 's'}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.accentCyan,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _showAddSlideInput = !_showAddSlideInput;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _showAddSlideInput ? PhosphorIconsBold.x : PhosphorIconsBold.plus,
                                    size: 12,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _showAddSlideInput ? 'Cancel' : 'Add Slide',
                                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_showAddSlideInput) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _newSlideController,
                                style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white),
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Paste slide image URL...',
                                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 11),
                                  filled: true,
                                  fillColor: AppTheme.charcoal,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final text = _newSlideController.text.trim();
                                if (text.isNotEmpty && text.startsWith('http')) {
                                  setState(() {
                                    _carouselUrls.add(text);
                                    _newSlideController.clear();
                                    _showAddSlideInput = false;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentCyan,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Add', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // Collection Header
              Text(
                'SAVE TO COLLECTION',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: const Color(0xFF71717A),
                ),
              ),
              const SizedBox(height: 10),

              // Chips Wrap
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...collections.map((col) {
                    final isSelected = !_showCustomInput && _selectedCollectionId == col.id;
                    final isFav = col.id == AppDatabase.favoritesCollectionId;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCollectionId = col.id;
                          _showCustomInput = false;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isFav ? AppTheme.accentAmber.withValues(alpha: 0.25) : AppTheme.accentPink.withValues(alpha: 0.2))
                              : AppTheme.elevated,
                          border: Border.all(
                            color: isSelected
                                ? (isFav ? AppTheme.accentAmber : AppTheme.accentPink)
                                : (isFav ? AppTheme.accentAmber.withValues(alpha: 0.4) : AppTheme.borderDark),
                            width: isSelected ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFav
                                  ? PhosphorIconsFill.star
                                  : (isSelected ? PhosphorIconsFill.folder : PhosphorIconsRegular.folder),
                              size: 15,
                              color: isFav
                                  ? AppTheme.accentAmber
                                  : (isSelected ? AppTheme.accentPink : const Color(0xFFA1A1AA)),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              col.name,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isFav
                                    ? (isSelected ? Colors.white : AppTheme.accentAmber)
                                    : (isSelected ? Colors.white : const Color(0xFFD4D4D8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // "+ New Collection" Chip
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showCustomInput = !_showCustomInput;
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _showCustomInput ? AppTheme.accentPurple.withValues(alpha: 0.2) : Colors.transparent,
                        border: Border.all(
                          color: _showCustomInput ? AppTheme.accentPurple : Colors.white24,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showCustomInput ? PhosphorIconsBold.x : PhosphorIconsBold.plus,
                            size: 14,
                            color: _showCustomInput ? AppTheme.accentPurple : Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '+ New Collection',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _showCustomInput ? Colors.white : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Inline New Collection input field
              if (_showCustomInput) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: _customColController,
                  autofocus: true,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'e.g. Travel & Cinematography',
                    hintStyle: GoogleFonts.inter(color: Colors.white38),
                    prefixIcon: const Icon(PhosphorIconsRegular.folderPlus, color: AppTheme.accentPurple, size: 20),
                    filled: true,
                    fillColor: AppTheme.elevated,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.accentPurple, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.accentPurple, width: 1.8),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => _customCollectionName = val);
                  },
                ),
              ],

              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: (_isSaving || _isLoadingOg) ? null : () => _saveMedia(collections),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPink,
                  disabledBackgroundColor: AppTheme.accentPink.withValues(alpha: 0.3),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(PhosphorIconsBold.downloadSimple, color: Colors.white, size: 19),
                          const SizedBox(width: 8),
                          Text(
                            'Save to Local Vault',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
