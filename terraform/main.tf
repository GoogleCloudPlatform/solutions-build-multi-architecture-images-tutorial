provider "google" {}

resource "google_service_account" "csr-cross-build-sa" {
  account_id   = "csr-cross-build"
  display_name = "Cross-build Cloud Source repositories Service Account"
}

resource "google_pubsub_topic" "csr-cross-build-topic" {
  name = "csr-topic"
  depends_on = [
    google_project_service.pubsub-apis
  ]
}

resource "google_project_service" "csr-apis" {
  service = "sourcerepo.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_project_service" "pubsub-apis" {
  service = "pubsub.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_sourcerepo_repository" "cross-build-repo" {
  depends_on = [
    google_project_service.csr-apis
    , google_service_account.csr-cross-build-sa
    , google_pubsub_topic.csr-cross-build-topic
  ]
  name = "cross-build"
  pubsub_configs {
    topic                 = google_pubsub_topic.csr-cross-build-topic.id
    message_format        = "JSON"
    service_account_email = google_service_account.csr-cross-build-sa.email
  }
}

resource "google_project_service" "cloudbuild-apis" {
  service = "cloudbuild.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_cloudbuild_trigger" "cloudbuild-trigger" {
  trigger_template {
    branch_name = "master"
    repo_name   = google_sourcerepo_repository.cross-build-repo.name
  }

  filename = "build-docker-image-trigger.yaml"

  depends_on = [
    google_project_service.cloudbuild-apis
    , google_sourcerepo_repository.cross-build-repo
    , google_pubsub_topic.csr-cross-build-topic
  ]
}

resource "google_project_service" "containerregistry-apis" {
  service = "containerregistry.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = true
}
