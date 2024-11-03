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
            nix = import ./modules/nix.nix;
            tailscale = import ./modules/tailscale.nix;
            cache-nginx = import ./modules/cache-nginx.nix;
            cache = import ./hosts/cache/configuration.nix;
            nix-serve = import ./modules/nix-serve.nix;
            hetzner = import ./modules/hetzner.nix;
            fail2ban = import ./modules/fail2ban.nix;
            k3s-worker = import ./modules/k3s-worker.nix;
            k3s-control = import ./modules/k3s-control.nix;
          };

          nixosConfigurations = {
            init-hetzner = import ./nix/configurations/init-hetzner.nix {
              inherit (nixpkgs.lib) nixosSystem;
              inherit self disko;
            };
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
