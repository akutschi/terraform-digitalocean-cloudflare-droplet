output "droplet_inventory" {
  value = [for s in digitalocean_droplet.droplet[*] : {
    "groups" : concat(
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
    "name" : s.name,
    "ip" : s.ipv4_address,
    "ipv6" : s.ipv6_address,
    "ansible_ssh_user" : "root",
  }]
}
