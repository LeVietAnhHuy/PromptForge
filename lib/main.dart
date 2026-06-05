import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize media_kit (libmpv) for inline audio/video playback. pdfrx
  // initializes itself lazily from its viewer widget.
  MediaKit.ensureInitialized();
  runApp(
    const ProviderScope(
      child: PromptForgeApp(),
    ),
  );
}
