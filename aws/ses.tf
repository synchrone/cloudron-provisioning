resource "aws_ses_domain_identity" "ses_id" {
  domain = "${var.domain}"
}
resource "aws_route53_record" "example_amazonses_verification_record" {
  zone_id = "${aws_route53_zone.cloudron_zone.zone_id}"
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = "600"
  records = ["${aws_ses_domain_identity.ses_id.verification_token}"]
}

resource "aws_iam_user" "ses_smtp" {
  name = "cloudron_smtp"
}
resource "aws_iam_access_key" "ses_smtp" {
  user = "${aws_iam_user.ses_smtp.name}"
}
resource "aws_iam_user_policy" "ses_smtp" {
  name = "ses_smtp"
  user = "${aws_iam_user.ses_smtp.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
     {
       "Effect": "Allow",
       "Action": ["ses:SendEmail", "ses:SendRawEmail"],
       "Resource":"*",
           "Condition": {
             "ForAllValues:StringLike": {
               "ses:FromAddress": ["*@${var.domain}"]
             }
         }
       }
    ]
 }
EOF
}
