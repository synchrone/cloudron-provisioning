Provisioning Cloudron in your cloud
====

Deploying Cloudron to your Cloud
---
1. Register a new 2-level domain, e.g mypersonalcloudron.org (sub-domains require a paid subscription)
1. Download and install [Terraform](https://www.terraform.io/downloads.html)

1. Register an account at [AWS](https://www.amazon.com/ap/signin?openid.assoc_handle=aws&openid.return_to=https%3A%2F%2Fsignin.aws.amazon.com%2Foauth%3Fcoupled_root%3Dtrue%26response_type%3Dcode%26redirect_uri%3Dhttps%253A%252F%252Fconsole.aws.amazon.com%252Fconsole%252Fhome%253Fstate%253DhashArgs%252523%2526isauthcode%253Dtrue%26client_id%3Darn%253Aaws%253Aiam%253A%253A015428540659%253Auser%252Fhomepage&openid.mode=checkid_setup&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&action=&disableCorpSignUp=&clientContext=&marketPlaceId=&poolName=&authCookies=&pageId=aws.ssop&siteState=unregistered%2CEN_US&accountStatusPolicy=P1&sso=&openid.pape.preferred_auth_policies=MultifactorPhysical&openid.pape.max_auth_age=120&openid.ns.pape=http%3A%2F%2Fspecs.openid.net%2Fextensions%2Fpape%2F1.0&server=%2Fap%2Fsignin%3Fie%3DUTF8&accountPoolAlias=&forceMobileApp=0&language=EN_US&forceMobileLayout=0) or [GCP](https://console.cloud.google.com)

1. (GCP-only) Create a new Project and Enable [IAM API](https://console.developers.google.com/apis/api/iam.googleapis.com/overview) and [Resource Manager API](https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview) in it

1. Optionally register an account at [Mailgun](http://mailgun.com) (free for individual-grade email volumes, no card required)

1. `cd aws` or `cd gcp`

1. Modify `terraform.tfvars` file with your domain, api keys, and optionally a backup url, when restoring.
Optionally `terraform plan`, if you want to know which resources will be created for you, or check for errors.

1. `terraform apply`. This command can take 10-15 minutes.

1. Delegate your domain to the name servers shown at the end (zone_ns). This is done at your domain registrar's control panel.

**That's it!** Wait for DNS records to update and try accessing your Cloudron!

Destroying
===
1. `./destroy.sh` in the same directory where you ran `terraform apply`. This uses a `terraform.tfstate` file, which is created by `apply` command.

Note: this does not destroy your backups bucket and the hosted DNS zone
