terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

variable "cache_bws_token" {
  sensitive = true
}

provider "hcloud" {
  token = trim("${file("../../hcloud_token.txt")}", "\n")
}

resource "hcloud_ssh_key" "default" {
  name = "default"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "hcloud_server" "cache" {
  name = "cache"
  server_type = "cpx11"
  datacenter = "hil-dc1"
  ssh_keys = [ hcloud_ssh_key.default.name ]
  image = "ubuntu-24.04"

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
}
