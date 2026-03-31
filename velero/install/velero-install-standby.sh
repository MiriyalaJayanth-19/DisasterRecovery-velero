#!/bin/bash
# ---------------------------------------------------------------------------------------
# Velero Installation (Standby Cluster - us-west-2)
# ---------------------------------------------------------------------------------------

# Prerequisites: 
# 1. AWS Credentials must be in ../configs/credentials-velero
# 2. Replica bucket: velero-backup-replica (in us-west-2)

echo "Installing Velero on Standby Cluster (us-west-2)..."

velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.9.0 \
  --bucket velero-backup-replica \
  --backup-location-config region=us-west-2 \
  --snapshot-location-config region=us-west-2 \
  --secret-file ./velero/configs/credentials-velero \
  --use-volume-snapshots=true \
  --use-node-agent \
  --features=EnableCSI \
  --wait

echo "---------------------------------------------------------------------------------------"
echo "Velero Installation Complete in us-west-2"
echo "This cluster is now ready for Cross-Region Recovery Drills"
echo "---------------------------------------------------------------------------------------"
