{ self
, disko
, nixosSystem
, mkPkgs
, publicKeys
, hostName
, stateVersion
, trusted-users ? [ "root" ]
}:
let
  system = "x86_64-linux";
  pkgs = mkPkgs system;
in
nixosSystem {
  inherit system;

  modules = [
    self.nixosModules.nix
    disko.nixosModules.disko
    self.nixosModules.hetzner

    ({ ... }: {
      system = {
        inherit stateVersion;
      };

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
    inherit publicKeys hostName pkgs trusted-users;
  };
}
