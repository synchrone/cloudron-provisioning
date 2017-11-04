resource "random_id" "backup_key" {
  keepers = {
    # Generate a new id each time we switch domain
    value = "${var.domain}"
  }
  byte_length = 12
}

data "template_file" "user_data" {
  template = "${file("cloud-init.yaml")}"

  vars {
    domain = "${var.domain}"
    cloudron_source_url = "${var.cloudron_source_url}"
    mail_relay = "${data.template_file.mail_relay_config.rendered}"
    cloudronData = <<EOF
{
  "boxVersionsUrl": "https://s3.amazonaws.com/prod-cloudron-releases/versions.json",
  "provider": "generic",
  "apiServerOrigin": "https://api.cloudron.io",
  "webServerOrigin": "https://cloudron.io",
  "tlsConfig": {
    "provider": "le-prod"
  },
  "dnsConfig": {
    "provider":"gcdns",
    "projectId": "${var.google_project}"
  },
  "backupConfig" : {
    "provider":"gcs",
    "format": "tgz",
    "key":"${coalesce(var.cloudron_restore_key, random_id.backup_key.b64)}",
    "retentionSecs":2592000,
    "bucket":"${google_storage_bucket.backups.name}",
    "prefix":""
  },
  "mailRelay": ${data.template_file.mail_relay_config.rendered},
  "updateConfig": {
    "prerelease": false
  },
  "fqdn": "${var.domain}",
  "zoneName": "${var.domain}",
  "version": "${var.version}",
  "restore": {
      "url": "${var.cloudron_restore_url}",
      "key": "${coalesce(var.cloudron_restore_key, random_id.backup_key.b64)}"
  }
}
EOF
  }
}

