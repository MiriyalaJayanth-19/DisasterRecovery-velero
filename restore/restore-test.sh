#!/bin/bash
# ---------------------------------------------------------------------------------------------------------
# Disaster Recovery Restore Drill & RTO Measurement
# Target Region: us-west-2 (Standby)
# ---------------------------------------------------------------------------------------------------------

NAMESPACE_TO_RESTORE="sample-app"
REPLICA_BUCKET="velero-backup-replica"

echo "--------------------------------------------------------"
echo "Starting DR Restore Drill & RTO Measurement"
echo "--------------------------------------------------------"

# 1. Clean Environment
echo "[Step 1/4] Ensuring clean environment: Deleting $NAMESPACE_TO_RESTORE..."
kubectl delete ns $NAMESPACE_TO_RESTORE --ignore-not-found --wait

# 2. Identify Latest Backup
echo "[Step 2/4] Identifying latest backup in replicated bucket: $REPLICA_BUCKET..."
LATEST_BACKUP=$(velero backup get --sort-column="created" --reverse | head -n 2 | tail -n 1 | awk '{print $1}')
echo "Using latest backup: $LATEST_BACKUP"

# 3. Start Restore & Time
START_TIME=$(date +%s)
echo "[Step 3/4] Triggering Velero restore from backup: $LATEST_BACKUP..."
velero restore create --from-backup $LATEST_BACKUP --wait

# 4. Measure RTO (Poll for Pods Running)
echo "[Step 4/4] Measuring RTO (Polling for Pods in $NAMESPACE_TO_RESTORE)..."
while [[ $(kubectl get pods -n $NAMESPACE_TO_RESTORE -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}' | grep -o "True" | wc -l) -eq 0 ]]; do
  echo "Still waiting for pods..."
  sleep 5
done

END_TIME=$(date +%s)
RTO_SECONDS=$((END_TIME - START_TIME))

echo "--------------------------------------------------------"
echo "Restore Drill Complete!"
echo "Recovery Time Objective (RTO): $RTO_SECONDS seconds"
echo "Result logged to restore/rto-report.log"
echo "--------------------------------------------------------"

echo "$(date): Backup=$LATEST_BACKUP RTO=$RTO_SECONDS seconds" >> ./restore/rto-report.log
