#!/usr/bin/env bash
# Menjalankan aplikasi dengan konfigurasi env (default: env/dev.json).
#   tool/run.sh                 → flutter run --dart-define-from-file=env/dev.json
#   tool/run.sh prod -d <id>    → memakai env/prod.json dan meneruskan argumen lain
set -euo pipefail
cd "$(dirname "$0")/.."
ENV_NAME="${1:-dev}"; shift || true
ENV_FILE="env/${ENV_NAME}.json"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "File $ENV_FILE tidak ada. Salin env/example.json → $ENV_FILE lalu isi nilainya." >&2
  exit 1
fi
exec flutter run --dart-define-from-file="$ENV_FILE" "$@"
