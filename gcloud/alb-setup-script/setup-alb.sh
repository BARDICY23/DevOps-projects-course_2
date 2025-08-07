#!/bin/bash

export REGION=us-central1
export ZONE=us-central1-a
export DOMAIN_NAME=dark-lord.xyz

# Reserve a global static IP
gcloud compute addresses create lb-ipv4 --ip-version=IPV4 --global

# Create a health check
gcloud compute health-checks create http tomcat-health-check \
  --port 8080 \
  --request-path /

# Create a backend service and attach health check
gcloud compute backend-services create tomcat-backend-service \
  --protocol=HTTP \
  --health-checks=tomcat-health-check \
  --port-name=http \
  --global

# Create URL map to route requests to backend
gcloud compute url-maps create tomcat-url-map \
  --default-service tomcat-backend-service

# Create target HTTP proxy
gcloud compute target-http-proxies create http-proxy \
  --url-map=tomcat-url-map

# Create target HTTPS proxy (will be used after SSL cert is ready)
gcloud compute ssl-certificates create tomcat-cert \
  --domains=$DOMAIN_NAME

gcloud compute target-https-proxies create https-proxy \
  --ssl-certificates=tomcat-cert \
  --url-map=tomcat-url-map

# Create forwarding rules (HTTP + HTTPS)
gcloud compute forwarding-rules create http-content-rule \
  --address=lb-ipv4 \
  --global \
  --target-http-proxy=http-proxy \
  --ports=80

gcloud compute forwarding-rules create https-content-rule \
  --address=lb-ipv4 \
  --global \
  --target-https-proxy=https-proxy \
  --ports=443

