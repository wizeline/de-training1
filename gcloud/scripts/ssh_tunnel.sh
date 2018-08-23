#! /bin/bash
echo "Type the port to be used in the ssh tunel, recommended port is 1100."
read SSH_PORT
echo
echo "Type the user id assigned to you. (ex. 0, 1, 2, 3...)"
read CLUSTER_ID
echo
# Variables
PROJECT_NAME="data-castle-bravo"
ZONE="us-central1-a"

# The prefix of the cluster name is what the environmnet.tfvars has assigned as prefix,
# if that changes this needs to be updated. Also it works with the master node.
CLUSTER_NAME=de-training-$CLUSTER_ID-m

# SSH Command
gcloud compute --project "$PROJECT_NAME" ssh --zone "$ZONE" --ssh-flag="-D $SSH_PORT" "$CLUSTER_NAME"
