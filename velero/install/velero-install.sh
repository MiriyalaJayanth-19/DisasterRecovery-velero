#!/bin/bash
# ---------------------------------------------------------------------------------------
# Velero Installation (Primary Cluster - us-east-1)
# ---------------------------------------------------------------------------------------

# Prerequisites: 
# 1. AWS Credentials must be in ../configs/credentials-velero
# 2. Primary bucket: velero-backup-primary (in us-east-1)

echo "Installing Velero on Primary Cluster (us-east-1)..."

velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.9.0 \
  --bucket velero-backup-primary \
  --backup-location-config region=us-east-1 \
  --snapshot-location-config region=us-east-1 \
  --secret-file ./velero/configs/credentials-velero \
  --use-volume-snapshots=true \
  --use-node-agent \
  --features=EnableCSI \
  --wait

echo "---------------------------------------------------------------------------------------"
echo "Velero Installation Complete in us-east-1"
echo "Next: Apply Backup Schedules"
echo "---------------------------------------------------------------------------------------"
