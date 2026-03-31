# 🛡️ Velero Disaster Recovery Automation

# Variables
PRIMARY_REGION="us-east-1"
STANDBY_REGION="us-west-2"

.PHONY: help foundation backup restore clean

help:
	@echo "--------------------------------------------------------"
	@echo "🛡️ Velero Disaster Recovery: Command Center"
	@echo "--------------------------------------------------------"
	@echo "foundation  - Setup IAM role and S3 buckets with CRR"
	@echo "backup      - Install Velero and apply daily schedules (Primary)"
	@echo "restore     - Run the RTO measurement and restore drill (Standby)"
	@echo "clean       - Cleanup test namespaces"
	@echo "--------------------------------------------------------"

foundation:
	@echo "[Foundation] Running IAM and S3 setup..."
	bash ./s3/create-buckets.sh
	bash ./iam/create-iam-role.sh

backup:
	@echo "[Backup] Installing Velero and scheduling backups..."
	bash ./velero/install/velero-install.sh
	kubectl apply -f ./velero/schedules/full-backup-schedule.yaml

restore:
	@echo "[Restore] Monitoring RTO and running restore drill..."
	bash ./restore/restore-test.sh

clean:
	@echo "[Cleanup] Deleting sample-app namespace..."
	kubectl delete ns sample-app --ignore-not-found
