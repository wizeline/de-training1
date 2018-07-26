#! /bin/bash
# The services account name is the one that exists in GCP, if no account name exists, then uncomment line 12 and 13 in order to create one
SERVICE_ACCOUNT_NAME="training"
# Project active
PROJECT_ID="data-castle-bravo"
# Roles for the new service account
ROLES="roles/editor"
# This path is where the Key of the service account is stored, if no service account exists yet, it will create one in the path specified
PATH_TO_JSON_KEY=~/gcp_key.json

#First, if a service account does not exists,  we need to create the service account, for that uncomment the following command
#gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME --display-name $SERVICE_ACCOUNT_NAME
#gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com --role $ROLES

#Then we need to get the key json file from the service account if not exists
if ! [ -f $PATH_TO_JSON_KEY ]
then
    gcloud iam service-accounts keys create $PATH_TO_JSON_KEY --iam-account $SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com
fi

#Then we export the GOOGLE_APPLICATION_CREDENTIALS with the path of the service account
export GOOGLE_APPLICATION_CREDENTIALS=$PATH_TO_JSON_KEY

# Finally we run the terraform file
cd ../terraform
terraform init
terraform apply -var-file=environment.tfvars