#!/bin/sh
set -e

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
OUT_DIR="$ROOT_DIR/poc_artifacts/run_$(date +%Y%m%d_%H%M%S)"

mkdir -p "$OUT_DIR"

run_and_save() {
  title="$1"
  script_path="$2"
  out_file="$3"

  echo "$title"
  set +e
  "$script_path" > "$out_file" 2>&1
  rc=$?
  set -e

  cat "$out_file"
  if [ "$rc" -ne 0 ]; then
    echo "[-] Script failed: $script_path (exit $rc)"
    exit "$rc"
  fi
}

run_and_save "[1/4] IDOR delete (log/msg)" \
  "$ROOT_DIR/poc_artifacts/poc_idor_log_msg_seeded.sh" \
  "$OUT_DIR/poc_idor_log_msg_seeded.out"

run_and_save "[2/4] Mass assignment registerUser" \
  "$ROOT_DIR/poc_artifacts/poc_register_mass_assignment.sh" \
  "$OUT_DIR/poc_register_mass_assignment.out"

run_and_save "[3/4] Supplier scope bypass (same tenant, low-priv role)" \
  "$ROOT_DIR/poc_artifacts/poc_supplier_scope_bypass.sh" \
  "$OUT_DIR/poc_supplier_scope_bypass.out"

run_and_save "[4/4] Supplier cross-tenant probe" \
  "$ROOT_DIR/poc_artifacts/poc_supplier_idor.sh" \
  "$OUT_DIR/poc_supplier_idor.out"

echo
echo "All PoCs completed. Evidence files:"
echo "$OUT_DIR"
