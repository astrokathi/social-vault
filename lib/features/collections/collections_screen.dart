import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../data/database/app_database.dart';
import '../../data/services/local_asset_manager.dart';
import '../feed/widgets/carousel_media_item.dart';
import '../feed/widgets/reel_video_item.dart';
import '../share_sheet/share_collection_sheet.dart';
import 'widgets/collection_mosaic_card.dart';
import 'widgets/media_grid_tile.dart';

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  String _activeSubTab = 'folders'; // 'folders' | 'grid'
  String? _selectedCollectionId;

  void _showCreateCollectionDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.charcoal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'New Collection',
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'e.g. Design Inspirations',
            hintStyle: GoogleFonts.inter(color: Colors.white38),
            filled: true,
            fillColor: AppTheme.elevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.borderDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.accentPink),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPink),
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final db = ref.read(databaseProvider);
                await db.insertOrUpdateCollection(
                  CollectionEntity(
                    id: 'col_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    createdAt: DateTime.now(),
                  ),
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openMediaDetailModal(VaultMediaEntity item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(PhosphorIconsRegular.x, color: Colors.white),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            title: Text(
              item.authorHandle,
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          body: item.mediaType == MediaType.carousel
              ? CarouselMediaItem(item: item)
              : ReelVideoItem(item: item),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final collectionsStream = db.watchAllCollections();
    final allMediaStream = db.watchMediaForCollection(_selectedCollectionId);

    final width = MediaQuery.of(context).size.width;
    final gridColumns = width >= 700 ? 5 : 3;
    final folderColumns = width >= 700 ? 3 : 2;

    return Scaffold(
      backgroundColor: AppTheme.oled,
      appBar: AppBar(
        title: Text(
          _selectedCollectionId != null ? 'Collection' : 'Library & Vault',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        leading: _selectedCollectionId != null
            ? IconButton(
                icon: const Icon(PhosphorIconsRegular.arrowLeft, color: Colors.white),
                onPressed: () => setState(() => _selectedCollectionId = null),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsBold.folderPlus, color: AppTheme.accentPink),
            tooltip: 'New Collection',
            onPressed: _showCreateCollectionDialog,
          ),
          IconButton(
            icon: const Icon(PhosphorIconsBold.plusCircle, color: Colors.white),
            tooltip: 'Add Reel',
            onPressed: () {
              ShareCollectionSheet.show(
                context,
                'https://www.instagram.com/reel/C8kPqR9vW4m/',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<CollectionEntity>>(
        stream: collectionsStream,
        builder: (context, colSnapshot) {
          final collections = colSnapshot.data ?? [];

          return StreamBuilder<List<VaultMediaEntity>>(
            stream: allMediaStream,
            builder: (context, mediaSnapshot) {
              final mediaList = mediaSnapshot.data ?? [];

              return Column(
                children: [
                  // SubTab Selector (Folders vs Grid) when not drilling down
                  if (_selectedCollectionId == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.charcoal,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderDark),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildSubTabButton(
                                label: 'Folders (${collections.length})',
                                icon: PhosphorIconsFill.folder,
                                isActive: _activeSubTab == 'folders',
                                onTap: () => setState(() => _activeSubTab = 'folders'),
                              ),
                            ),
                            Expanded(
                              child: _buildSubTabButton(
                                label: 'All Items (${mediaList.length})',
                                icon: PhosphorIconsFill.squaresFour,
                                isActive: _activeSubTab == 'grid',
                                onTap: () => setState(() => _activeSubTab = 'grid'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Active Filter Banner if a Collection is selected
                  if (_selectedCollectionId != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.elevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.accentPink.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(PhosphorIconsFill.folderOpen, color: AppTheme.accentPink, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                collections.firstWhere(
                                  (c) => c.id == _selectedCollectionId,
                                  orElse: () => CollectionEntity(id: '', name: 'Collection', createdAt: DateTime.now()),
                                ).name,
                                style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                            Text(
                              '${mediaList.length} items',
                              style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFFA1A1AA)),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Main Content View
                  Expanded(
                    child: (_activeSubTab == 'folders' && _selectedCollectionId == null)
                        ? _buildFoldersGrid(collections, mediaList, folderColumns)
                        : _buildMediaGrid(mediaList, gridColumns),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSubTabButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.elevated : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? AppTheme.accentPink : const Color(0xFF71717A),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? Colors.white : const Color(0xFFA1A1AA),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoldersGrid(
    List<CollectionEntity> collections,
    List<VaultMediaEntity> allMedia,
    int columns,
  ) {
    if (collections.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(PhosphorIconsRegular.folderDashed, size: 56, color: Colors.white24),
            const SizedBox(height: 12),
            Text('No Collections Yet', style: GoogleFonts.plusJakartaSans(fontSize: 18, color: Colors.white70)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPink),
              onPressed: _showCreateCollectionDialog,
              child: const Text('Create First Collection', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final col = collections[index];
        final colItems = allMedia.where((m) => m.collectionId == col.id).toList();

        return CollectionMosaicCard(
          collection: col,
          items: colItems,
          onTap: () {
            setState(() {
              _selectedCollectionId = col.id;
            });
          },
          onDelete: () async {
            final db = ref.read(databaseProvider);
            await db.deleteCollection(col.id);
          },
        );
      },
    );
  }

  Widget _buildMediaGrid(List<VaultMediaEntity> items, int columns) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(PhosphorIconsRegular.filmReel, size: 56, color: Colors.white24),
            const SizedBox(height: 12),
            Text('No Reels In This View', style: GoogleFonts.plusJakartaSans(fontSize: 18, color: Colors.white70)),
            const SizedBox(height: 8),
            Text('Share an Instagram Reel or Carousel to populate.', style: GoogleFonts.inter(color: Colors.white38)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75, // Vertical reel aspect ratio
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MediaGridTile(
          item: item,
          onTap: () => _openMediaDetailModal(item),
          onDelete: () async {
            final db = ref.read(databaseProvider);
            final assetManager = ref.read(localAssetManagerProvider);
            await assetManager.deleteMediaFolder(item.shortcode);
            await db.deleteMedia(item.id);
          },
        );
      },
    );
  }
}
