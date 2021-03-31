terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.4"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.0"
    }
  }
  required_version = ">= 0.14, < 0.15"
}

resource "digitalocean_droplet" "droplet" {
  count  = var.droplet_number_server
  image  = var.droplet_os_image
  name   = "${var.droplet_provider}-${var.droplet_country}-${var.droplet_datacenter}-${var.droplet_project}-${var.droplet_environment}-${var.droplet_purpose}-${format("%02d", count.index + 1)}.${var.cloudflare_tld}"
  region = var.droplet_datacenter
  tags = concat(
    var.droplet_tags,
    list("terraform"),
    list(var.droplet_country),
    list(var.droplet_datacenter),
    list(var.droplet_purpose),
    list(var.droplet_environment),
    list(var.droplet_project),
  )
  size        = var.droplet_size
  resize_disk = var.droplet_increase_disk
  ipv6        = true
  ssh_keys    = var.ssh_public_keys
}

data "cloudflare_zones" "domain" {
  filter {
    name = var.cloudflare_tld
  }
}

resource "cloudflare_record" "droplet-a" {
  count   = var.droplet_number_server
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = "${var.droplet_provider}-${var.droplet_country}-${var.droplet_datacenter}-${var.droplet_project}-${var.droplet_environment}-${var.droplet_purpose}-${format("%02d", count.index + 1)}"
  value   = element(digitalocean_droplet.droplet.*.ipv4_address, count.index)
  type    = "A"
  proxied = "false"
  ttl     = 3600
}

resource "cloudflare_record" "droplet-aaaa" {
  count   = var.droplet_number_server
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = "${var.droplet_provider}-${var.droplet_country}-${var.droplet_datacenter}-${var.droplet_project}-${var.droplet_environment}-${var.droplet_purpose}-${format("%02d", count.index + 1)}"
  value   = element(digitalocean_droplet.droplet.*.ipv6_address, count.index)
  type    = "AAAA"
  proxied = "false"
  ttl     = 3600
}
