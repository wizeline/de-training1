# GCP enviroment creation

## Install

To create the GCP environment first needs to update **environment.tfvars** file with the desired values, then run this commands in your terminal:

```bash
terraform apply -var-file=environment.tfvars
```

After it finished the creation of the environment, run the following commands in a terminal

```bash
gcloud compute ssh CLUSTER_NAME-m
gcloud compute ssh --ssh-flag="-D PORT_VALUE" --ssh-flag="-N" --ssh-flag="-n" CLUSTER_NAME-m
```

Were **CLUSTER_NAME** is the name defined in **environment.tfvars** file and **PORT_VALUE** is any port desired for SSH tunneling.

## Running

After running the commands, open a browser and set the proxy to **SOCKS** with localhost and port value defined.

To run zeppeling just open in yout browser to **<http://localhost:8080/>**

## Delete created environment

After completing the training or usage of the environment, the environment needs to be deleted to avoid billing of the resources. To do that run the following command

```bash
terraform destroy -var-file=environment.tfvars
```

Remember to remove the **SOCKS** proxy property from your browser after finishing.