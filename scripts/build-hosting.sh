#!/usr/bin/env bash
# Monta build/hosting para o Firebase Hosting:
#   /      -> landing estática (landing/, Astro) — indexável pelo Google
#   /app/  -> app Flutter
# Uso: bash scripts/build-hosting.sh && firebase deploy --only hosting
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

echo "==> Flutter (/app/)"
# MSYS_NO_PATHCONV: no Git Bash do Windows, "/app/" viraria um caminho local.
MSYS_NO_PATHCONV=1 flutter build web --release --base-href /app/

echo "==> Landing (/)"
# O podcast tem uma única cópia versionada, em assets/ do app.
mkdir -p landing/public/audio
cp assets/audio/podcast.mp3 landing/public/audio/
(cd landing && npm ci && npm run build)

echo "==> Juntando em build/hosting"
rm -rf build/hosting
mkdir -p build/hosting
cp -r landing/dist/. build/hosting/
cp -r build/web build/hosting/app

echo "Pronto: build/hosting"
