import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart' show SingleActivator;

/// The single source of truth for command-key shortcuts across the app.
///
/// Returns a [SingleActivator] that uses **Cmd on macOS** and **Ctrl on Windows
/// and Linux** — the platform-correct "command" modifier — so call sites never
/// hand-roll separate `control:`/`meta:` bindings. Pure navigation keys (arrows,
/// Escape, Enter without a command modifier) don't go through here; they need no
/// platform mapping.
SingleActivator cmdOrCtrl(
  LogicalKeyboardKey key, {
  bool shift = false,
  bool alt = false,
}) {
  final isMac = defaultTargetPlatform == TargetPlatform.macOS;
  return SingleActivator(
    key,
    control: !isMac,
    meta: isMac,
    shift: shift,
    alt: alt,
  );
}

/// Human-readable label for the command modifier on the current platform
/// ("⌘" on macOS, "Ctrl" elsewhere) for help text and tooltips.
String get cmdOrCtrlLabel =>
    defaultTargetPlatform == TargetPlatform.macOS ? '⌘' : 'Ctrl';
