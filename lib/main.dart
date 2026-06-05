import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'shared/attachments/media_capability.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize media_kit (libmpv) for inline audio/video playback, guarded so a
  // missing/broken backend on any platform degrades to open-externally instead
  // of crashing. pdfrx initializes itself lazily from its viewer widget.
  initMediaBackend();
  runApp(
    const ProviderScope(
      child: PromptForgeApp(),
    ),
  );
}
