// ---------------------------------
// Definition of variables
variable project_name {}

variable "staging_prefix" {}

variable "bucket_prefix_a" {}

variable "bucket_prefix_b" {}

variable "zeppelin_sh_path" {}

variable "cluster_prefix" {}

variable "region" {}

variable "location" {}

variable "machine_type" {}

variable "zone" {}

variable "num_alumns" {}

// ---------------------------------
// Configure the Google Cloud provider
provider "google" {
  project = "${var.project_name}"
  region  = "${var.region}"
}

// ---------------------------------  
// Configure resources

// Bucket where the zeppelin sh file is going to be copied
resource "google_storage_bucket" "de-bucket-a" {
  name          = "${var.bucket_prefix_a}-${count.index}"
  location      = "${var.location}"
  force_destroy = "true"
  count         = "${var.num_alumns}"

  provisioner "local-exec" {
    // This command is run in the local machine, if required in the remote resource
    // change it to remote-exec
    command = "gsutil cp ${var.zeppelin_sh_path} gs://${var.bucket_prefix_a}-${count.index}/"
  }
}

// Bucket for general purposes (delete if not required)
resource "google_storage_bucket" "de-bucket-b" {
  name          = "${var.bucket_prefix_b}-${count.index}"
  location      = "${var.location}"
  force_destroy = "true"
  count         = "${var.num_alumns}"
}

// Bucket required for the cluster
resource "google_storage_bucket" "de-staging" {
  name          = "${var.staging_prefix}-${count.index}"
  location      = "${var.location}"
  force_destroy = "true"
  count         = "${var.num_alumns}"
}

// Cluster that is initialized with zeppelin.sh previously copied.
resource "google_dataproc_cluster" "de-training" {
  name   = "${var.cluster_prefix}-${count.index}"
  region = "${var.region}"
  count  = "${var.num_alumns}"

  cluster_config {
    // Staging bucket name previously created
    staging_bucket = "${var.staging_prefix}-${count.index}"

    gce_cluster_config {
      zone = "${var.zone}"
    }

    master_config {
      num_instances = 1
      machine_type  = "${var.machine_type}"

      disk_config {
        boot_disk_size_gb = 15
        num_local_ssds    = 0
      }
    }

    worker_config {
      num_instances = 2
      machine_type  = "${var.machine_type}"

      disk_config {
        boot_disk_size_gb = 10
        num_local_ssds    = 0
      }
    }

    preemptible_worker_config {
      num_instances = 0
    }

    # You can define multiple initialization_action blocks
    initialization_action {
      // Path to the bucket where the zeppelin.sh was copied
      script      = "gs://${var.bucket_prefix_a}-${count.index}/zeppelin.sh"
      timeout_sec = 500
    }
  }
}
