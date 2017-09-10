# The domain where to install Cloudron, e.g example.org
# You need to be able to delegate it to DNS servers which this scenario will provide at the end.
domain = ""

# AWS Access Key Id and Secret. Get it from https://console.aws.amazon.com/iam/home?region=eu-west-1#/security_credential
aws_access_key = ""
aws_secret_key = ""

# The server location. Choose from http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions
region = "eu-west-1"

# The instance type. Choose one at https://aws.amazon.com/ec2/instance-types/
instance_type = "t2.micro"

# Disk size in GB
disk_size = "22"

#===== The following is optional. Uncomment the variables to use: =====

# Mailgun Secret API Key. e.g key-abcegedfafaecghef. Get one from https://app.mailgun.com/app/dashboard (box on the right)
# mailgun_api_key = ""

# When you have a backup to restore. Should be publicly accessible.
#cloudron_restore_url="https://s3-eu-west-1.amazonaws.com/cloudron-backups-<your_account>/<date>/box_<date>_<version>.tar.gz"

# Backup encryption key (as shown at the end of this scenario or set in cloudron manually)
#cloudron_restore_key=""

# AWS Public key to allow you to ssh.
# Create one at https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#KeyPairs:sort=keyName
# Uncomment to use:
#ec2_public_key_name = "me"
