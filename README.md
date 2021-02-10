# Digitalocean Droplets Module

This module will create a [Digitalocean](digitalocean.com) VM - aka droplet - protected by a Digitalocean firewall and creates at the same time DNS entries for IPv4 and IPv6 using [Cloudflare](cloudflare.com).

# Requirements

## SSH Fingerprints

The fingerprints from your public keys are required. Replace `<public_key_fingerprint>` with the fingerprints in `secrets.tfvars`.

## Cloudflare

Your e-mail address and API key for Cloudflare are required. Get this key [here](https://dash.cloudflare.com/profile) or open the dashboard for the domain and click on the link `Get your API token`. Replace `<name>@example.com` and `<key>` in `secrets.tfvars`.

## Digitalocean

A `personal access token` is required. Get this at `Account -> API -> Generate New Token` or click just [here](https://cloud.digitalocean.com/account/api/tokens). Replace `<token>` in `secrets.tfvars`.

## Secrets

Quite obvious: A `secrets.tfvars` file is required to store your credentials for Cloudflare and Digitalocean.

# Default Settings

## VM Defaults

- By default `IPv6` is enabled. 
- Resizing the disk when a larger VM is chosen is **disabled**. The reason is that once the disk is increased it can not be downsized anymore. If this behavior is acceptable for you add `resource_increase_disk = "true"` to the module.

## Firewall Defaults

- By default only `ssh` on port 22 and `ICMP` are open to the outside world. 
- Outbound are no limitations. 

# Example Usage

Either you use the example below where the module will be grabbed from [GitHub](github.com) direct or clone the repository and get the relative path to the module. Replace the GitHub link with the relative path (i.e. `"../../module/do-droplet"`) in the following `main.tf`:

```hcl
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
  required_version = ">= 0.14, < 0.15"
}

provider "digitalocean" {
  token = var.do_token
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

module "example" {
  source = "github.com/akutschi/terraform-digitalocean-cloudflare-droplet-firewall?ref=v0.0.1"

  do_token        = var.do_token
  ssh_public_keys = var.ssh_public_keys

  resource_number_server = 1

  resource_country     = "de"
  resource_datacenter  = "fra1"
  resource_project     = "demo"
  resource_purpose     = "example"
  resource_environment = "dev"

  resource_tags = [
      "example-tag-1",
      "example-tag-2:,
  ]

  do_inbound_rules = [
      "80/tcp",
      "443/tcp",
  ]

  cloudflare_email   = var.cloudflare_email
  cloudflare_api_key = var.cloudflare_api_key
  cloudflare_tld     = "example.com"
}
```

In the same directory `variables.tf` is required: 

```hcl
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
```

And the secrets are stored in `secrets.tfvars`:

```hcl
do_token = "<token>"

ssh_public_keys = [
    "<public_key_fingerprint>",
  ]

cloudflare_email = "<name>@example.com"

cloudflare_api_key = "<key>"
```

And finally run `terraform plan -var-file=../secrets.tfvars` check the changes and `terraform apply -var-file=../secrets.tfvars` to apply the plan. 

# Argument Reference

- `do_token` - (Required) API key for Digitalocean.

- `ssh_public_keys` - (Required) Fingerprints of public ssh keys. Type is `list(string)`
  
- `resource_number_server` - (Optional) Number of servers to deploy. Defaults to `1`.
  
- `resource_provider` - (Optional) Abbreviation for the cloud provider - required for naming. Defaults to `do`.
  
- `resource_country` - (Required) Country of where resource is deployed.

- `resource_datacenter` - (Required) Datacenter where the VM is deployed.

- `resource_image` - (Optional) Operating System of virtual machine. Default is `Ubuntu 20.04 LTS`.

- `resource_size` - (Optional) Size of virtual machine. Default is the smallest one: `s-1vcpu-1gb`.

- `resource_increase_disk` - (Optional) Resize disk when VM is resized. Default is `false`.

- `resource_project` - (Optional) Name of the project - optional for naming. Default is `project`.

- `resource_environment` - (Optional) Assigned environment - dev, stage, prod. Default is `dev`.

- `resource_purpose` - (Optional) Purpose of the resource. Defaults to `server`.

- `resource_tags` - (Optional) Additional assigned tags. Type `list(string)`. Default is an empty list.  A set of tags like country, datacenter and so on will be created automatically. This tags here are on top of the predefined ones.

- `do_inbound_rules` - (Optional) List of allowed ports, protocols and source addresses. Type is `list(string)`. Default is an empty list. Everything incoming except 22 and ICMP will be blocked by default. Outgoing traffic is unblocked.

- `cloudflare_email` - (Required) The E-Mail address assigned to the Cloudflare account.

- `cloudflare_api_key` - (Required) API key for Cloudflare.

- `cloudflare_tld` - (Required) Assigned domain to the droplet.


