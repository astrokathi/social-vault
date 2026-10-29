import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';

class VaultImage extends StatefulWidget {
  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;

  const VaultImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorWidget,
  });

  @override
  State<VaultImage> createState() => _VaultImageState();
}

class _VaultImageState extends State<VaultImage> {
  String? _resolvedLocalPath;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _resolvePath();
  }

  @override
  void didUpdateWidget(VaultImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _resolvePath();
    }
  }

  Future<void> _resolvePath() async {
    final path = widget.imagePath.trim();
    if (path.isEmpty || path.startsWith('http://') || path.startsWith('https://')) {
      if (mounted) {
        setState(() {
          _resolvedLocalPath = null;
          _isChecking = false;
        });
      }
      return;
    }

    try {
      // If it's already an absolute file path and exists
      final directFile = File(path);
      if (await directFile.exists()) {
        if (mounted) {
          setState(() {
            _resolvedLocalPath = directFile.path;
            _isChecking = false;
          });
        }
        return;
      }

      // Resolve relative path against application documents directory
      final docsDir = await getApplicationDocumentsDirectory();
      final fullPath = p.join(docsDir.path, path);
      final file = File(fullPath);

      if (await file.exists()) {
        if (mounted) {
          setState(() {
            _resolvedLocalPath = fullPath;
            _isChecking = false;
          });
        }
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _resolvedLocalPath = null;
        _isChecking = false;
      });
    }
  }

  Widget _buildFallback() {
    if (widget.errorWidget != null) return widget.errorWidget!;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: const BoxDecoration(
        color: AppTheme.charcoal,
        gradient: LinearGradient(
          colors: [
            AppTheme.elevated,
            AppTheme.charcoal,
            AppTheme.oled,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsFill.filmReel,
              size: (widget.height != null && widget.height! < 100) ? 20 : 32,
              color: AppTheme.accentPink.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.imagePath.trim();

    if (_isChecking) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: AppTheme.charcoal,
      );
    }

    // 1. Local resolved file exists
    if (_resolvedLocalPath != null) {
      return Image.file(
        File(_resolvedLocalPath!),
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }

    // 2. Remote HTTP URL
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }

    // 3. Fallback
    return _buildFallback();
  }
}
