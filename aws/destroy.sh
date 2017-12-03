#!/usr/bin/env bash
#this does not actually work. Waiting for https://github.com/hashicorp/terraform/issues/2182
#terraform destroy -target !aws_s3_bucket.backups -target !aws_route53_zone.cloudron_zone $*
terraform destroy $(for r in `terraform state list | fgrep -v aws_s3_bucket.backups | fgrep -v aws_route53_zone.cloudron_zone` ; do printf "-target ${r} "; done) $*

echo "Note: AWS Route53 Zone was not destroyed! Go to https://console.aws.amazon.com/route53/home#hosted-zones: and do it manually."
echo "Note: AWS S3 Bucket was not destroyed! Go to https://s3.console.aws.amazon.com/s3/home and do it manually"
