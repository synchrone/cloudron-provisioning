# The domain where to install Cloudron, e.g example.org
# You need to be able to delegate it to DNS servers which this scenario will provide at the end.
domain = ""

# Your Service Account Key (JSON). Get it from https://console.cloud.google.com/apis/credentials/serviceaccountkey. Create a new service account, with Project -> Editor role assigned
google_credentials_file = "" # file name relative to terraform.tfvars (this file)

# Google Cloud Platform project name (e.g hardy-iridium-123567)
google_project = ""

# The server region. Choose from https://cloud.google.com/compute/docs/regions-zones/regions-zones#available
region = "us-central1"

# The instance type. Choose one at https://cloud.google.com/compute/docs/machine-types#predefined_machine_types or use 'custom-CPUS-MEMORY', e.g custom-4-16
instance_type = "g1-small"

# Disk size in GB
disk_size = "22"

#===== The following is optional. Uncomment the variables to use: =====

# Mailgun Secret API Key. e.g key-abcegedfafaecghef. Get one from https://app.mailgun.com/app/dashboard (box on the right)
# mailgun_api_key = ""

# When you have a backup to restore. Should be publicly accessible.
#cloudron_restore_url="https://storage.googleapis.com/<your_project>-backups/<date>/box_<date>_<version>.tar.gz"

# Backup encryption key (as shown at the end of this scenario or set in cloudron manually)
#cloudron_restore_key=""
