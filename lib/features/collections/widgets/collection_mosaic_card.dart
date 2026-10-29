import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/url_sanitizer.dart';
import '../../../data/database/app_database.dart';

class CollectionMosaicCard extends StatelessWidget {
  final CollectionEntity collection;
  final List<VaultMediaEntity> items;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CollectionMosaicCard({
    super.key,
    required this.collection,
    required this.items,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    int totalBytes = 0;
    for (final it in items) {
      totalBytes += it.fileSizeBytes;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.elevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderDark),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2x2 Cover Mosaic
            AspectRatio(
              aspectRatio: 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: AppTheme.charcoal,
                  child: items.isEmpty
                      ? const Center(
                          child: Icon(
                            PhosphorIconsRegular.folderDashed,
                            size: 36,
                            color: Colors.white24,
                          ),
                        )
                      : GridView.count(
                          crossAxisCount: 2,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                          children: [
                            for (int i = 0; i < 4; i++)
                              if (i < items.length)
                                Image.network(
                                  items[i].localThumbnailRelPath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.black26,
                                    child: const Icon(PhosphorIconsRegular.image, size: 16, color: Colors.white24),
                                  ),
                                )
                              else
                                Container(color: AppTheme.oled),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Collection Name & Item Count
            Row(
              children: [
                Expanded(
                  child: Text(
                    collection.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(PhosphorIconsRegular.dotsThreeVertical, size: 16, color: Colors.white38),
                  color: AppTheme.charcoal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (val) {
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(PhosphorIconsRegular.trash, color: Colors.redAccent, size: 16),
                          const SizedBox(width: 8),
                          Text('Delete Collection', style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 2),

            // Metadata footer (item count + storage bytes)
            Row(
              children: [
                Text(
                  '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFFA1A1AA),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: Colors.white24, fontSize: 10)),
                const SizedBox(width: 8),
                Text(
                  UrlSanitizer.formatBytes(totalBytes),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: AppTheme.accentCyan,
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
