{ self, disko }: { name, node, pkgs, ... }: {
  imports = [
    self.nixosModules.nix
    disko.nixosModules.disko
    self.nixosModules.hetzner
    self.nixosModules.tailscale
    self.nixosModules.nix-serve
    self.nixosModules.cache
    self.nixosModules.cache-nginx
  ];

  deployment = {
    targetHost = "cache.sekun.net";
    targetUser = "operator";
    targetPort = 22;

    keys = {
      "ts_authkey" = {
        keyFile = "/home/sekun/Projects/infra/secrets/ts_authkey";
        destDir = "/var";
        user = "operator";
        group = "users";
        permissions = "0640";
      };
    };
  };
}
