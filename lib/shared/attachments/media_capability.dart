import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

/// Whether the media_kit (libmpv) backend initialized successfully on this
/// platform. When false, the audio/video renderers skip creating a [Player] and
/// show the in-app error panel + "Open externally" instead of crashing.
///
/// Windows and macOS bundle libmpv via `media_kit_libs_video`; Linux links the
/// system libmpv (bundled into release artifacts during packaging). If that
/// backend is missing or fails to load, this stays false and playback degrades
/// gracefully rather than taking down the app.
bool mediaBackendReady = false;

/// Initializes the media backend once, guarded so a missing/broken libmpv can
/// never crash startup. Call before `runApp`. Never throws.
void initMediaBackend() {
  try {
    MediaKit.ensureInitialized();
    mediaBackendReady = true;
  } catch (e, st) {
    mediaBackendReady = false;
    debugPrint(
        'media_kit init failed; audio/video fall back to open-externally: $e\n$st');
  }
}
