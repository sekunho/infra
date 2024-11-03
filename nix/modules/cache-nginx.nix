{ config, ... }: {
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedZstdSettings = true;

    virtualHosts = {
      "cache.quoll-owl.ts.net" = {
        locations = {
          "/hello-world" = {
            extraConfig = ''
              default_type text/html;
              return 200 'Hello, world!';
            '';
          };

          "/" = {
            extraConfig = ''
              proxy_pass http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port};
            '';
          };
        };
      };
    };
  };
}
