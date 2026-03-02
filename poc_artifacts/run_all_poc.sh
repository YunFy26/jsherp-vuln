#!/bin/sh
set -e

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
OUT_DIR="$ROOT_DIR/poc_artifacts/run_$(date +%Y%m%d_%H%M%S)"

mkdir -p "$OUT_DIR"

echo "[1/4] IDOR delete (log/msg)"
"$ROOT_DIR/poc_artifacts/poc_idor_log_msg_seeded.sh" | tee "$OUT_DIR/poc_idor_log_msg_seeded.out"

echo "[2/4] Mass assignment registerUser"
"$ROOT_DIR/poc_artifacts/poc_register_mass_assignment.sh" | tee "$OUT_DIR/poc_register_mass_assignment.out"

echo "[3/4] Supplier scope bypass (same tenant, low-priv role)"
"$ROOT_DIR/poc_artifacts/poc_supplier_scope_bypass.sh" | tee "$OUT_DIR/poc_supplier_scope_bypass.out"

echo "[4/4] Supplier cross-tenant probe"
"$ROOT_DIR/poc_artifacts/poc_supplier_idor.sh" | tee "$OUT_DIR/poc_supplier_idor.out"

echo
echo "All PoCs completed. Evidence files:"
echo "$OUT_DIR"
