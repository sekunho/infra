terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

provider "hcloud" {
  token = trim("${file("secrets/hcloud_token")}", "\n")
}

resource "hcloud_ssh_key" "default" {
  name = "default"
  public_key = "${file("~/.ssh/id_ed25519.pub")}"
}

resource "hcloud_server" "tacohiro" {
  name = "tacohiro"
  server_type = "cpx11"
  datacenter = "hil-dc1"
  ssh_keys = [ hcloud_ssh_key.default.name ]
  image = "ubuntu-24.04"

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
}
