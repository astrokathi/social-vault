import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/responsive/adaptive_scaffold.dart';
import 'core/theme/app_theme.dart';
import 'data/services/share_intent_service.dart';
import 'features/share_sheet/share_collection_sheet.dart';

class ReelVaultApp extends ConsumerStatefulWidget {
  const ReelVaultApp({super.key});

  @override
  ConsumerState<ReelVaultApp> createState() => _ReelVaultAppState();
}

class _ReelVaultAppState extends ConsumerState<ReelVaultApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Listen for incoming share sheet links
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
