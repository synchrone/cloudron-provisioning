resource "google_service_account" "cloudron" {
  account_id   = "cloudron"
  display_name = "Cloudron"
}

resource "google_project_iam_policy" "cloudron" {
  project     = "${var.google_project}"
  policy_data = "${data.google_iam_policy.cloudron.policy_data}"
}

data "google_iam_policy" "cloudron" {
  binding {
    role = "roles/dns.admin"
    members = ["serviceAccount:${google_service_account.cloudron.email}"]
  }
  binding {
    role = "roles/storage.objectAdmin"
    members = ["serviceAccount:${google_service_account.cloudron.email}"]
  }

  binding {
    role = "roles/monitoring.metricWriter"
    members = ["serviceAccount:${google_service_account.cloudron.email}"]
  }

  binding {
    role = "roles/logging.logWriter"
    members = ["serviceAccount:${google_service_account.cloudron.email}"]
  }
}