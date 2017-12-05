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

// TODO: Stackdriver
//  binding {
//    role = "<logs>"
//    members = ["serviceAccount:${google_service_account.cloudron.email}"]
//  }
//
//  binding {
//    role = "<metrics>"
//    members = ["serviceAccount:${google_service_account.cloudron.email}"]
//  }
}