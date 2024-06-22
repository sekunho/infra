tf-apply target:
  @echo 'Applying tofu @ {{ target }}...'
  tofu -chdir=hosts/{{ target }} apply

tf-destroy target:
  @echo 'Destroy tofu @ {{ target }}...'
  tofu -chdir=hosts/{{ target }} destroy

tf-plan target:
  @echo 'Planning tofu @ {{ target }}...'
  tofu -chdir=hosts/{{ target }} plan

tf-init target:
  @echo 'Initializing tofu @ {{ target }}...'
  tofu -chdir=hosts/{{ target }} init

install-nixos ip:
  @echo 'Installing NixOS on server {{ ip }}...'
  nix run github:numtide/nixos-anywhere -- --flake '.#init-hetzner' root@{{ ip }}
