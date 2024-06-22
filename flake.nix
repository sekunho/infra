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

      system = "x86_64-linux";
      overlays = [ (pkgsOverlay system) ];
      pkgs = import nixpkgs { inherit system; inherit overlays; config.allowUnfree = true; };

      publicKeys = {
        default = ''
          ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCUboqku5i0dRaOoTZab2aAtD6WWL5eCPhBQett0bVYYzWupKywA+f/HKy6TBk+syQ9mJ4tf9uBt1bsrpoYIlxzjpVj/iNU+jPxlQJl02Rmryq8dO0DaTh7gTpwZXx4MVUdbI4eV8CZ2tEBYIpPpuPjs8h7014RQJfImrXXo4DBEOTrYZ+GcPR1ITCJHMwMbv4MC+2Qvas67mEfvDAzhFqNR0srOplyRrzmFsNu2XBSjiZVsKjWsG90F21vf+yXfkFHfVILWCYxMumL+CC6rotlKlReMenuMgWhSGBxz2N2P6KifqgIHSMRfp+aVeTwIQTuUSuPFkO4PjNXkgEQvKakOOb/pSruO7fyMWowbVVONg+m+L+SCdrjC4ulxz5VOSdPtY0ZNS29QlwT6lSlCKcCQ4R0RtY+lWsLGUaPApxjqj4gVTEGDFFEx6NUQnhOZcNLDSKtAzIfxWjhLhsyTOVGxH0qTk9a0wbw/NA22eRx3iKLQ4qpF+tj5ow/6h2tywyTiDeXd9MPrOZazy+X8emwRUXvgW1gb6zMmM80/XDc7h/ojfiK5Wg2mkK/L9AksTJeV/EmX5XTNBY5Rl+anXMyh7MnYf9OEX4Ts3hBtdzJWCaQe793E6q14zmZgXP/N4Lj7YawtpFcHk5sw76KYG8tCy7ppexJVYtUA33HXULJnQ== devops@sekun.net
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
          inherit system;

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
            inherit pkgs;
            inherit publicKeys;
          };
        };
      };

      colmena = {
        meta = {
          nixpkgs = pkgs;

          specialArgs = {
            inherit pkgs;
            inherit publicKeys;
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
                keyFile = "/home/sekun/Projects/infra/secrets/hoenn/k3s_token";
                destDir = "/etc/secrets";
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
        x86_64-linux = {
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
              colmena
            ];
          };
        };
      };
    }
  ;
}
