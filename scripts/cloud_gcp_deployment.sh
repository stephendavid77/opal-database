#!/bin/bash

# This script deploys a PostgreSQL instance to Google Cloud SQL.

# --- Configuration ---
PROJECT_ID="your-gcp-project-id" # REPLACE WITH YOUR GCP PROJECT ID
REGION="us-central1"             # REPLACE WITH YOUR DESIRED GCP REGION
INSTANCE_NAME="opalsuite-db-instance" # Cloud SQL instance name
DATABASE_NAME="opalsuite_db"     # Database name within the instance
DB_USER="opalsuite_user"         # Database user
DB_PASSWORD="your_strong_password" # REPLACE WITH A STRONG PASSWORD

# --- Deployment Steps ---

echo "1. Setting gcloud project and region..."
gcloud config set project $PROJECT_ID
gcloud config set compute/region $REGION

echo "2. Creating Cloud SQL PostgreSQL instance: $INSTANCE_NAME..."
# For production, consider more advanced options like high availability, backups, etc.
gcloud sql instances create $INSTANCE_NAME \
  --database-version=POSTGRES_13 \
  --region=$REGION \
  --tier=db-f1-micro \
  --root-password=$DB_PASSWORD \
  --storage-size=20GB \
  --storage-type=SSD \
  --backup-start-time=03:00 \
  --enable-bin-log \
  --project=$PROJECT_ID

echo "3. Creating database: $DATABASE_NAME..."
gcloud sql databases create $DATABASE_NAME \
  --instance=$INSTANCE_NAME \
  --project=$PROJECT_ID

echo "4. Creating database user: $DB_USER..."
gcloud sql users create $DB_USER \
  --host=% \
  --instance=$INSTANCE_NAME \
  --password=$DB_PASSWORD \
  --project=$PROJECT_ID

echo "--- Deployment Complete ---"
echo "Cloud SQL Instance: $INSTANCE_NAME"
echo "Database Name: $DATABASE_NAME"
echo "Database User: $DB_USER"
echo "Database Password: $DB_PASSWORD"
echo ""
echo "To connect to your database, you might need to configure authorized networks or use the Cloud SQL Proxy."
echo "For example, to get the connection string:"
echo "gcloud sql instances describe $INSTANCE_NAME --format='value(connectionName)'"
echo "Then use the Cloud SQL Proxy: cloud_sql_proxy -instances=<CONNECTION_NAME>=tcp:5432"
echo ""
echo "Remember to replace placeholder values in this script before running."
