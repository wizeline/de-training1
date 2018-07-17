#! /bin/bash
cd ../terraform
terraform init
terraform apply -var-file=environment.tfvars