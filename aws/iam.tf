resource "aws_iam_instance_profile" "cloudron_iprofile" {
  name  = "cloudron_instance"
  role = "${aws_iam_role.cloudron_instance.name}"
}

resource "aws_iam_role" "cloudron_instance" {
  name = "cloudron_instance"
  path = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
resource "aws_iam_role_policy" "cloudron_instance_policy" {
  name = "cloudron_instance"
  role = "${aws_iam_role.cloudron_instance.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.backups.id}",
                "arn:aws:s3:::${aws_s3_bucket.backups.id}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "route53:*",
            "Resource": [
                "arn:aws:route53:::hostedzone/${aws_route53_zone.cloudron_zone.id}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:GetChange"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}