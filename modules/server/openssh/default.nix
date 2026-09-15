{...}: {
  flake.nixosModules.openssh = {...}: {
    services.openssh = {
      enable = true;

      settings = {
        # Key-based auth only; passwords are a dead giveaway.
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";

        X11Forwarding = false;
      };
    };

    # Brute-force protection; tailnet IPs are always trusted.
    services.fail2ban = {
      enable = true;

      maxretry = 5;
      bantime = "1h";

      ignoreIP = [
        "100.64.0.0/10"
      ];
    };
  };
}
