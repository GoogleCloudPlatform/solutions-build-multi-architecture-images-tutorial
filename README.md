# Building multi-architecture container images on Google Cloud

This repository contains the necessary scripts and descriptors to setup the
infrastructure described in
[Building multi-architecture container images in Google Cloud](https://cloud.google.com/solutions/building-multi-architecture-container-images-iot-devices-tutorial)
reference guide:

- [Terraform](https://www.terraform.io/) templates that provision the necessary
    infrastructure on Google Cloud.
- A [Dockerfile](https://docs.docker.com/engine/reference/builder/) to build a
    Docker image during the tutorial.

## Dependencies

You need the following tools to follow the tutorial:

- [Git](https://git-scm.com/) (tested with version `2.25.0`).
- [Terraform](https://www.terraform.io/) (tested with version `v0.12.20`).
- [Google Cloud SDK](https://cloud.google.com/sdk) (tested with version `271.0.0`).

## Setting environment variables

To provision the necessary infrastructure, you need to initialize and export the
following environment variables:

- `TF_SERVICE_ACCOUNT_NAME`: [Google Cloud service account](https://cloud.google.com/iam/docs/understanding-service-accounts)
    name that Terraform will use to provision resources.
- `TF_STATE_PROJECT`: Google Cloud project ID that Terraform will use to store
    the [state](https://www.terraform.io/docs/state/index.html).
- `TF_STATE_BUCKET`: Google Cloud Storage bucket that Terraform will use to save
    the state files.
- `GOOGLE_CLOUD_PROJECT`: Google Cloud project ID that will contain the
    resources for the container image building pipeline.
- `GOOGLE_APPLICATION_CREDENTIALS`: path to the default Google Cloud
    credentials.

## Provisioning the environment

1. Change your working directory to the root of this repo.
1. Generate the Terraform backend configuration: `./generate-tf-backend.sh`
1. Change your working directory: `cd terraform`
1. Inspect the changes that Terraform will apply: `terraform plan`
1. Apply the changes: `terraform apply`

## Triggering the pipeline

You can now trigger the container image building pipeline:

1. Clone the Cloud Source Repository (CSR) that you provisioned with Terraform:
    `gcloud source repos clone cross-build`
1. Copy the provided [`Dockerfile`](terraform/cloud-build/Dockerfile) and the
    [build-docker-image-trigger.yaml](terraform/cloud-build/build-docker-image-trigger.yaml)
    in the directory where you cloned the CSR repository.
1. Commit the changes: `git add .`
1. Push the changes to the remote CSR repository: `git push`

You can then open the Cloud Build page in the Google Cloud Console to inspect
the results.
