# Project configuration
project_name = "data-castle-bravo"
region = "us-central1"
zone = "us-central1-a"
location = "US"

# Buckets names
config_bucket_name = "de-training-config"
input_bucket_name = "de-training-input"
staging_bucket_prefix = "de-training-staging"
output_bucket_prefix = "de-training-output"

# Dataproc clusters configuration parameters
zeppelin_sh_path = "zeppelin/zeppelin.sh"

cluster_prefix = "de-training"
machine_type = "n1-standard-2"
cluster_master_num_local_ssds = 0
cluster_worker_num_local_ssds = 0
cluster_init_timeout = 500
cluster_master_instances = 1
cluster_worker_instances = 2
cluster_master_boot_disk_size = 15
cluster_worker_boot_disk_size = 10

# User groups
# They will get Owner/Admin permissions on the project
admins = [
  "abraham.alcantara@wizeline.com",
  "ana.gabriela@wizeline.com",
  "carlos.zubieta@wizeline.com",
  "donovan@wizeline.com",
  "edgar.arenas@wizeline.com",
  "luis.dealba@wizeline.com",
  "matthew.ropp@wizeline.com",
  "ricardo.magana@wizeline.com",
  "rodrigo.chaparro@wizeline.com",
  "said.montiel@wizeline.com",
  "willebaldo@wizeline.com",
]

# All the people below will get their own clusters
# and in the future the clusters will be provisioned
# independently for each group
mentors = [
  "abraham.alcantara@wizeline.com",
  "ana.gabriela@wizeline.com",
  "carlos.zubieta@wizeline.com",
  "edgar.arenas@wizeline.com",
  "ricardo.magana@wizeline.com",
  "rodrigo.chaparro@wizeline.com",
  "said.montiel@wizeline.com",
  "willebaldo@wizeline.com",
]

testers = [
  "matthew.ropp@wizeline.com",
]

students = [
  "alberto.leal@wizeline.com",
  "alfre2x@gmail.com",
  "armando.diaz.glez@gmail.com",
  "aztre@yellowme.mx",
  "barpan@gmail.com",
  "brunoarh@gmail.com",
  "ceoe1996@gmail.com",
  "ces.nietor@gmail.com",
  "chuygc@gmail.com",
  "diego@tr3sco.com",
  "eejl1992@gmail.com",
  "efren.ce@gmail.com",
  "fherdelpino@gmail.com",
  "francisco.gonzalez.vazquez@gmail.com",
  "gmisaenz@gmail.com",
  "ivo@wizeline.com",
  "jalil@relativity6.com",
  "javier.guajardo@wizeline.com",
  "javiero.barbosa@gmail.com",
  "joaquincasanova001@gmail.com",
  "jorge.vera.colima@gmail.com",
  "jorge@yellowme.mx",
  "martinez.zapata.carlos@gmail.com",
  "migueltlapa@gmail.com",
  "nunez.gonzalez.jl@gmail.com",
  "petergtam@gmail.com",
  "rhdzmota@gmail.com",
  "rjlopez.android@gmail.com",
  "saul.flores@wizeline.com",
  "sjcmexr@gmail.com",
  "soysamygp@gmail.com",
  "topifloresl@gmail.com",
  "leobiwankenobi@gmail.com",
  "tania.mendoza@wizeline.com",
]
