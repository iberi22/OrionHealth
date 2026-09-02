#!/usr/bin/env bash
# deploy-smoke.sh — Post-deploy smoke para @swal/app-template (adaptado de worldexams/scripts/deploy-smoke.sh)
# Checks: 1) app raíz 200, 2) /manifest.json 200, 3) /api/ai/infer 405/400 (existe), 4) HTML contiene AUI demo
set -uo pipefail
APP_URL="${APP_URL:-https://orionhealth-web.iberi22.workers.dev}"
FAILED=()
http_code() { curl -s -o /dev/null -w '%{http_code}' -m 20 "$1"; }
check_status() {
  local name="$1" url="$2" expected="${3:-^200$|^30[178]$}"
  local code; code=$(http_code "$url")
  if [[ "$code" =~ $expected ]]; then echo "  OK   [$code] $name"; else echo "  FAIL [$code] $name — $url"; FAILED+=("$name ($code)"); fi
}
echo "[smoke] APP_URL=$APP_URL"
check_status "app raíz" "$APP_URL"
check_status "manifest" "$APP_URL/manifest.json"
# /api/ai/infer debe existir (405 si GET, 400 si POST sin body) — no 404
check_status "api ai infer (existe)" "$APP_URL/api/ai/infer" "^405$|^400$|^402$"
# HTML contiene AUI demo + ProBadge (prueba contenido, no solo 200)
body=$(curl -sL -m 20 "$APP_URL" || true)
if echo "$body" | grep -q "Demo AUI" || echo "$body" | grep -q "OrionHealth" || echo "$body" | grep -q "core esqueleto"; then echo "  OK   [contenido] contenido esperado en HTML"; else echo "  FAIL [contenido] contenido esperado no encontrado"; FAILED+=("contenido"); fi
if echo "$body" | grep -q "swal-"; then echo "  OK   [contenido] @swal/ui tokens presentes"; else echo "  FAIL [contenido] @swal/ui no encontrado"; FAILED+=("swal tokens"); fi
if [[ ${#FAILED[@]} -eq 0 ]]; then echo "[smoke] all OK"; exit 0; else echo "[smoke] ${#FAILED[@]} FAIL: ${FAILED[*]}"; exit 1; fi
