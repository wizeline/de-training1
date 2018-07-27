#! /bin/bash
# The services account name is the one that was specified in deploy.sh
echo "Type the service account name specified in the deploy.sh script.
It must match in order to delete what terraform created using that service account name."
echo
read SERVICE_ACCOUNT_NAME
# Put the path to the key file generated
PATH_TO_JSON_KEY=~/"$SERVICE_ACCOUNT_NAME"_gcp_key.json
export GOOGLE_APPLICATION_CREDENTIALS=$PATH_TO_JSON_KEY

cd ../terraform
terraform destroy -var-file=environment.tfvars