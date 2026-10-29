import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../../core/utils/url_sanitizer.dart';

class ShareIntentService {
  final _sharedUrlController = StreamController<String>.broadcast();
  Stream<String> get onSharedUrlReceived => _sharedUrlController.stream;
  StreamSubscription? _intentSub;

  ShareIntentService() {
    _initListener();
  }

  void _initListener() {
    // Only listen to native platform intents on supported mobile devices
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      try {
        // Warm state: listen for incoming shared links while app is in background/foreground
        _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
          (List<SharedMediaFile> value) {
            for (final file in value) {
              _processSharedText(file.path);
            }
          },
          onError: (err) {
            debugPrint('ReceiveSharingIntent stream error: $err');
          },
        );

        // Cold start: check if app was opened via Share Sheet
        ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
          for (final file in value) {
            _processSharedText(file.path);
          }
          ReceiveSharingIntent.instance.reset();
        });
      } catch (e) {
        debugPrint('Could not initialize ReceiveSharingIntent: $e');
      }
    }
  }

  void _processSharedText(String text) {
    final parsed = UrlSanitizer.parseInstagramUrl(text);
    if (parsed != null) {
      _sharedUrlController.add(parsed.canonicalUrl);
    } else if (text.contains('instagram.com/')) {
      _sharedUrlController.add(text.trim());
    }
  }

  /// Manually trigger a shared URL (useful for simulators, web, and the in-app Share Test modal)
  void simulateIncomingShare(String url) {
    _sharedUrlController.add(url);
  }

  void dispose() {
    _intentSub?.cancel();
    _sharedUrlController.close();
  }
}

final shareIntentServiceProvider = Provider<ShareIntentService>((ref) {
  final service = ShareIntentService();
  ref.onDispose(() => service.dispose());
  return service;
});

final incomingShareStreamProvider = StreamProvider<String>((ref) {
  final service = ref.watch(shareIntentServiceProvider);
  return service.onSharedUrlReceived;
});
