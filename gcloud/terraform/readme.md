# GCP enviroment creation

---

## Pre-requisites

* Latest Google Cloud SDK
* Latest Terraform version

### GCP SDK

Need to have Google Cloud Platform SDK installed. The following link has the instructions to install the SDK in Mac, Windows, Linux, etc.

`https://cloud.google.com/sdk/docs/`

### Terraform

To download Terraform and install it, you can use either homewbrew in Mac or download the package from the offical page.

The official page url is:

`https://www.terraform.io/intro/getting-started/install.html`

The brew formula url is:

`http://brewformulas.org/Terraform`

---

## Install

### Executing Terraform script

To create the GCP environment first needs to update **environment.tfvars** file with the desired values (number of alumns, naming of buckets, etc.), then go to folder `gcloud/scripts` and run the `deploy.sh` script.

`./deploy.sh`

After run it will prompt the infrastructure that terraform will create, type "yes" and hit enter. The creation process shall start.

### Creating SSH tunel and running Zeppelin

After it finished the creation of the environment, go, in a new terminal, to `gcloud/scripts` folder and run the script `ssh_tunnel.sh`

`./ssh_tunnel.sh`

This will create the ssh tunnel, the terminal will hang in this process until the user terminates it.

In a new terminal, go to `gcloud/scripts` folder and run the script `start.sh`

`./start.sh`

This will opent a Chrome browser with SOCKS proxy enabled.

---

## Delete created environment

After completing the training or usage of the environment, the environment needs to be deleted to avoid billing of the resources. To do that go to `gcloud/scripts` folder and run the `delete.sh` script

`./delete.sh`

It will prompt to type "yes" if you want to delete the resources created.