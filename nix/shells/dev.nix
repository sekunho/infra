{ pkgs, ... }: pkgs.mkShell {
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
}
