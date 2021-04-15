output "droplet_inventory" {
  value = [for s in digitalocean_droplet.droplet[*] : {
    "groups" : concat(
      var.droplet_tags,
      tolist(["terraform"]),
      tolist([var.droplet_country]),
      tolist([var.droplet_datacenter]),
      tolist([var.droplet_purpose]),
      tolist([var.droplet_environment]),
      tolist([var.droplet_project]),
    )
    "name" : s.name,
    "ip" : s.ipv4_address,
    "ipv6" : s.ipv6_address,
    "ansible_ssh_user" : "root",
    "droplet_id" : s.id,
  }]
}
