#!/usr/bin/env bash

# Prepare gcloud auth credentials
echo -n -E $GOOGLE_SERVICE_KEY_BLOB | base64 --decode > /tmp/key.json

# Auth with gcloud using a service account and credentials file
gcloud auth activate-service-account $GOOGLE_SERVICE_ACCOUNT --key-file=/tmp/key.json

# Configure gcloud
gcloud config set project $PROJECT_ID
gcloud config set compute/zone $COMPUTE_ZONE

# Set up cluster
gcloud container clusters create $CLUSTER_NAME --enable-autoscaling --min-nodes=1 --max-nodes=10
gcloud container clusters get-credentials $CLUSTER_NAME

# If you're using a SQL instance, prepare SQL credentials for cloudsql proxy and create secrets to be used in deployment yaml
echo -n -E $GOOGLE_SQL_KEY_BLOB | base64 --decode > /tmp/sqlkey.json

# Recrate secrets if they already exist, otherwise the values will not be updated
secrets=`kubectl get secret`

if [[ $secrets =~ 'cloudsql-instance-credentials' ]]; then
  kubectl delete secret cloudsql-instance-credentials
fi
kubectl create secret generic cloudsql-instance-credentials --from-file=credentials.json=/tmp/sqlkey.json

if [[ $secrets =~ 'cloudsql-db-credentials' ]]; then
  kubectl delete secret cloudsql-db-credentials
fi
kubectl create secret generic cloudsql-db-credentials --from-literal=database_user=$DATABASE_USER --from-literal=database_password=$DATABASE_PASSWORD

# Apply yaml deployment configurations in the current directory
kubectl apply -f .

# Update an image of a deployed container
kubectl set image deployment/$DEPLOYMENT_NAME $CURRENT_IMAGE=$NEW_IMAGE
