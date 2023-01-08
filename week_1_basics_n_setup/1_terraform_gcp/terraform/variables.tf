locals {
    data_lake_bucket ="dtc_data_lake"
}

variable "project" {
    description = "taxi-rides-ny"
}

variable "access_key_id" {
    description = "AWS access key for transfer service"
}

variable "aws_secret_key" {
    description = "AWS secret for transfer service"
}

variable "region" {
    description = "Region for GCP resources. Choose as per your location: https://cloud.google.com/about/locations"
    default = "us-central1"
    type = string
}

variable "storage_class" {
    description = "Storage class type for your bucket. Check official docs for more info."
    default = "STANDARD"
}

variable "BQ_DATASET" {
    description = "BigQuery Dataset that raw data (from GCS) will be written to"
    type = string
    default = "trips_data_all"
}