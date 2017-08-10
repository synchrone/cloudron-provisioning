data "template_file" "user_data" {
  template = "${file("cloud-init.yaml")}"

  vars {
    domain = "${var.domain}"
    mail_relay = <<EOF
{
    "provider":"ses-smtp",
    "host":"email-smtp.${var.region}.amazonaws.com",
    "port":"587",
    "tls":true,
    "username":"${aws_iam_access_key.ses_smtp.id}",
    "password":"${aws_iam_access_key.ses_smtp.ses_smtp_password}"
}
EOF
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
    "accessKeyId":null,
    "secretAccessKey":null,
    "region":"us-east-1",
    "endpoint":null
  },
  "backupConfig" : {
    "provider":"s3",
    "key":"",
    "retentionSecs":2592000,
    "bucket":"${aws_s3_bucket.backups.id}",
    "prefix":"",
    "accessKeyId":null,
    "secretAccessKey":null,
    "region":"${var.region}"
  },
  "updateConfig": {
    "prerelease": false
  },
  "fqdn": "${var.domain}",
  "version": "${var.version}",
  "restore": {
      "url": "${var.cloudron_restore_url}",
      "key": "${var.cloudron_restore_key}"
  }
}
EOF
  }
}