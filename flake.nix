{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-parts.url = "github:hercules-ci/flake-parts";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-parts, disko }@inputs:
    let
      pkgsOverlay = system: final: prev: { };
      stateVersion = "24.05";

      mkPkgs = system:
        let
          overlays = [ (pkgsOverlay system) ];
        in
        import nixpkgs {
          inherit system;
          inherit overlays;
          config.allowUnfree = true;
        };

      publicKeys = {
        arceus = ''
          ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILivh7MN4ZQilbj0jTbKCwoRb+Z/qUYUs6U7E4+61abJ sekun@arceus
        '';

        blaziken = ''
          ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9nZqRf4oi9qIQJTJ/yftfj6MzHl+K6i0vUXKnyk9tR sekun@blaziken
        '';
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; }
      {
        systems = [ "x86_64-linux" "aarch64-darwin" ];

        flake = {
          nixosModules = {
            nix = import ./nix/modules/nix.nix;
            tailscale = import ./nix/modules/tailscale.nix;
            cache-nginx = import ./nix/modules/cache-nginx.nix;
            cache = import ./hosts/cache/configuration.nix;
            nix-serve = import ./nix/modules/nix-serve.nix;
            hetzner = import ./nix/modules/hetzner.nix;
            fail2ban = import ./nix/modules/fail2ban.nix;
            k3s-worker = import ./nix/modules/k3s-worker.nix;
            k3s-control = import ./nix/modules/k3s-control.nix;
          };

          nixosConfigurations = {
            init-cache = self.bruh.mkHetzner {
              inherit (nixpkgs.lib) nixosSystem;
              inherit self disko mkPkgs publicKeys stateVersion;
              hostName = "cache";
            };
          };

          lib = {
            mkHetzner = import ./nix/packages/mk-hetzner.nix;
          };

          colmena = {
            meta = {
              nixpkgs = mkPkgs "x86_64-linux";

              specialArgs = {
                inherit publicKeys;
                pkgs = mkPkgs "x86_64-linux";
                authKeyFile = "/var/ts_authkey";
              };
            };

            cache = import ./nix/colmena/cache.nix { inherit self disko; };
          };
        };

        perSystem = { config, system, ... }:
          let
            pkgs = mkPkgs "x86_64-linux";
          in
          {
            devShells = {
              default = import ./nix/shells/dev.nix { inherit pkgs; };
            };
          };
      };
}
