{ ... }: {
  services.fail2ban = {
    enable = true;
    maxretry = 5;

    ignoreIP = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "100.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
      "8.8.8.8"
    ];
  };
}
