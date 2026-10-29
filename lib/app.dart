import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'core/responsive/adaptive_scaffold.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/url_sanitizer.dart';
import 'data/services/share_intent_service.dart';
import 'features/share_sheet/share_collection_sheet.dart';

class ReelVaultApp extends ConsumerStatefulWidget {
  const ReelVaultApp({super.key});

  @override
  ConsumerState<ReelVaultApp> createState() => _ReelVaultAppState();
}

class _ReelVaultAppState extends ConsumerState<ReelVaultApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  String? _lastPromptedUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Listen for incoming share sheet links and check clipboard on initial launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkClipboardForInstagramLink();

      ref.listenManual(incomingShareStreamProvider, (previous, next) {
        next.whenData((url) {
          if (url.isNotEmpty && _navigatorKey.currentContext != null) {
            ShareCollectionSheet.show(_navigatorKey.currentContext!, url);
          }
        });
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboardForInstagramLink();
    }
  }

  Future<void> _checkClipboardForInstagramLink() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (text.isEmpty) return;

      final parsed = UrlSanitizer.parseInstagramUrl(text);
      if (parsed != null && parsed.canonicalUrl != _lastPromptedUrl) {
        _lastPromptedUrl = parsed.canonicalUrl;
        final ctx = _navigatorKey.currentContext;
        if (ctx != null && ctx.mounted) {
          ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              backgroundColor: AppTheme.charcoal,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: AppTheme.accentPink.withValues(alpha: 0.6)),
              ),
              content: Row(
                children: [
                  const Icon(PhosphorIconsFill.instagramLogo, color: AppTheme.accentPink, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Instagram Reel copied!',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
              action: SnackBarAction(
                label: 'Save to Vault',
                textColor: AppTheme.accentPink,
                onPressed: () {
                  ShareCollectionSheet.show(ctx, parsed.canonicalUrl);
                },
              ),
              duration: const Duration(seconds: 8),
            ),
          );
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'ReelVault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AdaptiveScaffold(),
    );
  }
}
