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
  count  = var.resource_number_server
  image  = var.resource_image
  name   = "${var.resource_provider}-${var.resource_country}-${var.resource_datacenter}-${var.resource_project}-${var.resource_environment}-${var.resource_purpose}-${format("%02d", count.index + 1)}.${var.cloudflare_tld}"
  region = var.resource_datacenter
  tags = concat(
    var.resource_tags,
    list("terraform"),
    list(var.resource_country),
    list(var.resource_datacenter),
    list(var.resource_provider),
    list(var.resource_image),
    list(var.resource_purpose),
    list(var.resource_environment),
    list(var.resource_project),
    list(var.resource_size),
  )
  size        = var.resource_size
  resize_disk = var.resource_increase_disk
  ipv6        = true
  ssh_keys    = var.ssh_public_keys
}

resource "digitalocean_firewall" "droplet-fw" {
  name = "${var.resource_provider}-${var.resource_country}-${var.resource_datacenter}-${var.resource_project}-${var.resource_environment}-${var.resource_purpose}"

  droplet_ids = [for d in digitalocean_droplet.droplet[*] : d.id]

  dynamic "inbound_rule" {
    iterator = rule
    for_each = var.do_inbound_rules
    content {
      port_range       = split("/", rule.value)[0]
      protocol         = split("/", rule.value)[1]
      source_addresses = ["0.0.0.0/0", "::/0"]
    }
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

data "cloudflare_zones" "domain" {
  filter {
    name = var.cloudflare_tld
  }
}

resource "cloudflare_record" "droplet-a" {
  count   = var.resource_number_server
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = "${var.resource_provider}-${var.resource_country}-${var.resource_datacenter}-${var.resource_project}-${var.resource_environment}-${var.resource_purpose}-${format("%02d", count.index + 1)}"
  value   = element(digitalocean_droplet.droplet.*.ipv4_address, count.index)
  type    = "A"
  proxied = "false"
  ttl     = 3600
}

resource "cloudflare_record" "droplet-aaaa" {
  count   = var.resource_number_server
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = "${var.resource_provider}-${var.resource_country}-${var.resource_datacenter}-${var.resource_project}-${var.resource_environment}-${var.resource_purpose}-${format("%02d", count.index + 1)}"
  value   = element(digitalocean_droplet.droplet.*.ipv6_address, count.index)
  type    = "AAAA"
  proxied = "false"
  ttl     = 3600
}
