provider "mailgun" {
  api_key = "${var.mailgun_api_key}"
}
resource "random_id" "mailgun_password" {
  keepers = {
    # Generate a new id each time we switch the api key
    value = "${var.mailgun_api_key}"
  }
  byte_length = 12
}
resource "mailgun_domain" "current" {
  count         = "${var.mailgun_api_key != "" ? 1 : 0}"
  name          = "${var.domain}"
  spam_action   = "disabled"
  smtp_password = "${random_id.mailgun_password.b64}"
}

# https://github.com/terraform-providers/terraform-provider-mailgun/issues/1
resource "google_dns_record_set" "mailgun_sending_record0" {
  count   = "${var.mailgun_api_key != "" ? 1 : 0}"
  managed_zone = "${google_dns_managed_zone.cloudron_zone.name}"
  name    = "${mailgun_domain.current.sending_records.0.name}"
  type    = "${mailgun_domain.current.sending_records.0.record_type}"
  rrdatas = ["${mailgun_domain.current.sending_records.0.value}"]
  ttl     = "600"
}
resource "google_dns_record_set" "mailgun_sending_record1" {
  count   = "${var.mailgun_api_key != "" ? 1 : 0}"
  managed_zone = "${google_dns_managed_zone.cloudron_zone.name}"
  name    = "${mailgun_domain.current.sending_records.1.name}"
  type    = "${mailgun_domain.current.sending_records.1.record_type}"
  rrdatas = ["${mailgun_domain.current.sending_records.1.value}"]
  ttl     = "600"
}

# ==== The following is a hack to enable optional Mailgun domain creation
# thanks https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
data "template_file" "mail_relay_present" {
  count = "${var.mailgun_api_key != "" ? 1 : 0}"
  template = <<EOF
{
    "provider":"mailgun-smtp",
    "host":"smtp.mailgun.org",
    "port":"587",
    "tls":true,
    "username":"${mailgun_domain.current.smtp_login}",
    "password":"${mailgun_domain.current.smtp_password}"
}
EOF
}
data "template_file" "mail_relay_absent" {
  count = "${var.mailgun_api_key == "" ? 1 : 0}" # the stub is active when there is no mailgun api key defined
  template = "{}"
}

data "template_file" "mail_relay_config" {
  template = "${element(concat(data.template_file.mail_relay_present.*.rendered, data.template_file.mail_relay_absent.*.rendered), 0)}"
}