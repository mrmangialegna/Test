# Kubernetes Infrastructure – Portfolio Example

This repository collects four **multi-pod Helm projects** designed to
demonstrate a progression of skills in building, securing, and
automating infrastructure on Kubernetes.

Each project is contained in a separate folder and comes with a
complete Helm chart, ready to be installed with `helm install`.

---

## Projects

| Project | Folder | Complexity | Main Topics |
| :--- | :--- | :--- | :--- |
| **TradeX** | `tradex/` | Basic | Deployment, StatefulSet, Service, Ingress, NetworkPolicy, RBAC, HPA |
| **ShopSync** | `shopsync/` | Intermediate | Everything in TradeX + Pod Security Standards, Promtail ConfigMap |
| **OrderHub** | `orderhub/` | Advanced | Everything in ShopSync + CI/CD (GitHub Actions), self-hosted runner, automatic image tagging |
| **LogStream** | `logstream/` | Advanced | Python application with Prometheus metrics, ready for Grafana monitoring |

---

## Progression

### TradeX – Kubernetes Fundamentals

The first project covers all the core objects:

- **Deployment** for frontend and backend.
- **StatefulSet** for PostgreSQL.
- **Service** (ClusterIP and Headless).
- **IngressRoute** with Traefik and Middleware for rate limiting.
- **NetworkPolicy** to isolate components.
- **RBAC** (ServiceAccount, Role, RoleBinding).
- **HPA** for autoscaling.

### ShopSync – Security and Observability

An extension of TradeX that adds:

- **Pod Security Standards (Restricted)** with `securityContext`.
- **Promtail ConfigMap** for log collection towards Loki.

### OrderHub – CI/CD and Automation

The most operationally complete project:

- **GitHub Actions** with a workflow that builds and pushes Docker images.
- **Self-hosted runner** on a container, with access to the local registry.
- Automatic image tag update in `values.yaml`.
- Real deployment on a **Proxmox** cluster with a private registry.

### LogStream – Monitoring and Metrics

An application that produces real data for monitoring:

- **Python server** with Flask.
- **`/metrics` endpoint** exposed via `prometheus_client`.
- Ready to be connected to **Prometheus** and **Grafana**.

---

## Technologies Used

- **Kubernetes** (Deployment, StatefulSet, Service, Ingress, NetworkPolicy,
  RBAC, HPA, CRD)
- **Helm** (chart, template, values, lint)
- **Traefik** (Ingress Controller, Middleware)
- **Docker** (multi-stage build, security context, entrypoint)
- **GitHub Actions** (workflow, matrix, self-hosted runner)
- **Proxmox** (on-premise cluster)
- **Prometheus/Grafana** (metrics and dashboards)
- **Linux** (troubleshooting, shell scripting)

---

## How to Use This Repository

1. Clone the repository.
2. For each project, enter the corresponding folder.
3. Run `helm lint .` to check the syntax.
4. Install the chart with:
   ```bash
   helm install <release-name> . -n <namespace> --create-namespace
   ```