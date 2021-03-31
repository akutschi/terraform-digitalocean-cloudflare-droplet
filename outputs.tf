output "droplet_inventory" {
  value = [for s in digitalocean_droplet.droplet[*] : {
    "groups" : concat(
      var.droplet_tags,
      list("terraform"),
      list(var.droplet_country),
      list(var.droplet_datacenter),
      list(var.droplet_purpose),
      list(var.droplet_environment),
      list(var.droplet_project),
    )
    "name" : s.name,
    "ip" : s.ipv4_address,
    "ipv6" : s.ipv6_address,
    "ansible_ssh_user" : "root",
    "droplet_id" : s.id,
  }]
}
