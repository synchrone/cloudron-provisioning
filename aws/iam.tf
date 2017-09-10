resource "aws_iam_user" "cloudron" {
  name = "cloudron"
  path = "/"
}
resource "aws_iam_access_key" "cloudron" {
  user    = "${aws_iam_user.cloudron.name}"
}
resource "aws_iam_user_policy" "cloudron" {
  name = "cloudron"
  user = "${aws_iam_user.cloudron.name}"
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
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "ec2:DescribeTags"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}
