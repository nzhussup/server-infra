#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONITORING_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
STACK_DIR="$MONITORING_DIR/kube-prometheus/release-0.17/stack"
OUT_FILE="$STACK_DIR/grafana-dashboard-custom.yaml"
CM_NAME="grafana-dashboard-custom"

json_files=("$SCRIPT_DIR"/*.json)
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
  namespace: monitoring
YAML

  if [[ "$has_json" == true ]]; then
    echo "data:"
    for file in "${json_files[@]}"; do
      key="$(basename "$file")"
      echo "  ${key}: |-"
      sed 's/^/    /' "$file"
      echo
    done
  else
    echo "data: {}"
  fi
} > "$OUT_FILE"

echo "Generated: $OUT_FILE"
