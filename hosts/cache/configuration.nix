{ config, pkgs, ... }: {
  networking = {
    hostName = "cache";
    domain = "cache.quoll-owl.ts.net";

    firewall = {
      enable = true;
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      allowedTCPPorts = [ 22 ];
    };
  };

  environment.systemPackages = with pkgs; [ tailscale ];
}
