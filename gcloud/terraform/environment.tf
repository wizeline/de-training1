// ---------------------------------
// Definition of variables
variable project_name {}

variable "staging_bucket" {}

variable "bucket_01" {}

variable "bucket_02" {}

variable "zeppelin_sh_path" {}

variable "cluster_name" {}

variable "region" {}

variable "location" {}

variable "machine_type" {}

variable "zone" {}

// ---------------------------------
// Configure the Google Cloud provider
provider "google" {
  project = "${var.project_name}"
  region  = "${var.region}"
}

// ---------------------------------  
// Configure resources

// Bucket where the zeppelin sh file is going to be copied
resource "google_storage_bucket" "de-bucket01" {
  name          = "${var.bucket_01}"
  location      = "${var.location}"
  force_destroy = "true"

  provisioner "local-exec" {
    // This command is run in the local machine, if required in the remote resource
    // change it to remote-exec
    command = "gsutil cp ${var.zeppelin_sh_path} gs://${var.bucket_01}/"
  }
}

// Bucket for general purposes (delete if not required)
resource "google_storage_bucket" "de-bucket02" {
  name          = "${var.bucket_02}"
  location      = "${var.location}"
  force_destroy = "true"
}

// Bucket required for the cluster
resource "google_storage_bucket" "de-staging" {
  name          = "${var.staging_bucket}"
  location      = "${var.location}"
  force_destroy = "true"
}

// Cluster that is initialized with zeppelin.sh previously copied.
resource "google_dataproc_cluster" "de-training" {
  name   = "${var.cluster_name}"
  region = "${var.region}"

  // Here is the name of the bucket where the zeppelin sh is copied
  // terraform does not accept interpolation in depends and naming
  depends_on = ["google_storage_bucket.de-bucket01"]

  cluster_config {
    // Staging bucket name previously created
    staging_bucket = "${var.staging_bucket}"

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
      script      = "gs://${var.bucket_01}/zeppelin.sh"
      timeout_sec = 500
    }
  }
}
