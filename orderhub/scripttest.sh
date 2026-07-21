#!/bin/bash
# Stress test simultaneo per orderhub-staging
# Verifica prima i nomi reali dei pod con: kubectl get pods -n orderhub-staging

set -x

NAMESPACE="orderhub-staging"
FRONTEND_POD=$(kubectl get pod -n $NAMESPACE -l app=orderhub-frontend -o jsonpath='{.items[0].metadata.name}')
BACKEND_POD=$(kubectl get pod -n $NAMESPACE -l app=orderhub-backend -o jsonpath='{.items[0].metadata.name}')
DB_POD=$(kubectl get pod -n $NAMESPACE -l app=orderhub-db -o jsonpath='{.items[0].metadata.name}')

echo "Frontend pod: $FRONTEND_POD"
echo "Backend pod:  $BACKEND_POD"
echo "DB pod:       $DB_POD"

# 1. Traffico HTTP continuo verso il backend
kubectl exec -it $FRONTEND_POD -n $NAMESPACE -c orderhub-frontend -- sh -c '
for i in $(seq 1 200); do curl -s -o /dev/null http://orderhub-backend-svc/; sleep 0.2; done' &

# 2. Genera errori 404
kubectl exec -it $FRONTEND_POD -n $NAMESPACE -c orderhub-frontend -- sh -c '
for i in $(seq 1 100); do curl -s -o /dev/null http://orderhub-backend-svc/pagina-inesistente-$i; sleep 0.3; done' &

# 3. Stress CPU sul backend
kubectl exec -it $BACKEND_POD -n $NAMESPACE -c orderhub-backend -- sh -c 'yes > /dev/null &' &

# 4. Connessioni TCP dirette al DB
kubectl exec -it $BACKEND_POD -n $NAMESPACE -c orderhub-backend -- sh -c '
for i in $(seq 1 50); do curl -s --connect-timeout 1 orderhub-db-svc:5432 > /dev/null 2>&1; sleep 0.5; done' &

# 5. Log applicativi ripetuti
kubectl exec -it $BACKEND_POD -n $NAMESPACE -c orderhub-backend -- sh -c '
for i in $(seq 1 100); do echo "test log line $i $(date)"; sleep 0.2; done' &

# 6. Query lenta al DB
kubectl exec -it $DB_POD -n $NAMESPACE -- psql -U postgres -c "SELECT pg_sleep(3);" &

# 7. Traffico parallelo massiccio (5 loop annidati)
kubectl exec -it $FRONTEND_POD -n $NAMESPACE -c orderhub-frontend -- sh -c '
for j in $(seq 1 5); do
  (for i in $(seq 1 50); do curl -s -o /dev/null http://orderhub-backend-svc/; done) &
done
wait' &

echo "Tutti i job lanciati in background. Aspetto la fine..."
wait
echo "Stress test completato."