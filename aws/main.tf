variable "domain" {
  type = "string"
  description = "The domain where to install Cloudron. You need to be able to delegate it to DNS servers which this scenario will provide at the end."
}
variable "aws_access_key" {
  type = "string"
  default = "" # defaults to empty, because some have ~/.aws/credentials in place, which is picked up by Terraform
  description = "AWS Secret Key Id. Get it from https://console.aws.amazon.com/iam/home?region=eu-west-1#/security_credential"
}
variable "aws_secret_key" {
  type = "string"
  default = ""
  description = "AWS Secret Key. See above"
}
variable "mailgun_api_key" {
  type = "string"
  description = "(optional) Mailgun Secret API Key. Get one from https://app.mailgun.com/app/dashboard (box on the right)"
  default = ""
}
variable "instance_type" {
  type = "string"
  default = "t2.micro"
  description = "(optional) The instance type. Choose one at https://aws.amazon.com/ec2/instance-types/"
}
variable "disk_size" {
  type = "string"
  default = "22"
  description = "(optional) Disk size. Defaults to 22GB"
}
variable "disk_type" {
  type = "string"
  default = "standard"
  description = "Can be 'standard', 'gp2', or 'io1'"
}
variable "ec2_public_key_name" {
  type = "string"
  description = "(optional) AWS Public key to allow you to ssh. Create one at https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#KeyPairs:sort=keyName"
  default = ""
}
variable "r53_delegation_set" {
  type = "string"
  default = ""
  description = "(optional) This is useful to avoid having a new NS-records set every time you delete/create this stack, when debugging"
}
variable "region" {
  type = "string"
  default = "eu-west-1"
  description = "The server location. Choose from http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions"
}
variable "backup_region" {
  type = "string"
  default = "eu-west-2"
  description = "The backups (S3) region. Choose one different from 'region' variable value"
}
variable "version" {
  type = "string"
  default = "1.7.6"
}
variable "cloudron_restore_url" {
  type = "string"
  default = ""
  description = "(optional) Restore from a Backup (URL, must be publicly-accessible)"
}
variable "cloudron_restore_key" {
  type = "string"
  default = ""
  description = "(optional) Backup encryption key (as shown at the end of this scenario or set in cloudron manually)"
}
variable "cloudron_source_url" {
  type = "string"
  default = ""
  description = "(optional) Install cloudron from this distribution URL"
}
# ===================================

provider "aws" {
  region     = "${var.region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}
data "aws_caller_identity" "current" {}

variable "images" {
  type = "map"
  default = { #from http://cloud-images.ubuntu.com/locator/ec2/
// Instance-store images here
    ap-northeast-1 = "ami-6a89290c" # 	xenial	16.04 LTS	amd64	hvm:instance-store	20171026.1			hvm
    ap-northeast-2 = "ami-b21fbadc" # 	xenial	16.04 LTS	amd64	hvm:instance-store	20171026.1			hvm
    ap-south-1 = "ami-e409448b" # 	xenial	16.04 LTS	amd64	hvm:instance-store	20171026.1			hvm
    ap-southeast-1 = "ami-14abeb77" # 	xenial	16.04 LTS	amd64	hvm:instance-store	20171026.1			hvm
    ap-southeast-2 = "ami-9ac32cf8" # 	xenial	16.04 LTS	amd64	hvm:instance-store	20171026.1			hvm
    ca-central-1 = "ami-f172ca95" # 	xenial	16.04 LTS	amd64	hvm:instance-store	20171026.1			hvm
    eu-central-1 = "ami-37e25858" # 	xenial	16.04 LTS	amd64	hvm:instance-store	20171026.1			hvm
    eu-west-1 = "ami-1bde7a62" # 	xenial	16.04 LTS	amd64	hvm:instance-store	20171026.1			hvm
    eu-west-2 = "ami-1bbba67f" # 	xenial	16.04 LTS	amd64	hvm:instance-store	20171026.1			hvm
    sa-east-1 = "ami-556a1239" # 	xenial	16.04 LTS	amd64	hvm:instance-store	20171026.1			hvm
    us-east-1 = "ami-910faeeb" # 	xenial	16.04 LTS	amd64	hvm:instance-store	20171026.1			hvm
    us-east-2 = "ami-9d6b44f8" # 	xenial	16.04 LTS	amd64	hvm:instance-store	20171026.1			hvm
    us-west-1 = "ami-f11f2391" # 	xenial	16.04 LTS	amd64	hvm:instance-store	20171026.1			hvm
    us-west-2 = "ami-0d1fd175" # 	xenial	16.04 LTS	amd64	hvm:instance-store	20171026.1			hvm

// EBS images here
//    ap-south-1 = "ami-49e59a26"     # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
//    us-east-1 = "ami-d15a75c7"      # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
//    ap-northeast-1 = "ami-785c491f" # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
//    eu-west-1 = "ami-6d48500b"      # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
//    ap-southeast-1 = "ami-2378f540" # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
//    ca-central-1 = "ami-7ed56a1a"   # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
//    us-west-1 = "ami-73f7da13"      # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
//    eu-central-1 = "ami-1c45e273"   # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
//    sa-east-1 = "ami-34afc458"      # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
//    cn-north-1 = "ami-a163b4cc"     # 	xenial	amd64	hvm:ebs-ssd	20170303		hvm
//    us-gov-west-1 = "ami-939412f2"  # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
//    ap-southeast-2 = "ami-e94e5e8a" # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
//    eu-west-2 = "ami-cc7066a8"      # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
//    ap-northeast-2 = "ami-94d20dfa" # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
//    us-west-2 = "ami-835b4efa"      # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
//    us-east-2 = "ami-8b92b4ee"      # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
  }
}

resource "aws_instance" "cloudron" {
  tags = {Project = "cloudron"}
  ami           = "${var.images[var.region]}"
  instance_type = "${var.instance_type}"
  key_name = "${var.ec2_public_key_name}"
  user_data = "${data.template_file.user_data.rendered}"
  vpc_security_group_ids  = ["${aws_security_group.cloudron_sg.id}"]
  root_block_device = {
    volume_size = "${var.disk_size}"
    volume_type = "${var.disk_type}"
  }
  provisioner "file" {
    connection {user = "ubuntu"}
    source      = "${data.template_file.cloudwatch_metrics.rendered}"
    destination = "/etc/systemd/system/cloudwatch-metrics.service"
  }
  provisioner "file" {
    connection {user = "ubuntu"}
    source      = "${data.template_file.cloudwatch_logs.rendered}"
    destination = "/etc/systemd/system/cloudwatch-logs.service"
  }
}

resource "aws_s3_bucket" "backups" {
  tags = {Project = "cloudron"}
  bucket = "cloudron-backups-${data.aws_caller_identity.current.account_id}"
  region = "${var.backup_region}"
  acl    = "public-read" # we use encrypted backups, so public reads are safe. Also cloudron setup script cannot authenticate to s3, so this is the only option.
  policy =  <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AddPerm",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::cloudron-backups-${data.aws_caller_identity.current.account_id}/*"
        }
    ]
}
EOF
  lifecycle {
    prevent_destroy = true
  }
}

output "cloudron_installation_complete" {
  value = <<EOF
==============================================================
Thank you for installing Cloudron!

The cloud resources have been successfully created, but some processes are still active in background.

Make sure you delegate your domain '${var.domain}' to these name servers (NS):
${aws_route53_zone.cloudron_zone.name_servers.0}
${aws_route53_zone.cloudron_zone.name_servers.1}
${aws_route53_zone.cloudron_zone.name_servers.2}
${aws_route53_zone.cloudron_zone.name_servers.3}

After that please wait ~15 minutes and try navigating your browser to https://my.${var.domain} to finish the installation.

In the meantime, you should subscribe to alarms, to be notified if something happens on your server:
https://${var.region}.console.aws.amazon.com/sns/v2/home#/topics/${aws_sns_topic.alarms.arn}

Backups will be stored under https://s3.console.aws.amazon.com/s3/buckets/${aws_s3_bucket.backups.id}
Backup Encryption Key: ${random_id.backup_key.b64}

Enjoy self-hosting!
EOF
}
