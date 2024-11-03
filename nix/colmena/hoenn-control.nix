{ self, disko, hostName }: { name, node, pkgs, ... }: {
  imports = [
    (self.nixosModules.nix { trusted-users = [ "root" "operator" ]; })
    disko.nixosModules.disko
    (self.nixosModules.hetzner { inherit hostName; })
    self.nixosModules.k3s-control
  ];

  deployment = {
    tags = [ "hoenn" "hoenn-control" ];
    targetHost = "hoenn-control-1.sekun.net";
    targetUser = "operator";
    targetPort = 22;

    keys = {
      "k3s_token" = {
        keyCommand = [ "./bws-secret-get" "k3s-token" ];
        destDir = "/etc/secrets";
        user = "operator";
        group = "users";
        permissions = "0640";
      };

      "registries.yaml" = {
        keyCommand = [ "./bws-secret-get" "k3s-registries" ];
        destDir = "/etc/rancher/k3s";
        user = "operator";
        group = "users";
        permissions = "0640";
      };
    };
  };
}
