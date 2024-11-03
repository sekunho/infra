{ pkgs, ... }: {
  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/cache-priv-key.pem";
  };

  systemd.services = {
    proxy-nix-serve = {
      description = "Broadcast nix-serve service to tailnet";

      after = [ "network-pre.target" "tailscale.service" "tailscale-autoconnect.service" "nix-serve.service" ];
      wants = [ "network-pre.target" "tailscale.service" "tailscale-autoconnect.service" "nix-serve.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.tailscale}/bin/tailscale serve --https 443 localhost:80";
      };
    };
  };
}
