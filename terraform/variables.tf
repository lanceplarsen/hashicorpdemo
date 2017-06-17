variable "region" {
  description = "region"
  default = "us-central1"
}

variable "region_zone" {
  description = "zone"
  default = "us-central1-f"
}

variable "project_name" {
  description = "llarsen-hashicorp-demo"
  default = "llarsen-hashicorp-demo"
}

variable "credentials_file_path" {
  description = "Path to the JSON file used to describe your account credentials"
  default     = "<cred file>"
}

variable "public_key_path" {
  description = "Path to file containing public key"
  default     = "gcloud_hashi_id_rsa.pub"
}

variable "private_key_path" {
  description = "Path to file containing private key"
  default     = "gcloud_hashi_id_rsa"
}