{...}: {
  flake.nixosModules.uptimeKuma = {
    services.uptime-kuma = {
      enable = true;

      # Reachable on LAN and via the tailnet; has its own login.
      # Monitors/alerts are configured through the web UI on first run.
      settings = {
        HOST = "0.0.0.0";
        PORT = "3001";
      };
    };

    # ntfy is a tiny push-notification server — pairs with uptime-kuma
    # alerts so your machines can ping your phone without a SaaS.
    services.ntfy-sh = {
      enable = true;

      settings = {
        base-url = "http://lazarus:3002";
        listen-http = ":3002";

        auth-file = "/var/lib/ntfy-sh/user.db";
        auth-default-access = "deny-all";

        behind-proxy = false;
      };
    };

    networking.firewall.allowedTCPPorts = [
      3001 # uptime-kuma
      3002 # ntfy
    ];
  };
}
