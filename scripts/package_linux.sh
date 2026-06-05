#!/usr/bin/env bash
# Packages a built Flutter Linux release into distributable artifacts under dist/:
#   - promptforge-<version>-linux-x64.tar.gz   (always; self-contained bundle)
#   - PromptForge-<version>-x86_64.AppImage    (best-effort via linuxdeploy)
#
# The AppImage is preferred (portable, bundles libmpv + its dependency tree) but
# is best-effort: if the AppImage tooling can't run on the host/runner, the
# tar.gz still ships (per the Stage 26 brief). Run AFTER `flutter build linux
# --release`.
#
# Usage: scripts/package_linux.sh [VERSION]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

VERSION="${1:-$(awk -F'[:+]' '/^version:/ {gsub(/ /,"",$2); print $2; exit}' pubspec.yaml)}"
APPID="io.github.levietanhhuy.promptforge"
BUNDLE="build/linux/x64/release/bundle"
DIST="$ROOT/dist"
mkdir -p "$DIST"

if [ ! -x "$BUNDLE/promptforge" ]; then
  echo "ERROR: $BUNDLE/promptforge not found. Run 'flutter build linux --release' first." >&2
  exit 1
fi

# 1) Make the bundle self-contained for audio/video, then tar it (always works).
bash "$ROOT/scripts/bundle_linux_libmpv.sh" "$BUNDLE"
TARBALL="$DIST/promptforge-$VERSION-linux-x64.tar.gz"
tar -C "$(dirname "$BUNDLE")" -czf "$TARBALL" "$(basename "$BUNDLE")"
echo "Created $TARBALL"

# 2) Best-effort AppImage.
build_appimage() {
  local arch="x86_64"
  local appdir="build/appimage/PromptForge.AppDir"
  rm -rf "$appdir"
  mkdir -p "$appdir/usr/bin" \
           "$appdir/usr/share/applications" \
           "$appdir/usr/share/icons/hicolor/512x512/apps"

  # Flutter finds data/ and lib/ relative to the executable; keep them together.
  cp -r "$BUNDLE"/. "$appdir/usr/bin/"

  cat > "$appdir/usr/share/applications/$APPID.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=PromptForge
Comment=Local-first prompt engineering workspace
Exec=promptforge
Icon=$APPID
Categories=Development;Utility;
Terminal=false
EOF
  cp "$ROOT/assets/brand/promptforge_icon_512.png" \
     "$appdir/usr/share/icons/hicolor/512x512/apps/$APPID.png"
  cp "$ROOT/assets/brand/promptforge_icon_512.png" "$appdir/$APPID.png"

  local tools="build/appimage/tools"
  mkdir -p "$tools"
  local ld="$tools/linuxdeploy-$arch.AppImage"
  local ldgtk="$tools/linuxdeploy-plugin-gtk.sh"
  if [ ! -x "$ld" ]; then
    curl -fsSL -o "$ld" \
      "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-$arch.AppImage"
    chmod +x "$ld"
  fi
  if [ ! -x "$ldgtk" ]; then
    curl -fsSL -o "$ldgtk" \
      "https://raw.githubusercontent.com/linuxdeploy/linuxdeploy-plugin-gtk/master/linuxdeploy-plugin-gtk.sh"
    chmod +x "$ldgtk"
  fi

  export OUTPUT="PromptForge-$VERSION-$arch.AppImage"
  export PATH="$ROOT/$tools:$PATH"
  # Run all AppImage tooling (linuxdeploy AND the appimagetool it invokes) by
  # extracting rather than mounting, so no FUSE is required on CI runners.
  export APPIMAGE_EXTRACT_AND_RUN=1
  "$ld" --appimage-extract-and-run \
    --appdir "$appdir" \
    --executable "$appdir/usr/bin/promptforge" \
    --desktop-file "$appdir/usr/share/applications/$APPID.desktop" \
    --icon-file "$appdir/$APPID.png" \
    --plugin gtk \
    --output appimage
  mv "$OUTPUT" "$DIST/$OUTPUT"
  echo "Created $DIST/$OUTPUT"
}

if build_appimage; then
  echo "AppImage build succeeded."
else
  echo "WARNING: AppImage build failed; shipping the tar.gz only (allowed fallback)." >&2
fi

echo "Linux artifacts:"
ls -la "$DIST"
