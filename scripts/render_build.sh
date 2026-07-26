#!/usr/bin/env bash
# Build the Flutter web app inside Render's static site build environment.
# Render has no Flutter runtime, so the SDK is downloaded into the build cache.
set -euo pipefail

FLUTTER_VERSION="3.22.0"
FLUTTER_HOME="${XDG_CACHE_HOME:-$HOME/.cache}/flutter-${FLUTTER_VERSION}"
API_BASE_URL="${API_BASE_URL:-https://srj-tech-website-apis.onrender.com/api}"

if [ ! -x "${FLUTTER_HOME}/bin/flutter" ]; then
  echo "Downloading Flutter ${FLUTTER_VERSION}..."
  mkdir -p "${FLUTTER_HOME}"
  curl -fsSL \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    | tar -xJ --strip-components=1 -C "${FLUTTER_HOME}"
else
  echo "Reusing cached Flutter ${FLUTTER_VERSION}"
fi

export PATH="${FLUTTER_HOME}/bin:${PATH}"

# Render's build container clones the repo as a different user than the SDK dir owner.
git config --global --add safe.directory "${FLUTTER_HOME}"

flutter --version
flutter config --enable-web --no-analytics
flutter pub get

# CanvasKit is required: the HTML renderer does not support BackdropFilter,
# which the site's glassmorphism panels rely on.
flutter build web \
  --release \
  --web-renderer canvaskit \
  --dart-define=API_BASE_URL="${API_BASE_URL}"

echo "Build complete -> build/web (API: ${API_BASE_URL})"
