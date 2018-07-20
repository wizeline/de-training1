#! /bin/bash
# Lets authenticate first to google cloud
gcloud auth login
# [CLUSTER_NAME]-m is cluster name value assigned to you, for example, if your student number is 1
# the command will have the cluster number 0, if its 2, it will have 1, and so on.
# Suggested [PORT_VALUE] port for tunel is 1080 but you can chose any port you want
# gcloud compute ssh [CLUSTER_NAME]-m -- -D [PORT_VALUE] -N -n
gcloud compute ssh --ssh-flag="-D 1100" --ssh-flag="-N" --ssh-flag="-n" de-training-0-m