{ config, pkgs, ... }: {
  networking = {
    hostName = "tacohiro";
    domain = "tacohiro.quoll-owl.ts.net";

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
