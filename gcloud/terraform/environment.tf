// ---------------------------------
// Definition of variables
# Project information
variable project_name {}

variable "zone" {}
variable "region" {}
variable "location" {}

# Buckets names
variable "input_bucket_name" {}

variable "config_bucket_name" {}
variable "staging_bucket_prefix" {}
variable "output_bucket_prefix" {}

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

# Varibles block
variable "students" {
  type = "list"
}

variable "mentors" {
  type = "list"
}

variable "admins" {
  type = "list"
}

variable "testers" {
  type = "list"
}

locals {
  "cluster-users"     = "${distinct(concat(var.students, var.mentors, var.testers))}"
  "num-cluster-users" = "${length(local.cluster-users)}"
  "users-list"        = "${formatlist("user:%s", local.cluster-users)}"
  "admins-list"       = "${formatlist("user:%s", distinct(var.admins))}"
  "num-admins"        = "${length(local.admins-list)}"

  "service-accounts-students" = "${formatlist(
    "serviceAccount:%s",
    google_service_account.student-service-accounts.*.email
  )}"
}

// -----------------------------------
// Configure the Google Cloud provider
provider "google" {
  project = "${var.project_name}"
  region  = "${var.region}"
}

//--------------------------
// Mentor accounts

# Owner role assignment
resource "google_project_iam_binding" "owner-role-members" {
  project = "${var.project_name}"
  role    = "roles/owner"

  members = [
    "${local.admins-list}",
  ]
}

# Storage admin role assignment
resource "google_project_iam_binding" "storage-admin-role-members" {
  project = "${var.project_name}"
  role    = "roles/storage.admin"

  members = [
    "${local.admins-list}",
  ]
}

// -------------------------
// Students Accounts

# Students role
# Allows:
#   * Listing buckets
#   * See vms details
#   * SSH to vms
#   * See dataproc cluster details
#   * See vms and clusters resource consumption
resource "google_project_iam_custom_role" "student-role" {
  role_id     = "StudentRole"
  title       = "Student Project Role"
  description = "Custom project role for the students"

  permissions = [
    "compute.instances.get",
    "compute.instances.list",
    "compute.instances.osLogin",
    "compute.instances.setMetadata",
    "compute.machineTypes.get",
    "compute.machineTypes.list",
    "compute.networks.get",
    "compute.networks.list",
    "compute.projects.get",
    "compute.regions.get",
    "compute.regions.list",
    "compute.zones.get",
    "compute.zones.list",
    "dataproc.clusters.get",
    "dataproc.clusters.list",
    "dataproc.clusters.use",
    "dataproc.jobs.cancel",
    "dataproc.jobs.create",
    "dataproc.jobs.get",
    "dataproc.jobs.list",
    "dataproc.jobs.update",
    "monitoring.timeSeries.list",
    "resourcemanager.projects.get",
    "serviceusage.quotas.get",
    "serviceusage.services.get",
    "serviceusage.services.list",
    "storage.buckets.list",
  ]
}

# Students role assignment
resource "google_project_iam_binding" "student-role-members" {
  project = "${var.project_name}"
  role    = "${google_project_iam_custom_role.student-role.id}"

  members = [
    "${local.users-list}",
  ]
}

# Students service accounts
resource "google_service_account" "student-service-accounts" {
  display_name = "student-${element(local.cluster-users, count.index)}"

  account_id = "student-${substr(
    replace(element(local.cluster-users, count.index), "/@.*|[^A-Za-z0-9]/", ""), 0,
    min(20, length(replace(element(local.cluster-users, count.index), "/@.*|[^A-Za-z0-9]/", "")))
  )}"

  count = "${local.num-cluster-users}"
}

# Student service account role
resource "google_project_iam_custom_role" "student-service-account-role" {
  role_id     = "StudentServiceAccountRole"
  title       = "Student Service Account Role"
  description = "Custom role for the students to run dataproc jobs"

  permissions = [
    "dataproc.agents.create",
    "dataproc.agents.delete",
    "dataproc.agents.get",
    "dataproc.agents.list",
    "dataproc.agents.update",
    "dataproc.tasks.lease",
    "dataproc.tasks.listInvalidatedLeases",
    "dataproc.tasks.reportStatus",
    "logging.logEntries.create",
    "monitoring.metricDescriptors.create",
    "monitoring.metricDescriptors.get",
    "monitoring.metricDescriptors.list",
    "monitoring.monitoredResourceDescriptors.get",
    "monitoring.monitoredResourceDescriptors.list",
    "monitoring.timeSeries.create",
    "storage.buckets.list",
    "storage.buckets.get",
    "storage.objects.list",
    "storage.objects.get",
  ]
}

resource "google_project_iam_binding" "student-service-account-role-members" {
  project = "${var.project_name}"
  role    = "${google_project_iam_custom_role.student-service-account-role.id}"

  members = [
    "${local.service-accounts-students}",
  ]
}

# Student service account role assignment
resource "google_service_account_iam_member" "student-service-account-users" {
  service_account_id = "${element(google_service_account.student-service-accounts.*.id, count.index)}"
  role               = "roles/iam.serviceAccountUser"
  member             = "${element(local.users-list, count.index)}"
  count              = "${local.num-cluster-users}"
}

// -----------------------------------------------------------------------------
// Buckets
# Input bucket
resource "google_storage_bucket" "input-bucket" {
  project  = "${var.project_name}"
  name     = "${var.input_bucket_name}"
  location = "${var.location}"

  lifecycle {
    prevent_destroy = "true"
  }
}

# Configuration bucket
resource "google_storage_bucket" "config-bucket" {
  project  = "${var.project_name}"
  name     = "${var.config_bucket_name}"
  location = "${var.location}"

  lifecycle {
    prevent_destroy = "true"
  }
}

# Bucket for users to put their data/file
resource "google_storage_bucket" "output-buckets" {
  project = "${var.project_name}"

  name = "${var.output_bucket_prefix}-${substr(
    replace(element(local.cluster-users, count.index), "/@.*|[^A-Za-z0-9]/", ""), 0,
    min(20, length(replace(element(local.cluster-users, count.index), "/@.*|[^A-Za-z0-9]/", "")))
  )}"

  location = "${var.location}"
  count    = "${local.num-cluster-users}"

  lifecycle {
    prevent_destroy = "false"
  }
}

# Bucket required for the dataproc cluster
resource "google_storage_bucket" "staging-buckets" {
  project = "${var.project_name}"

  name = "${var.staging_bucket_prefix}-${substr(
    replace(element(local.cluster-users, count.index), "/@.*|[^A-Za-z0-9]/", ""), 0,
    min(20, length(replace(element(local.cluster-users, count.index), "/@.*|[^A-Za-z0-9]/", "")))
  )}"

  location      = "${var.location}"
  count         = "${local.num-cluster-users}"
  force_destroy = "true"
}

// ------------------------
// Bucket level permissions
# Input bucket
resource "google_storage_bucket_iam_binding" "input-bucket-obj-viewers" {
  bucket = "${google_storage_bucket.input-bucket.name}"
  role   = "roles/storage.objectViewer"

  members = [
    "${concat(local.users-list, local.service-accounts-students)}",
  ]
}

# Config bucket
resource "google_storage_bucket_iam_binding" "config-bucket-obj-viewers" {
  bucket = "${google_storage_bucket.config-bucket.name}"
  role   = "roles/storage.objectViewer"

  members = [
    "${local.service-accounts-students}",
  ]
}

# Output buckets
resource "google_storage_bucket_iam_binding" "output-bucket-obj-viewers" {
  bucket = "${element(google_storage_bucket.output-buckets.*.name, count.index)}"
  role   = "roles/storage.objectViewer"

  members = [
    "${element(local.users-list, count.index)}",
    "${element(local.service-accounts-students, count.index)}",
  ]

  count = "${local.num-cluster-users}"
}

resource "google_storage_bucket_iam_binding" "output-bucket-obj-creators" {
  bucket = "${element(google_storage_bucket.output-buckets.*.name, count.index)}"
  role   = "roles/storage.objectCreator"

  members = [
    "${element(local.users-list, count.index)}",
  ]

  count = "${local.num-cluster-users}"
}

resource "google_storage_bucket_iam_binding" "output-bucket-obj-admins" {
  bucket = "${element(google_storage_bucket.output-buckets.*.name, count.index)}"
  role   = "roles/storage.objectAdmin"

  members = [
    "${element(local.service-accounts-students, count.index)}",
  ]

  count = "${local.num-cluster-users}"
}

# Staging buckets
resource "google_storage_bucket_iam_binding" "staging-bucket-obj-viewers" {
  bucket = "${element(google_storage_bucket.staging-buckets.*.name, count.index)}"
  role   = "roles/storage.objectViewer"

  members = [
    "${element(local.users-list, count.index)}",
  ]

  count = "${local.num-cluster-users}"
}

resource "google_storage_bucket_iam_binding" "staging-bucket-obj-creators" {
  bucket = "${element(google_storage_bucket.staging-buckets.*.name, count.index)}"
  role   = "roles/storage.objectCreator"

  members = [
    "${element(local.users-list, count.index)}",
  ]

  count = "${local.num-cluster-users}"
}

resource "google_storage_bucket_iam_binding" "staging-bucket-obj-admins" {
  bucket = "${element(google_storage_bucket.staging-buckets.*.name, count.index)}"
  role   = "roles/storage.objectAdmin"

  members = [
    "${element(local.service-accounts-students, count.index)}",
  ]

  count = "${local.num-cluster-users}"
}

// -----------------------------------------------------------------------------
// Dataproc

// Cluster that is initialized with zeppelin.sh previously copied.
resource "google_dataproc_cluster" "spark-clusters" {
  name = "${var.cluster_prefix}-${substr(
    replace(element(local.cluster-users, count.index), "/@.*|[^A-Za-z0-9]/", ""), 0,
    min(20, length(replace(element(local.cluster-users, count.index), "/@.*|[^A-Za-z0-9]/", "")))
  )}"

  region = "${var.region}"
  count  = "${local.num-cluster-users}"

  depends_on = [
    "google_storage_bucket.config-bucket",
    "google_storage_bucket_iam_binding.config-bucket-obj-viewers",
    "google_project_iam_binding.student-service-account-role-members",
  ]

  cluster_config {
    staging_bucket = "${element(google_storage_bucket.staging-buckets.*.name, count.index)}"

    gce_cluster_config {
      zone            = "${var.zone}"
      service_account = "${element(google_service_account.student-service-accounts.*.email, count.index)}"
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
      /* script      = "${google_storage_bucket.config-bucket.url}/${var.zeppelin_sh_path}" */
      script = "gs://dataproc-initialization-actions/zeppelin/zeppelin.sh"

      timeout_sec = "${var.cluster_init_timeout}"
    }
  }
}
