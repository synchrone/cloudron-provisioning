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
  "provider": "ec2",
  "apiServerOrigin": "https://api.cloudron.io",
  "webServerOrigin": "https://cloudron.io",
  "tlsConfig": {
    "provider": "le-prod"
  },
  "dnsConfig": {
    "provider":"route53",
    "accessKeyId":"${aws_iam_access_key.cloudron.id}",
    "secretAccessKey":"${aws_iam_access_key.cloudron.secret}",
    "region":"us-east-1",
    "endpoint":null
  },
  "backupConfig" : {
    "provider":"s3",
    "key":"${coalesce(var.cloudron_restore_key, random_id.backup_key.b64)}",
    "retentionSecs":2592000,
    "bucket":"${aws_s3_bucket.backups.id}",
    "prefix":"",
    "accessKeyId":"${aws_iam_access_key.cloudron.id}",
    "secretAccessKey":"${aws_iam_access_key.cloudron.secret}",
    "region":"${var.region}"
  },
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