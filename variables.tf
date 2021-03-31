variable "do_token" {
  description = "API key for Digitalocean"
  type        = string
  sensitive   = true
}

variable "ssh_public_keys" {
  description = "Fingerprints of public ssh keys"
  type        = list(string)
  sensitive   = true
}

variable "droplet_number_server" {
  description = "Number of servers to deploy"
  type        = number
  default     = 1
}

variable "droplet_provider" {
  description = "Abbreviation for the cloud provider - required for naming"
  type        = string
  default     = "do"
}

variable "droplet_country" {
  description = "Country of where resource is deployed"
  type        = string
}

variable "droplet_datacenter" {
  description = "Datacenter where resource is deployed"
  type        = string
}

variable "droplet_os_image" {
  description = "Operating System of virtual machine"
  type        = string
  default     = "ubuntu-20-04-x64"
}

variable "droplet_size" {
  description = "Size of virtual machine"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "droplet_increase_disk" {
  description = "Resize disk when VM is resized"
  type        = bool
  default     = false
}

variable "droplet_project" {
  description = "Name of the project - optional for naming"
  type        = string
  default     = "project"
}

variable "droplet_environment" {
  description = "Assigned environment - dev, stage, prod"
  type        = string
  default     = "dev"
}

variable "droplet_purpose" {
  description = "Purpose of the resource"
  type        = string
  default     = "server"
}

variable "droplet_tags" {
  description = "Additional assigned tags"
  type        = list(string)
  default     = []
}

variable "do_inbound_rules" {
  description = "List of allowed ports, protocols and source addresses"
  type        = list(string)
  default     = []
}

variable "cloudflare_email" {
  description = "The E-Mail address assigned to the Cloudflare account"
  type        = string
  sensitive   = true
}

variable "cloudflare_api_key" {
  description = "API key for Cloudflare"
  type        = string
  sensitive   = true
}

variable "cloudflare_tld" {
  description = "Assigned domain"
  type        = string
}

# aws-us-nyc1-terraform-dev-web-001.example.com
# Scheme: cloud-country-datacenter-project-environment-purpose-sequence.domain.tld
