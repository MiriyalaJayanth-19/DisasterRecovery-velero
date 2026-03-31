#!/bin/bash
# Description: Automated S3 bucket creation and versioning setup for Cross-Region Replication

PRIMARY_BUCKET="velero-backup-primary"
REPLICA_BUCKET="velero-backup-replica"

echo "--------------------------------------------------------"
echo "Starting S3 Foundation Setup"
echo "--------------------------------------------------------"

echo "[1/3] Creating primary bucket in us-east-1..."
aws s3api create-bucket --bucket $PRIMARY_BUCKET --region us-east-1

echo "[2/3] Creating replica bucket in us-west-2..."
aws s3api create-bucket --bucket $REPLICA_BUCKET \
    --region us-west-2 \
    --create-bucket-configuration LocationConstraint=us-west-2

echo "[3/3] Enabling versioning (Required for CRR)..."
aws s3api put-bucket-versioning --bucket $PRIMARY_BUCKET --versioning-configuration Status=Enabled
aws s3api put-bucket-versioning --bucket $REPLICA_BUCKET --versioning-configuration Status=Enabled

echo "--------------------------------------------------------"
echo "Foundation Setup Complete"
echo "--------------------------------------------------------"
echo "Next: Configure Cross-Region Replication (CRR)"
