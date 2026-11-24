#!/usr/bin/env bash
# Menjalankan Firebase Emulator (Auth 9099, Firestore 8086) yang TERBUKA ke
# jaringan lokal (0.0.0.0) agar HP fisik bisa terhubung — memakai rules dan
# firebase-tools dari repo CSMS. Seed data tetap lewat repo CSMS:
#   cd ../admin-indosafetymarine/qa/automation && npm run seed
set -euo pipefail
cd "$(dirname "$0")/.."
CSMS="${CSMS_DIR:-../admin-indosafetymarine}"
FIREBASE="$CSMS/qa/automation/node_modules/.bin/firebase"
[[ -x "$FIREBASE" ]] || { echo "firebase-tools tidak ditemukan: jalankan npm install di $CSMS/qa/automation" >&2; exit 1; }
cp "$CSMS/firestore.rules" tool/emulator/firestore.rules
echo "Emulator terbuka di $(ipconfig getifaddr en0 2>/dev/null || echo '<ip-mac>'):9099 / :8086 — isi EMULATOR_HOST di env/dev.json dengan IP ini untuk HP fisik."
exec "$FIREBASE" emulators:start --only auth,firestore --project indosafetymarine-9b920 --config tool/emulator/firebase.json
