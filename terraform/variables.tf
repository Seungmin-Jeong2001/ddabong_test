variable "gcp_project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "The GCP region"
  type        = string
  default     = "asia-northeast3" # Seoul
}

variable "gcp_zone" {
  description = "The GCP zone"
  type        = string
  default     = "asia-northeast3-a"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for bucheongoyangijanggun.com"
  type        = string
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
}

variable "ssh_user" {
  description = "The SSH user name"
  type        = string
  default     = "ubuntu"
}

variable "ssh_pub_key" {
  description = "The SSH public key content"
  type        = string
}
