# Google Cloud + Kubernetes deployment

This docker file aims to help with automated deployment to Kubernetes running on the Google Cloud Platform. The image prepares a container ready to use `gcloud` and `kubectl` command line tools.

## Usage

Using the example script in `examples/deploy.sh`. The environment variables used are completely dependent on what is going on inside the script.
```bash
docker run --rm \
  -v `pwd`/examples/:/examples \
  -e GOOGLE_SERVICE_ACCOUNT= \    # service account ID
  -e GOOGLE_SERVICE_KEY_BLOB= \   # base64 encoded JSON key of the service account
  -e PROJECT_ID= \                # google cloud project id
  -e COMPUTE_ZONE= \              # e.g.: europe-west3-a
  -e CLUSTER_NAME= \              # Name your cluster, e.g.: cluster1
  -e GOOGLE_SQL_KEY_BLOB= \       # base64 encoded JSON key of the service account with SQL API Client role
  -e DATABASE_USER= \             # Credentials required by your app
  -e DATABASE_PASSWORD= \         # Credentials required by your app
  -e DEPLOYMENT_NAME= \           # Name of your Kubernetes deployment config
  -e CONTAINER_NAME= \            # Name of the container in the deployment config
  -e NEW_IMAGE= \                 # New image to use for the specified container
  hutchisont/gcloud-k8s-docker-shipper \
  /examples/deploy.sh
```
### Example deploy scripts

**IMPORTANT**: This script relies on existence of a kubernetes deployment configuration in the current directory.

```bash
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
kubectl set image deployment/$DEPLOYMENT_NAME $CONTAINER_NAME=$NEW_IMAGE

```
