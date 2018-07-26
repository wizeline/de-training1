#! /bin/bash
# The services account name is the one that was specified in deploy.sh
SERVICE_ACCOUNT_NAME="test-training"
# Put the path to the key file generated
PATH_TO_JSON_KEY=~/"$SERVICE_ACCOUNT_NAME"_gcp_key.json
export GOOGLE_APPLICATION_CREDENTIALS=$PATH_TO_JSON_KEY

cd ../terraform
terraform destroy -var-file=environment.tfvars