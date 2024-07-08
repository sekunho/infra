{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    tailscale.url = "github:sekunho/tailscale/update-hash";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, tailscale, disko }:
    let
      pkgsOverlay = system: final: prev: {
        tailscale = tailscale.packages.${system}.tailscale;
      };

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
    {
      packages = { };

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
        init-hetzner = nixpkgs.lib.nixosSystem {
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

        hoenn-control-1 = { name, node, pkgs, ... }: {
          imports = [
            self.nixosModules.nix
            disko.nixosModules.disko
            self.nixosModules.hetzner
            self.nixosModules.k3s-control

            ({ ... }: {
              networking.hostName = "hoenn-control-1";
            })
          ];

          deployment = {
            tags = [ "hoenn" "hoenn-control" ];
            targetHost = "hoenn-control-1.sekun.net";
            targetUser = "operator";
            targetPort = 22;

            keys = {
              "k3s_token" = {
                keyCommand = ["./bws-secret-get" "k3s-token"];
                destDir = "/etc/secrets";
                user = "operator";
                group = "users";
                permissions = "0640";
              };

              "registries.yaml" = {
                keyCommand = ["./bws-secret-get" "k3s-registries"];
                destDir = "/etc/rancher/k3s";
                user = "operator";
                group = "users";
                permissions = "0640";
              };
            };
          };
        };

        hoenn-worker-1 = { name, node, pkgs, ... }: {
          imports = [
            self.nixosModules.nix
            disko.nixosModules.disko
            self.nixosModules.hetzner
            self.nixosModules.k3s-worker

            ({ ... }: {
              networking.hostName = "hoenn-worker-1";
            })
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
        };

        hoenn-worker-2 = { name, node, pkgs, ... }: {
          imports = [
            self.nixosModules.nix
            disko.nixosModules.disko
            self.nixosModules.hetzner
            self.nixosModules.k3s-worker

            ({ ... }: {
              networking.hostName = "hoenn-worker-2";
            })
          ];

          deployment = {
            tags = [ "hoenn" "hoenn-worker" ];
            targetHost = "hoenn-worker-2.sekun.net";
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
        };

        cache = { name, node, pkgs, ... }: {
          imports = [
            self.nixosModules.nix
            disko.nixosModules.disko
            self.nixosModules.hetzner
            self.nixosModules.tailscale
            self.nixosModules.nix-serve
            self.nixosModules.cache
            self.nixosModules.cache-nginx
          ];

          deployment = {
            targetHost = "cache.sekun.net";
            targetUser = "operator";
            targetPort = 22;

            keys = {
              "ts_authkey" = {
                keyFile = "/home/sekun/Projects/infra/secrets/ts_authkey";
                destDir = "/var";
                user = "operator";
                group = "users";
                permissions = "0640";
              };
            };
          };
        };
      };

      devShells = {
        aarch64-darwin =
          let
            pkgs = mkPkgs "aarch64-darwin";
          in
          {
            default = pkgs.mkShell {
              shellHook = ''
                set -a
                source env.sh
                set +a
              '';

              buildInputs = with pkgs; [
                nil
                nixpkgs-fmt
                opentofu
                kubectl
                just
                bws
                jq
                colmena
              ];
            };
          };

        x86_64-linux =
          let
            pkgs = mkPkgs "x86_64-linux";
          in
          {
            default = pkgs.mkShell {
              shellHook = ''
                set -a
                source env.sh
                set +a
              '';

              buildInputs = with pkgs; [
                nil
                nixpkgs-fmt
                opentofu
                kubectl
                just
                bws
                colmena
              ];
            };
          };
      };
    }
  ;
}
