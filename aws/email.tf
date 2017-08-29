//resource "aws_ses_domain_identity" "ses_id" {
//  domain = "${var.domain}"
//}
//resource "aws_route53_record" "example_amazonses_verification_record" {
//  zone_id = "${aws_route53_zone.cloudron_zone.zone_id}"
//  name    = "_amazonses.${var.domain}"
//  type    = "TXT"
//  ttl     = "600"
//  records = ["${aws_ses_domain_identity.ses_id.verification_token}"]
//}
//
//resource "aws_iam_user" "ses_smtp" {
//  name = "cloudron_smtp"
//}
//resource "aws_iam_access_key" "ses_smtp" {
//  user = "${aws_iam_user.ses_smtp.name}"
//}
//resource "aws_iam_user_policy" "ses_smtp" {
//  name = "ses_smtp"
//  user = "${aws_iam_user.ses_smtp.name}"
//
//  policy = <<EOF
//{
//    "Version": "2012-10-17",
//    "Statement": [
//     {
//       "Effect": "Allow",
//       "Action": ["ses:SendEmail", "ses:SendRawEmail"],
//       "Resource":"*",
//           "Condition": {
//             "ForAllValues:StringLike": {
//               "ses:FromAddress": ["*@${var.domain}"]
//             }
//         }
//       }
//    ]
// }
//EOF
//}

#========================================== Mailgun
provider "mailgun" {
  api_key = "${var.mailgun_api_key}"
}
resource "random_id" "mailgun_password" {
  keepers = {
    # Generate a new id each time we switch domain
    value = "${var.mailgun_api_key}"
  }
  byte_length = 12
}
resource "mailgun_domain" "current" {
  name          = "${var.domain}"
  spam_action   = "disabled"
  smtp_password = "${random_id.mailgun_password.b64}"
}

# https://github.com/terraform-providers/terraform-provider-mailgun/issues/1
resource "aws_route53_record" "mailgun_sending_record0" {
  zone_id = "${aws_route53_zone.cloudron_zone.zone_id}"
  name    = "${mailgun_domain.current.sending_records.0.name}"
  type    = "${mailgun_domain.current.sending_records.0.record_type}"
  records = ["${mailgun_domain.current.sending_records.0.value}"]
  ttl     = "600"
}
resource "aws_route53_record" "mailgun_sending_record1" {
  zone_id = "${aws_route53_zone.cloudron_zone.zone_id}"
  name    = "${mailgun_domain.current.sending_records.1.name}"
  type    = "${mailgun_domain.current.sending_records.1.record_type}"
  records = ["${mailgun_domain.current.sending_records.1.value}"]
  ttl     = "600"
}
