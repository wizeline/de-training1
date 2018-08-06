// ---------------------------------
// Definition of variables
# Project information
variable project_name {}

variable "zone" {}
variable "region" {}
variable "location" {}

# Buckets names
variable "staging_prefix" {}
variable "bucket_output_name_prefix" {}
variable "input_bucket_name" {}

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

#User Members
variable "user_members" {
  type = "list"
}

// ---------------------------------
// Configure the Google Cloud provider
provider "google" {
  project = "${var.project_name}"
  region  = "${var.region}"
}

// ---------------------------------  
// Configure resources
// Access to input bucket for each user
resource "google_storage_bucket_iam_member" "input-bucket" {
  bucket     = "${var.input_bucket_name}"
  role       = "roles/storage.objectViewer"
  member     = "user:${element(var.user_members, count.index)}"
  count      = "${var.num_users}"
}


// Bucket for users to put their data/file
resource "google_storage_bucket" "de-bucket-output" {
  project       = "${var.project_name}"
  name          = "${var.bucket_output_name_prefix}-${count.index}"
  location      = "${var.location}"
  force_destroy = "true"
  count         = "${var.num_users}"
}

// Access to users for buckets, the list in environment vars goes from index 0 to n-1 (same as the buckets)
resource "google_storage_bucket_iam_member" "viewer" {
  bucket     = "${var.bucket_output_name_prefix}-${count.index}"
  role       = "roles/storage.objectViewer"
  member     = "user:${element(var.user_members, count.index)}"
  count      = "${var.num_users}"
  depends_on = ["google_storage_bucket.de-bucket-output"]
}

resource "google_storage_bucket_iam_member" "create" {
  bucket     = "${var.bucket_output_name_prefix}-${count.index}"
  role       = "roles/storage.objectCreator"
  member     = "user:${element(var.user_members, count.index)}"
  count      = "${var.num_users}"
  depends_on = ["google_storage_bucket.de-bucket-output"]
}

// Bucket required for the cluster
resource "google_storage_bucket" "de-staging" {
  project       = "${var.project_name}"
  name          = "${var.staging_prefix}-${count.index}"
  location      = "${var.location}"
  force_destroy = "true"
  count         = "${var.num_users}"
}

resource "google_project_iam_member" "add-user-project" {
  project = "${var.project_name}"
  role    = "roles/compute.osLogin"
  member  = "user:${element(var.user_members, count.index)}"
  count   = "${var.num_users}"
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
      script      = "${var.zeppelin_sh_path}"
      timeout_sec = "${var.cluster_init_timeout}"
    }
  }
}
