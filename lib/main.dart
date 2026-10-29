import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Immersive edge-to-edge transparent system overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final container = ProviderContainer();
  final db = container.read(databaseProvider);
  
  // Seed sample collections & media records matching the UI prototype on first run
  await db.seedInitialDataIfEmpty();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ReelVaultApp(),
    ),
  );
}
