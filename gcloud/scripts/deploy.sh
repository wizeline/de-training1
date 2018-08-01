#! /bin/bash
# The services account name is the one that exists in GCP, if not exists, it will show an error that the account exists, but there is no issue with that
echo "Type the service account name to be used for the creation of the resources. 
The resources will be created using this service account."
echo
read SERVICE_ACCOUNT_NAME
echo
# Project active
PROJECT_ID="data-castle-bravo"
# This path is where the Key of the service account is stored, if no service account exists yet, it will create one in the path specified
PATH_TO_JSON_KEY=~/"$SERVICE_ACCOUNT_NAME"_gcp_key.json

#First, if a service account does not exists,  we need to create the service account, for that uncomment the following command
accounts=$(gcloud iam service-accounts list)
if [[ $accounts = *"$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"* ]];
then
    echo "Account already exists, skipping creation of service account."
else
    gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME --display-name $SERVICE_ACCOUNT_NAME
    gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com --role roles/storage.admin
fi

#Then we need to get the key json file from the service account if not exists
if ! [ -f $PATH_TO_JSON_KEY ]
then
    gcloud iam service-accounts keys create $PATH_TO_JSON_KEY --iam-account $SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com
else
    echo "Key json file already exists, if want to generate again, delete $PATH_TO_JSON_KEY"
fi

#Then we export the GOOGLE_APPLICATION_CREDENTIALS with the path of the service account
export GOOGLE_APPLICATION_CREDENTIALS=$PATH_TO_JSON_KEY

# Finally we run the terraform file
cd ../terraform
terraform init
terraform apply -var-file=environment.tfvars