#!/usr/bin/env bash
#this does not actually work. Waiting for https://github.com/hashicorp/terraform/issues/2182
#terraform destroy -target !google_storage_bucket.backups -target !google_dns_managed_zone.cloudron_zone $*
terraform destroy $(for r in `terraform state list | fgrep -v google_storage_bucket.backups | fgrep -v google_dns_managed_zone.cloudron_zone` ; do printf "-target ${r} "; done) $*

echo "Note: Google Cloud DNS Zone was not destroyed! Go to https://console.cloud.google.com/net-services/dns/zones and do it manually."
echo "Note: Google CLoud Storage Bucket was not destroyed! Go to https://console.cloud.google.com/storage/browser and do it manually"
