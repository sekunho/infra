{ modulesPath, publicKeys, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    extraConfig = ''
      PrintLastLog no
    '';
  };

  security.sudo.wheelNeedsPassword = false;

  users.users = {
    root.openssh.authorizedKeys.keys = [ publicKeys.arceus publicKeys.blaziken ];

    operator = {
      isNormalUser = true;
      uid = 1000;
      home = "/home/operator";
      extraGroups = [ "wheel" "networkmanager" ];
      openssh.authorizedKeys.keys = [ publicKeys.arceus publicKeys.blaziken ];
    };
  };

  system.stateVersion = "23.11";
}
