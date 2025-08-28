#!/bin/bash

# This script deploys the OpalSuite environment to a Google Compute Engine instance.
# It provisions a new VM, installs Docker and Docker Compose, copies project files,
# and starts the services using docker-compose.

# --- Configuration ---
PROJECT_ID="${GCP_PROJECT_ID}" # Your Google Cloud Project ID
REGION="${GCP_REGION}"         # Your desired GCP region (e.g., us-central1)
ZONE="${GCP_ZONE:-us-central1-b}" # Your desired GCP zone
INSTANCE_NAME="opalsuite-dev-vm" # Name of the GCE instance
MACHINE_TYPE="e2-medium" # Machine type for the VM (adjust as needed)
IMAGE_FAMILY="debian-11" # Changed to a more specific Debian image family
IMAGE_PROJECT="debian-cloud" # Project for the base OS image
FIREWALL_RULE_NAME="allow-opalsuite-ports" # Name for the firewall rule

# Ports to open on the VM (for external access to apps)
# 3000: opal-portal, 3001: opal-auth-frontend, 5000: opal-database app
APP_PORTS=(3000 3001 5000)

# --- Functions ---
check_gcloud_auth() {
    gcloud auth print-access-token > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: gcloud is not authenticated. Please run 'gcloud auth login' and 'gcloud config set project <YOUR_PROJECT_ID>'."
        exit 1
    fi
}

# --- Main Logic ---

echo "--- Starting OpalSuite GCP Deployment ---"

check_gcloud_auth

# Validate required environment variables
if [ -z "$PROJECT_ID" ]; then
    echo "Error: GCP_PROJECT_ID environment variable is not set."
    exit 1
fi
if [ -z "$REGION" ]; then
    echo "Error: GCP_REGION environment variable is not set."
    exit 1
fi

echo "1. Setting gcloud project and region..."
gcloud config set project $PROJECT_ID
gcloud config set compute/region $REGION

echo "2. Creating Compute Engine instance: $INSTANCE_NAME..."
# Startup script to install Docker, Docker Compose, and run services
STARTUP_SCRIPT=$(cat <<EOF
#! /bin/bash
# Ensure apt-get update runs first
sudo apt-get update -y

# Install Docker
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# Use /etc/os-release directly for VERSION_CODENAME
. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $VERSION_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER # Add current user to docker group
# newgrp docker # This command requires re-login, not suitable for startup script

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create project directory
mkdir -p /opt/opalsuite
chown -R $USER:$USER /opt/opalsuite

echo "Docker and Docker Compose installed."
EOF
)

gcloud compute instances create $INSTANCE_NAME \
  --zone=$ZONE \
  --machine-type=$MACHINE_TYPE \
  --image-family=$IMAGE_FAMILY \
  --image-project=$IMAGE_PROJECT \
  --boot-disk-size=50GB \
  --metadata-from-file=startup-script=<(echo "$STARTUP_SCRIPT") \
  --tags=opalsuite-vm \
  --project=$PROJECT_ID # Explicitly specify project for instance creation

echo "VM instance $INSTANCE_NAME created. Waiting for it to be ready..."
# Get VM external IP for SSH check
VM_EXTERNAL_IP=$(gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

# Wait for SSH to be ready (retry connection)
echo "Waiting for SSH on $VM_EXTERNAL_IP to be ready..."
for i in $(seq 1 10); do # Try 10 times with 10 second delay
    if gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --command="echo SSH is ready." --quiet --strict-host-key-checking=no --ssh-flag="-o ConnectTimeout=10"; then
        echo "SSH is ready."
        break
    else
        echo "SSH not ready yet. Retrying in 10 seconds..."
        sleep 10
    fi
    if [ $i -eq 10 ]; then
        echo "Error: SSH did not become ready after multiple attempts. Aborting."
        exit 1
    fi
done

echo "3. Copying project files to the VM..."
# Copy the entire OpalSuite directory to the VM
gcloud compute scp --recurse . $INSTANCE_NAME:/opt/opalsuite/ --zone=$ZONE --quiet --compress

echo "4. Starting Docker Compose services on the VM..."
# SSH into the VM and run docker-compose up
gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --command="
  cd /opt/opalsuite/OpalSuite # Navigate to the root of the cloned project
  docker-compose up -d --build
"

echo "5. Configuring firewall rules..."
# Allow TCP traffic on specified application ports
# Corrected syntax for --allow with multiple ports
gcloud compute firewall-rules create $FIREWALL_RULE_NAME \
  --allow=tcp:$(IFS=,; echo "${APP_PORTS[*]}") \
  --target-tags=opalsuite-vm \
  --description="Allow traffic to OpalSuite application ports" \
  --project=$PROJECT_ID # Explicitly specify project for firewall rule

echo "--- Deployment Complete ---"
VM_EXTERNAL_IP=$(gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
echo "OpalSuite deployed to VM: $INSTANCE_NAME"
echo "External IP: $VM_EXTERNAL_IP"
echo "Access your applications on ports: ${APP_PORTS[*]}"
echo "PostgreSQL is accessible internally within the VM on port 5432."
echo "Remember to configure DNS for your domains (api.opalsuite.com, auth.opalsuite.com, portal.opalsuite.com) to point to this IP."