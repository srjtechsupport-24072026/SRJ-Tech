#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -z "${API_BASE_URL:-}" ]]; then
  echo "Usage: API_BASE_URL=https://YOUR-RENDER-SERVICE.onrender.com/api ./scripts/deploy_firebase.sh"
  echo "Example: API_BASE_URL=https://srj-tech-api.onrender.com/api ./scripts/deploy_firebase.sh"
  exit 1
fi

echo "Building Flutter web with API_BASE_URL=$API_BASE_URL"
flutter build web --release --dart-define=API_BASE_URL="$API_BASE_URL"

echo "Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo "Done."
