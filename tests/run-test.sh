#!/usr/bin/env bash
# Тест у тимчасовій теці: копія server/ + тестові фікстури + мок n8n + --dry-run.
# Справжні .env / resume-base.md / photo.jpg НЕ потрібні й не читаються. Ключ тут фейковий.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
W="$(mktemp -d)"; trap 'kill $MOCK 2>/dev/null || true' EXIT
cp "$ROOT"/server/run.sh "$ROOT"/server/resume-template.html "$W"/
cp "$ROOT"/tests/fixtures/resume-base.sample.md "$W/resume-base.md"
python3 -c "
from PIL import Image; Image.new('RGB',(64,64),(200,180,160)).save('$W/photo.jpg')" 2>/dev/null || : >"$W/photo.jpg"
PORT=18765
printf 'N8N_BASE=http://127.0.0.1:%s\nJOBS_KEY=test-key-not-real\n' "$PORT" >"$W/.env"
python3 "$ROOT/tests/mock_n8n.py" "$PORT" test-key-not-real "$ROOT/tests/fixtures/queue.json" & MOCK=$!
sleep 1
cd "$W"; export KEEP_RAW="${KEEP_RAW:-}"
CHROMIUM_BIN="${CHROMIUM_BIN:-chromium}" bash ./run.sh --dry-run || true
echo "--- результати в $W/out"; ls "$W/out"
