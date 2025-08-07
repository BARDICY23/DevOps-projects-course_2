#!/bin/bash

export REGION=us-central1
export ZONE=us-central1-a
export TEMPLATE_NAME=tomcat-template
export INSTANCE_GROUP=tomcat-mig
export STARTUP_SCRIPT_PATH=../../startup-scripts/tomcat.sh

# Create instance template
gcloud compute instance-templates create $TEMPLATE_NAME \
  --machine-type=e2-medium \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=20GB \
  --tags=http-server,https-server \
  --metadata-from-file startup-script=$STARTUP_SCRIPT_PATH

# Create managed instance group
gcloud compute instance-groups managed create $INSTANCE_GROUP \
  --base-instance-name=tomcat \
  --template=$TEMPLATE_NAME \
  --size=2 \
  --zone=$ZONE

# Autoscaling policy
gcloud compute instance-groups managed set-autoscaling $INSTANCE_GROUP \
  --zone=$ZONE \
  --max-num-replicas=5 \
  --min-num-replicas=2 \
  --target-cpu-utilization=0.6 \
  --cool-down-period=60

# Attach instance group to backend service
gcloud compute backend-services add-backend tomcat-backend-service \
  --instance-group=$INSTANCE_GROUP \
  --instance-group-zone=$ZONE \
  --global

