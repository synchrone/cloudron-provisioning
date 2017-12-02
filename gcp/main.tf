variable "domain" {
  type = "string"
  description = "The domain where to install Cloudron. You need to be able to delegate it to DNS servers which this scenario will provide at the end."
}
variable "google_credentials_file" {
  type = "string"
  default = "" # defaults to empty, giving up precedence to google_credentials
  description = "(alternatively) Your Service Account Key (JSON) file name"
}
variable "google_credentials" {
  type = "string"
  default = "" # defaults to empty giving up precedence to GOOGLE_APPLICATION_CREDENTIALS is picked up
  description = "Your Service Account Key (JSON) file contents"
}
variable "google_project" {
  type = "string"
  default = "" # defaults to empty, because some have GOOGLE_APPLICATION_CREDENTIALS is picked up
  description = "The name of your project"
}
variable "mailgun_api_key" {
  type = "string"
  description = "(optional) Mailgun Secret API Key. Get one from https://app.mailgun.com/app/dashboard (box on the right)"
  default = ""
}
variable "instance_type" {
  type = "string"
  default = "g1-small"
  description = "(optional) The instance type. Choose one at https://cloud.google.com/compute/docs/machine-types#predefined_machine_types or use 'custom-CPUS-MEMORY', e.g custom-4-16"
}
variable "disk_size" {
  type = "string"
  default = "22"
  description = "(optional) Disk size. Defaults to 22GB"
}
variable "disk_type" {
  type = "string"
  default = "pd-ssd"
  description = "(optional) Disk type. pd-ssd or pd-standard for magnetic"
}
variable "public_key" {
  type = "string"
  default = ""
  description = "SSH public key to assign"
}
variable "region" {
  type = "string"
  default = "us-central1"
  description = "The server region. Choose from https://cloud.google.com/compute/docs/regions-zones/regions-zones#available"
}
variable "backup_region" {
  type = "string"
  default = "us-east1"
  description = "The backups (GCS) region. Choose one different from 'region' variable value. Multiregion locations are not supported"
}
variable "version" {
  type = "string"
  default = "1.8.2"
}
variable "cloudron_restore_url" {
  type = "string"
  default = ""
  description = "(optional) Restore from a Backup (URL, must be publicly-accessible)"
}
variable "cloudron_restore_key" {
  type = "string"
  default = ""
  description = "(optional) Backup encryption key (as shown at the end of this scenario or set in cloudron manually)"
}
variable "cloudron_source_url" {
  type = "string"
  default = ""
  description = "(optional) Install cloudron from this distribution URL"
}
# ===================================

locals {
  google_credentials = "${var.google_credentials_file != "" ? file(var.google_credentials_file) : var.google_credentials}"
}
provider "google" {
  credentials = "${local.google_credentials}"
  project     = "${var.google_project}"
  region      = "${var.region}"
}

resource "google_compute_instance" "cloudron" {
  name = "cloudron"
  tags = [ "cloudron" ] //attches firewall rules
  machine_type = "${var.instance_type}"
  zone = "${var.region}-a"

  network_interface {
    network = "default"
    access_config {}
  }

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts"
      size = "${var.disk_size}"
      type = "${var.disk_type}"
    }
  }

  service_account {
    email = "${google_service_account.cloudron.email}"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata {
    sshKeys = "root:${var.public_key}\nyellowtent:${var.public_key}"
  }

  metadata_startup_script = "${data.template_file.user_data.rendered}"
}


resource "google_storage_bucket" "backups" {
  name     = "${var.google_project}-backups"
  location = "${var.region}"
  storage_class = "REGIONAL"
  location = "${var.backup_region}"

  lifecycle {
    prevent_destroy = true
  }
}
resource "google_storage_bucket_acl" "backups" {
  bucket = "${google_storage_bucket.backups.name}"
  predefined_acl = "publicRead"
}

output "cloudron_installation_complete" {
  value = <<EOF
==============================================================
Thank you for installing Cloudron!

The cloud resources have been successfully created, but some processes are still active in background.

Make sure you delegate your domain '${var.domain}' to these name servers (NS):
${google_dns_managed_zone.cloudron_zone.name_servers.0}
${google_dns_managed_zone.cloudron_zone.name_servers.1}
${google_dns_managed_zone.cloudron_zone.name_servers.2}
${google_dns_managed_zone.cloudron_zone.name_servers.3}

After that please wait ~15 minutes and try navigating your browser to https://my.${var.domain} to finish the installation.

In the meantime, you should subscribe to alarms, to be notified if something happens on your server:
#TODO: Stackdriver

Backups will be stored under https://console.cloud.google.com/storage/browser/${google_storage_bucket.backups.name}
Backup Encryption Key: ${coalesce(var.cloudron_restore_key, random_id.backup_key.b64)}

Enjoy self-hosting!
EOF
}
