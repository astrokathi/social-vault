import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/url_sanitizer.dart';
import '../../data/database/app_database.dart';
import '../../data/services/local_asset_manager.dart';
import '../share_sheet/share_collection_sheet.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  int _diskBytes = 0;
  bool _isRecalculating = false;
  final double _cacheLimitGB = 2.0;
  double _completionThreshold = 95.0;

  @override
  void initState() {
    super.initState();
    _refreshStorageStats();
  }

  Future<void> _refreshStorageStats() async {
    setState(() => _isRecalculating = true);
    final assetManager = ref.read(localAssetManagerProvider);
    final bytes = await assetManager.calculateDiskUsageBytes();
    if (mounted) {
      setState(() {
        _diskBytes = bytes;
        _isRecalculating = false;
      });
    }
  }

  Future<void> _exportZipBackup() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final vaultDir = Directory(p.join(docsDir.path, 'vault_media'));
      final dbFile = File(p.join(docsDir.path, 'reelvault.sqlite'));

      final encoder = ZipFileEncoder();
      final zipPath = p.join(docsDir.path, 'ReelVault_Backup_${DateTime.now().millisecondsSinceEpoch}.zip');
      encoder.create(zipPath);

      if (await dbFile.exists()) {
        encoder.addFile(dbFile);
      }
      if (await vaultDir.exists()) {
        encoder.addDirectory(vaultDir);
      }
      encoder.close();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.elevated,
            content: Text('Backup archive created at: $zipPath', style: GoogleFonts.inter(color: Colors.white)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.redAccent, content: Text('Export failed: $e')),
        );
      }
    }
  }

  void _showWipeConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.charcoal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Wipe All Local Data?', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
          'This will permanently delete all saved Reels, Collections, watch history, and local video cache.',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final db = ref.read(databaseProvider);
              final assetManager = ref.read(localAssetManagerProvider);
              await db.wipeAllData();
              await assetManager.wipeAllMedia();
              await _refreshStorageStats();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Local vault has been wiped.')),
                );
              }
            },
            child: const Text('Wipe Everything', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final collectionsStream = db.watchAllCollections();
    final allMediaStream = db.watchMediaForCollection(null);

    final usedGB = _diskBytes / (1024 * 1024 * 1024);
    final progressFraction = (usedGB / _cacheLimitGB).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppTheme.oled,
      appBar: AppBar(
        title: Text(
          'Storage & Telemetry',
          style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<CollectionEntity>>(
        stream: collectionsStream,
        builder: (context, colSnap) {
          final collections = colSnap.data ?? [];

          return StreamBuilder<List<VaultMediaEntity>>(
            stream: allMediaStream,
            builder: (context, mediaSnap) {
              final mediaList = mediaSnap.data ?? [];
              final watchedCount = mediaList.where((m) => m.watchProgress >= 0.98).length;

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // 1. Storage Telemetry Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.elevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentCyan.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(PhosphorIconsFill.hardDrives, color: AppTheme.accentCyan, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Local Vault Storage',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Offline Documents Sandbox',
                                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFA1A1AA)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: _isRecalculating
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentCyan))
                                  : const Icon(PhosphorIconsRegular.arrowClockwise, color: Colors.white60, size: 18),
                              onPressed: _refreshStorageStats,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progressFraction,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${UrlSanitizer.formatBytes(_diskBytes)} used',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Cap: ${_cacheLimitGB.toStringAsFixed(1)} GB',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                color: const Color(0xFFA1A1AA),
                              ),
                            ),
                          ],
                        ),

                        const Divider(color: AppTheme.borderDark, height: 28),

                        // Breakdown stats row
                        Row(
                          children: [
                            _buildMiniStat('Reels & Slides', '${mediaList.length} items'),
                            _buildMiniStat('Collections', '${collections.length} folders'),
                            _buildMiniStat('100% Watched', '$watchedCount items'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Playback & Scraper Settings Card
                  _buildSectionHeader('SCRAPER & PLAYBACK ENGINE'),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.elevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(PhosphorIconsRegular.robot, color: AppTheme.accentPurple),
                          title: Text('User-Agent Header', style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
                          subtitle: Text('TelegramBot (OpenGraph Bypass)', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFFA1A1AA))),
                          trailing: const Icon(PhosphorIconsBold.check, color: Colors.greenAccent, size: 18),
                        ),
                        const Divider(color: AppTheme.borderDark, height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Completion Threshold',
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                                  ),
                                  Text(
                                    '${_completionThreshold.round()}%',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.accentPink,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Mark as 100% watched when playback reaches this ratio',
                                style: GoogleFonts.inter(color: const Color(0xFFA1A1AA), fontSize: 11),
                              ),
                              Slider(
                                value: _completionThreshold,
                                min: 80,
                                max: 100,
                                divisions: 4,
                                activeColor: AppTheme.accentPink,
                                inactiveColor: Colors.white12,
                                onChanged: (val) => setState(() => _completionThreshold = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. Data & Vault Actions
                  _buildSectionHeader('SESSION & DATA ACTIONS'),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.elevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(PhosphorIconsRegular.arrowCounterClockwise, color: AppTheme.accentAmber),
                          title: Text('Reset All Watch Progress', style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
                          subtitle: Text('Re-enables completed reels in endless feed', style: GoogleFonts.inter(color: const Color(0xFFA1A1AA), fontSize: 12)),
                          onTap: () async {
                            await db.resetAllProgress();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Watch progress reset to 0% for all items.')),
                              );
                            }
                          },
                        ),
                        const Divider(color: AppTheme.borderDark, height: 1),
                        ListTile(
                          leading: const Icon(PhosphorIconsRegular.fileArchive, color: AppTheme.accentCyan),
                          title: Text('Export ZIP Backup', style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
                          subtitle: Text('Bundles SQLite database & media files', style: GoogleFonts.inter(color: const Color(0xFFA1A1AA), fontSize: 12)),
                          onTap: _exportZipBackup,
                        ),
                        const Divider(color: AppTheme.borderDark, height: 1),
                        ListTile(
                          leading: const Icon(PhosphorIconsRegular.trash, color: Colors.redAccent),
                          title: Text('Wipe All Local Data', style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: Text('Deletes all SQLite tables & downloaded files', style: GoogleFonts.inter(color: const Color(0xFFA1A1AA), fontSize: 12)),
                          onTap: _showWipeConfirmationDialog,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Test Presets (For Simulating Incoming Shares)
                  _buildSectionHeader('DEVELOPER SHARE SIMULATOR'),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.elevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Test Native Share Sheet Intake:',
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              avatar: const Icon(PhosphorIconsRegular.filmReel, size: 14, color: AppTheme.accentPink),
                              label: const Text('Simulate Reel #C9xLmP2o'),
                              backgroundColor: AppTheme.charcoal,
                              side: const BorderSide(color: Colors.white12),
                              onPressed: () {
                                ShareCollectionSheet.show(
                                  context,
                                  'https://www.instagram.com/reel/C9xLmP2oQ1z/?igsh=MWZ4Nm12',
                                );
                              },
                            ),
                            ActionChip(
                              avatar: const Icon(PhosphorIconsRegular.images, size: 14, color: AppTheme.accentPurple),
                              label: const Text('Simulate Carousel #C8kPqR9v'),
                              backgroundColor: AppTheme.charcoal,
                              side: const BorderSide(color: Colors.white12),
                              onPressed: () {
                                ShareCollectionSheet.show(
                                  context,
                                  'https://www.instagram.com/p/C8kPqR9vW4m/?igsh=test1234',
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF71717A),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFFA1A1AA),
            ),
          ),
        ],
      ),
    );
  }
}
