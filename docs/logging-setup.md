# Logging Setup (No Helm, GitOps-Only)

This document describes the in-repo logging stack for production pod log monitoring with Grafana UI.

## Scope

- log collection from Kubernetes pod logs on each node
- centralized storage and query in Loki
- visualization and analysis in existing Grafana
- deployment fully managed from this repository via Argo CD

## Components

- Argo CD application: `argocd/apps/logging.yml`
- Loki manifests: `k8s/logging/loki/`
- Fluent Bit manifests: `k8s/logging/fluent-bit/`
- Grafana datasource provisioning: `k8s/monitoring/kube-prometheus/release-0.17/stack/grafana-dashboardDatasources.yaml`

## Architecture

1. Fluent Bit runs as a `DaemonSet` in namespace `monitoring`.
2. It tails `/var/log/containers/*.log` on each node.
3. Kubernetes metadata is attached (namespace, pod, container).
4. Logs are pushed to `http://loki.monitoring.svc.cluster.local:3100`.
5. Grafana queries Loki through a provisioned `loki` datasource.

## Deployment Flow

1. Commit and push changes in this repository.
2. Argo CD `platform-root` sync picks up `argocd/apps/logging.yml`.
3. Argo CD creates/syncs all resources under `k8s/logging`.
4. Existing `monitoring-stack` app sync updates Grafana datasource secret.

No Helm commands are required.

## Verification

Run these checks after Argo CD reports `Healthy` and `Synced`:

```bash
kubectl -n monitoring get pods -l app.kubernetes.io/name=loki
kubectl -n monitoring get pods -l app.kubernetes.io/name=fluent-bit
kubectl -n monitoring get svc loki
kubectl -n monitoring get secret grafana-datasources
```

Check Loki readiness:

```bash
kubectl -n monitoring port-forward svc/loki 3100:3100
curl -s http://127.0.0.1:3100/ready
```

Expected output: `ready`

## Grafana Usage

1. Open Grafana at `https://monitoring.nzhussup.dev`.
2. Go to `Explore`.
3. Select datasource `loki`.
4. Start with:

```logql
{job="fluent-bit"}
```

Then narrow by labels:

```logql
{job="fluent-bit", namespace="default", pod=~".*llm.*"}
```

## Retention and Storage

- Loki retention is configured to `168h` (7 days).
- Data is stored on PVC `loki-storage` in namespace `monitoring`.
- Requested storage size is `30Gi`.

Adjust as needed:

- retention: `k8s/logging/loki/loki-configmap.yml`
- pvc size: `k8s/logging/loki/loki-pvc.yml`

## Operational Notes

- This setup is single-replica Loki and intended as a simple production baseline.
- For higher durability/scale, migrate Loki storage to object storage and scale components accordingly.
- Fluent Bit buffer is `emptyDir`; short outages may drop logs if Loki is unavailable for long periods.

## Troubleshooting

Fluent Bit cannot send to Loki:

```bash
kubectl -n monitoring logs daemonset/fluent-bit --tail=200
kubectl -n monitoring get endpoints loki
```

No logs in Grafana:

```bash
kubectl -n monitoring get secret grafana-datasources -o yaml
kubectl -n monitoring rollout restart deployment/grafana
```

Loki pod restarts:

```bash
kubectl -n monitoring describe pod -l app.kubernetes.io/name=loki
kubectl -n monitoring logs statefulset/loki --tail=200
```
