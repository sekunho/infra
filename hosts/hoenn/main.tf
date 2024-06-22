terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "~> 1.47"
    }
  }
}

variable "hcloud_token" {
  type = string
  sensitive = true
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "default" {
  name = "default"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "hcloud_network" "hoennet" {
  name = "hoennet"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "hoenn-subnet" {
  type = "cloud"
  network_id = hcloud_network.hoennet.id
  network_zone = "us-west"
  ip_range = "10.0.1.0/24"
}

resource "hcloud_server" "hoenn-control-1" {
  name = "hoenn-control-1"
  server_type = "cpx11"
  datacenter = "hil-dc1"
  ssh_keys = [ hcloud_ssh_key.default.name ]
  image = "ubuntu-24.04"

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
}

resource "hcloud_server" "hoenn-worker-1" {
  name = "hoenn-worker-1"
  server_type = "cpx11"
  datacenter = "hil-dc1"
  ssh_keys = [ hcloud_ssh_key.default.name ]
  image = "ubuntu-24.04"

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
}

resource "hcloud_server" "hoenn-worker-2" {
  name = "hoenn-worker-2"
  server_type = "cpx11"
  datacenter = "hil-dc1"
  ssh_keys = [ hcloud_ssh_key.default.name ]
  image = "ubuntu-24.04"

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
}

resource "hcloud_server_network" "hoenn-control-1-network" {
  server_id = hcloud_server.hoenn-control-1.id
  subnet_id = hcloud_network_subnet.hoenn-subnet.id
  ip = "10.0.1.1"
}

resource "hcloud_server_network" "hoenn-worker-1-network" {
  server_id = hcloud_server.hoenn-worker-1.id
  subnet_id = hcloud_network_subnet.hoenn-subnet.id
  ip = "10.0.1.2"
}

resource "hcloud_server_network" "hoenn-worker-2-network" {
  server_id = hcloud_server.hoenn-worker-2.id
  subnet_id = hcloud_network_subnet.hoenn-subnet.id
  ip = "10.0.1.3"
}
