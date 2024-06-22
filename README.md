# infra

## Hosts

### `hoenn`

`hoenn` is a `k3s` cluster running on Hetzner Cloud.

WIP

## `cache` (deprecated)

`cache` is a nix binary cache server that's meant to run internally within my
tailnet.

### Secrets

- `ts_authkey`: Tailscale auth key

### Environment variables

- `HCLOUD_TOKEN`: Hetzner read/write project access token

### Orchestrating the `cache` server from scratch

1. `just apply-cache` to spin up Hetzner instance
2. `nix run github:numtide/nixos-anywhere -- --flake '.#init-hetzner' root@<IP_ADDRESS>`
3. Follow [_Setting up a binary cache_](https://nixos.wiki/wiki/Binary_Cache)'s step 1
to generate `nix-serve`'s ec25519 keypair.
4. `colmena apply --on cache --reboot`
