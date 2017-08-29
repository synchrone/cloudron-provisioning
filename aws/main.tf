variable "domain" {
  type = "string"
  description = "The domain where to install Cloudron"
}
variable "ec2_public_key_name" {
  type = "string"
  description = "AWS Public key to allow you to ssh into machine"
  default = ""
}
variable "r53_delegation_set" {
  type = "string"
  default = ""
  description = "Reusable delegation set ID"
}

variable "region" {
  type = "string"
  default = "eu-west-1"
}
variable "version" {
  type = "string"
  default = "1.6.2"
}
variable "cloudron_restore_url" {
  type = "string"
  default = ""
  description = "Restore from a Backup (URL, must be publicly-accessable)"
}
variable "cloudron_restore_key" {
  type = "string"
  default = ""
  description = "Backup encryption key, if any"
}
# ===================================

provider "aws" {
  region     = "${var.region}"
}
data "aws_caller_identity" "current" {}

variable "images" {
  type = "map"
  default = { #from http://cloud-images.ubuntu.com/locator/ec2/
    ap-south-1 = "ami-49e59a26"     # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
    us-east-1 = "ami-d15a75c7"      # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
    ap-northeast-1 = "ami-785c491f" # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
    eu-west-1 = "ami-6d48500b"      # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
    ap-southeast-1 = "ami-2378f540" # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
    ca-central-1 = "ami-7ed56a1a"   # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
    us-west-1 = "ami-73f7da13"      # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
    eu-central-1 = "ami-1c45e273"   # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
    sa-east-1 = "ami-34afc458"      # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
    cn-north-1 = "ami-a163b4cc"     # 	xenial	amd64	hvm:ebs-ssd	20170303		hvm
    us-gov-west-1 = "ami-939412f2"  # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
    ap-southeast-2 = "ami-e94e5e8a" # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
    eu-west-2 = "ami-cc7066a8"      # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
    ap-northeast-2 = "ami-94d20dfa" # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
    us-west-2 = "ami-835b4efa"      # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
    us-east-2 = "ami-8b92b4ee"      # 	xenial	amd64	hvm:ebs-ssd	20170619.1		hvm
  }
}

resource "aws_instance" "cloudron" {
  ami           = "${var.images[var.region]}"
  instance_type = "t2.micro"
  key_name = "${var.ec2_public_key_name}"
  user_data = "${data.template_file.user_data.rendered}"
  vpc_security_group_ids  = ["${aws_security_group.cloudron_sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.cloudron_iprofile.name}"
  root_block_device = {
    volume_size = 22 #GB
  }
}

resource "aws_s3_bucket" "backups" {
  bucket = "cloudron-backups-${data.aws_caller_identity.current.account_id}"
}

# ======================================================
output "zone_ns" {
  value = "${aws_route53_zone.cloudron_zone.name_servers}"
  description = "Update your NS records in the domain registrar's control panel to these:"
}

output "cloudron_installation_complete" {
  value = <<EOF
==============================================================
Thank you for installing Cloudron!

The cloud resources have been successfully created, but some processes are still active in background.

Please wait a couple minutes and try navigating your browser to https://${var.domain} to finish the installation.

Backups will be stored under https://s3.console.aws.amazon.com/s3/buckets/${aws_s3_bucket.backups.id}

Enjoy self-hosting!
EOF
}
