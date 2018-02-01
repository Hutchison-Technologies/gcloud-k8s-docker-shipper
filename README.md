# Google Cloud + Kuberentes deployment

This docker file aims to help with automated deployment to Kuberentes running on the Google Cloud Platform. The image prepares a container ready to use `gcloud` and `kubectl` command line tools.

## Usage

Using the example script in `examples/deploy.sh`. The environment variables used are completely dependent on what is going on inside the script.
```bash
docker run --rm hutchisont/gcloud-k8s-docker-shipper \
  -v `pwd`/examples/:/examples \
  -e GOOGLE_SERVICE_ACCOUNT=    # service account ID
  -e GOOGLE_SERVICE_KEY_BLOB=   # base64 encoded JSON key of the service account
  -e PROJECT_ID=                # google cloud project id
  -e COMPUTE_ZONE=              # e.g.: europe-west3-a
  -e CLUSTER_NAME=              # Name your cluster, e.g.: cluster1
  -e GOOGLE_SQL_KEY_BLOB=       # base64 encoded JSON key of the service account with SQL API Client role
  -e DATABASE_USER=             # Credentials required by your app
  -e DATABASE_PASSWORD=         # Credentials required by your app
  -e DEPLOYMENT_NAME=           # Name of your Kuberentes deployment config
  -e CONTAINER_NAME=            # Name of the container in the deployment config
  -e NEW_IMAGE=                 # New image to use for the specified container
```
