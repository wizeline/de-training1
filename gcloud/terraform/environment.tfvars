# Project information

project_name = "data-castle-bravo"

region = "us-central1"

zone = "us-central1-a"

location = "US"

# Buckets names

staging_prefix = "de-training-staging"

bucket_input_name = "de-training-bucket-input"

bucket_output_name_prefix = "de-training-output-bucket-"

#Cluster information

zeppelin_sh_path = "../zeppelin.sh"

cluster_prefix = "de-training"

machine_type = "n1-standard-1"

cluster_master_num_local_ssds = 0

cluster_worker_num_local_ssds = 0

cluster_init_timeout = 500

cluster_master_instances = 1

cluster_worker_instances = 2

cluster_master_boot_disk_size = 15

cluster_worker_boot_disk_size = 10

# Number of users
num_users = 2
