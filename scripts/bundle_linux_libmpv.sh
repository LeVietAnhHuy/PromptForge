#!/usr/bin/env bash
# Bundles the system libmpv into a Flutter Linux release bundle's lib/ so the
# bundle ships its own audio/video backend. On Linux media_kit links the *system*
# libmpv.so.2 (Windows/macOS bundle libmpv automatically via media_kit_libs_*),
# so without this step a Linux artifact has a runtime dependency on a system
# libmpv. The Flutter Linux executable's rpath includes $ORIGIN/lib, so a copy
# placed here is found first at runtime.
#
# Usage: scripts/bundle_linux_libmpv.sh [BUNDLE_DIR]
#   BUNDLE_DIR defaults to build/linux/x64/release/bundle
#
# Note: this copies libmpv.so.2 itself. For a fully portable artifact that also
# carries libmpv's own dependency tree, the AppImage build (see docs/RELEASING.md)
# uses linuxdeploy, which walks and bundles the whole tree.
set -euo pipefail

BUNDLE_DIR="${1:-build/linux/x64/release/bundle}"
LIB_DIR="$BUNDLE_DIR/lib"

if [ ! -d "$BUNDLE_DIR" ]; then
  echo "ERROR: bundle dir not found: $BUNDLE_DIR (run 'flutter build linux --release' first)" >&2
  exit 1
fi
mkdir -p "$LIB_DIR"

# Resolve libmpv via the dynamic-linker cache first, then common locations.
# (Pipe to `tail` rather than `awk ...exit` so the reader consumes the whole
# stream — an early awk exit would SIGPIPE ldconfig and, under pipefail, abort.)
SRC="$(ldconfig -p 2>/dev/null | awk '/libmpv\.so\.2/ {print $NF}' | tail -n1)"
if [ -z "${SRC:-}" ]; then
  for c in /usr/lib/x86_64-linux-gnu/libmpv.so.2 /usr/lib/libmpv.so.2 \
           /usr/lib64/libmpv.so.2 /lib/x86_64-linux-gnu/libmpv.so.2; do
    [ -e "$c" ] && SRC="$c" && break
  done
fi
if [ -z "${SRC:-}" ]; then
  echo "ERROR: libmpv.so.2 not found. Install it (Debian/Ubuntu: apt-get install -y libmpv2 || libmpv-dev)." >&2
  exit 1
fi

# Dereference symlinks so the real shared object lands under the soname.
cp -L "$SRC" "$LIB_DIR/libmpv.so.2"
echo "Bundled $(readlink -f "$SRC") -> $LIB_DIR/libmpv.so.2"
