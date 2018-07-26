#! /bin/bash
# Put the path to the key file generated
PATH_TO_JSON_KEY=~/gcp_key.json
export GOOGLE_APPLICATION_CREDENTIALS=$PATH_TO_JSON_KEY

cd ../terraform
terraform destroy -var-file=environment.tfvars