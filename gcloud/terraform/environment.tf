// ---------------------------------
// Definition of variables
# Project information
variable project_name {}

variable "zone" {}
variable "region" {}
variable "location" {}

# Buckets names
variable "staging_prefix" {}

variable "bucket_input_name" {}
variable "bucket_output_name_prefix" {}

# Cluster information

variable "zeppelin_sh_path" {}
variable "cluster_prefix" {}
variable "machine_type" {}
variable "cluster_master_num_local_ssds" {}
variable "cluster_worker_num_local_ssds" {}
variable "cluster_init_timeout" {}
variable "cluster_master_instances" {}
variable "cluster_worker_instances" {}
variable "cluster_master_boot_disk_size" {}
variable "cluster_worker_boot_disk_size" {}

# Number of users
variable "num_users" {}

// ---------------------------------
// Configure the Google Cloud provider
provider "google" {
  project = "${var.project_name}"
  region  = "${var.region}"
}

// ---------------------------------  
// Configure resources

// Bucket where the zeppelin sh file is going to be copied
resource "google_storage_bucket" "de-training-bucket-input" {
  name          = "${var.bucket_input_name}"
  location      = "${var.location}"
  force_destroy = "true"

  provisioner "local-exec" {
    // This command is run in the local machine, if required in the remote resource
    // change it to remote-exec
    command = "gsutil cp ${var.zeppelin_sh_path} gs://${var.bucket_input_name}/"
  }
}

// Bucket for general purposes (delete if not required)
resource "google_storage_bucket" "de-bucket-output" {
  name          = "${var.bucket_output_name_prefix}-${count.index}"
  location      = "${var.location}"
  force_destroy = "true"
  count         = "${var.num_users}"
}

// Bucket required for the cluster
resource "google_storage_bucket" "de-staging" {
  name          = "${var.staging_prefix}-${count.index}"
  location      = "${var.location}"
  force_destroy = "true"
  count         = "${var.num_users}"
}

// Cluster that is initialized with zeppelin.sh previously copied.
resource "google_dataproc_cluster" "de-training" {
  name       = "${var.cluster_prefix}-${count.index}"
  region     = "${var.region}"
  count      = "${var.num_users}"
  depends_on = ["google_storage_bucket.de-bucket-output"]

  cluster_config {
    // Staging bucket name previously created
    staging_bucket = "${var.staging_prefix}-${count.index}"

    gce_cluster_config {
      zone = "${var.zone}"
    }

    master_config {
      num_instances = "${var.cluster_master_instances}"
      machine_type  = "${var.machine_type}"

      disk_config {
        boot_disk_size_gb = "${var.cluster_master_boot_disk_size}"
        num_local_ssds    = "${var.cluster_master_num_local_ssds}"
      }
    }

    worker_config {
      num_instances = "${var.cluster_worker_instances}"
      machine_type  = "${var.machine_type}"

      disk_config {
        boot_disk_size_gb = "${var.cluster_worker_boot_disk_size}"
        num_local_ssds    = "${var.cluster_worker_num_local_ssds}"
      }
    }

    # You can define multiple initialization_action blocks
    initialization_action {
      // Path to the bucket where the zeppelin.sh was copied
      script      = "gs://${var.bucket_input_name}/zeppelin.sh"
      timeout_sec = "${var.cluster_init_timeout}"
    }
  }
}
