{ config, pkgs, ... }: {
  networking = {
    firewall = {
      enable = true;
      checkReversePath = "loose";
      # trustedInterfaces = [ "tailscale0" ];

      # https://docs.k3s.io/installation/requirements#inbound-rules-for-k3s-nodes
      allowedUDPPorts = [
        8472
        51820
      ];

      allowedTCPPorts = [
        22
        # k3s supervisor & api server
        6443
        # kubelet metrics
        10250
      ];
    };
  };

  services = {
    k3s = {
      enable = true;
      role = "agent";
      tokenFile = "/etc/secrets/k3s_token";
      serverAddr = "https://10.0.1.1:6443";

      extraFlags = ''
        --flannel-iface enp7s0
      '';
    };
  };
}
