{ self, disko, hostName }: { name, node, pkgs, ... }: {
  imports = [
    (self.nixosModules.nix { trusted-users = [ "root" "operator" ]; })
    disko.nixosModules.disko
    (self.nixosModules.hetzner { inherit hostName; })
    self.nixosModules.k3s-worker
  ];

  deployment = {
    tags = [ "hoenn" "hoenn-worker" ];
    targetHost = "hoenn-worker-1.sekun.net";
    targetUser = "operator";
    targetPort = 22;

    keys = {
      "k3s_token" = {
        keyFile = "/home/sekun/Projects/infra/secrets/hoenn/k3s_token";
        destDir = "/etc/secrets";
        user = "operator";
        group = "users";
        permissions = "0640";
      };
    };
  };
}
