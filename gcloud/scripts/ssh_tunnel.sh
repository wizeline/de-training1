#! /bin/bash

# Variables 
    PROJECT_NAME=data-castle-bravo
    ZONE=us-central1-a
    # Suggested [PORT_VALUE] port for tunel is 1100 but you can chose any port you want
    SSH_PORT=1100
    # [CLUSTER_NAME]-m is cluster name value assigned to you, for example, if your user number is 0
    CLUSTER_NAME=de-training-0-m

# SSH Command
gcloud compute --project "$PROJECT_NAME" ssh --zone "$ZONE" --ssh-flag="-D $SSH_PORT" "$CLUSTER_NAME"
