# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
