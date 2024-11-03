{ self, disko, nixosSystem, mkPkgs, publicKeys }: nixosSystem {
  system = "x86_64-linux";

  modules = [
    self.nixosModules.nix
    disko.nixosModules.disko
    self.nixosModules.hetzner

    ({ ... }: {
      networking = {
        firewall = {
          enable = true;
          trustedInterfaces = [ ];
          allowedUDPPorts = [ ];
          allowedTCPPorts = [ 22 ];
        };
      };
    })
  ];

  specialArgs = {
    pkgs = mkPkgs "x86_64-linux";
    inherit publicKeys;
  };
}
