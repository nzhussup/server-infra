#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./generate-grafana-custom-dashboard-configmap.sh [SOURCE_DIR] [OUT_FILE]
#
# Optional env vars:
#   CM_NAME, NAMESPACE, MONITORING_DIR, OUT_FILE

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${1:-$SCRIPT_DIR}"
SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"

if [[ -z "${MONITORING_DIR:-}" ]]; then
  for candidate in \
    "$SCRIPT_DIR/../monitoring" \
    "$SCRIPT_DIR/../../k8s/monitoring" \
    "$SCRIPT_DIR/../../monitoring"
  do
    if [[ -d "$candidate/kube-prometheus/release-0.17/stack" ]]; then
      MONITORING_DIR="$(cd "$candidate" && pwd)"
      break
    fi
  done
fi

if [[ -z "${MONITORING_DIR:-}" ]]; then
  echo "Could not resolve MONITORING_DIR. Set MONITORING_DIR env var explicitly." >&2
  exit 1
fi

STACK_DIR="$MONITORING_DIR/kube-prometheus/release-0.17/stack"
DEFAULT_OUT_FILE="$STACK_DIR/grafana-dashboard-custom.yaml"
OUT_FILE="${2:-${OUT_FILE:-$DEFAULT_OUT_FILE}}"
CM_NAME="${CM_NAME:-grafana-dashboard-custom}"
NAMESPACE="${NAMESPACE:-monitoring}"

json_files=("$SOURCE_DIR"/*.json)
has_json=false
if [[ -e "${json_files[0]}" ]]; then
  has_json=true
fi

{
  cat <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/component: grafana
    app.kubernetes.io/name: grafana
    app.kubernetes.io/part-of: kube-prometheus
    app.kubernetes.io/version: 12.4.1
  name: ${CM_NAME}
  namespace: ${NAMESPACE}
YAML

  if [[ "$has_json" == true ]]; then
    echo "data:"
    IFS=$'\n' json_files_sorted=($(printf '%s\n' "${json_files[@]}" | sort))
    unset IFS
    for file in "${json_files_sorted[@]}"; do
      [[ -f "$file" ]] || continue
      key="$(basename "$file")"
      python3 -m json.tool "$file" >/dev/null
      echo "  ${key}: |-"
      sed -E 's/\$\{[Dd][Ss][_ -]?[A-Za-z0-9_-]+\}/prometheus/g; s/\$\{[Dd][Ss]_[A-Za-z0-9_-]+\}/prometheus/g; s/\$\{[Dd][Ss]-[A-Za-z0-9_-]+\}/prometheus/g' "$file" | sed 's/^/    /'
      echo
    done
  else
    echo "data: {}"
  fi
} > "$OUT_FILE"

echo "Generated: $OUT_FILE"
