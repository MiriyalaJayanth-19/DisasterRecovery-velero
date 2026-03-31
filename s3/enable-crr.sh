#!/bin/bash
# ---------------------------------------------------------------------------------------------------------
# S3 Cross-Region Replication (CRR) Activation Script
# ---------------------------------------------------------------------------------------------------------

PRIMARY_BUCKET="velero-backup-primary"
REPLICA_BUCKET="velero-backup-replica"
REPLICATION_ROLE_NAME="VeleroBucketReplicationRole"

echo "--------------------------------------------------------"
echo "Setting up Cross-Region Replication (CRR)"
echo "--------------------------------------------------------"

# 1. Create Replication IAM Role & Policy
echo "[1/3] Creating Replication IAM Role: $REPLICATION_ROLE_NAME..."
cat <<EOF > /tmp/trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "s3.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

ROLE_ARN=$(aws iam create-role --role-name $REPLICATION_ROLE_NAME --assume-role-policy-document file:///tmp/trust-policy.json --query 'Role.Arn' --output text)

# 2. Attach Permissions (Primary -> Replica)
echo "[2/3] Attaching replication permissions to role..."
cat <<EOF > /tmp/replication-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetReplicationConfiguration", "s3:ListBucket"],
      "Resource": ["arn:aws:s3:::$PRIMARY_BUCKET"]
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObjectVersionForReplication", "s3:GetObjectVersionAcl", "s3:GetObjectVersionTagging"],
      "Resource": ["arn:aws:s3:::$PRIMARY_BUCKET/*"]
    },
    {
      "Effect": "Allow",
      "Action": ["s3:ReplicateObject", "s3:ReplicateDelete", "s3:ReplicateTags"],
      "Resource": ["arn:aws:s3:::$REPLICA_BUCKET/*"]
    }
  ]
}
EOF

aws iam put-role-policy --role-name $REPLICATION_ROLE_NAME --policy-name ReplicationPolicy --policy-document file:///tmp/replication-policy.json

# 3. Apply Replication Configuration to Primary Bucket
echo "[3/3] Applying replication configuration to $PRIMARY_BUCKET..."
cat <<EOF > /tmp/crr-config.json
{
  "Role": "$ROLE_ARN",
  "Rules": [
    {
      "Status": "Enabled",
      "Priority": 1,
      "DeleteMarkerReplication": { "Status": "Disabled" },
      "Filter": {},
      "Destination": { "Bucket": "arn:aws:s3:::$REPLICA_BUCKET" }
    }
  ]
}
EOF

aws s3api put-bucket-replication --bucket $PRIMARY_BUCKET --replication-configuration file:///tmp/crr-config.json

echo "--------------------------------------------------------"
echo "CRR Setup Complete! Primary bucket is now syncing to $REPLICA_BUCKET."
echo "--------------------------------------------------------"
