{...}: {
  flake.nixosModules.adguardhome = {
    services.adguardhome = {
      enable = true;

      # Bind to all interfaces so yoga/legion (LAN or tailnet) can use it
      # as their DNS server.
      host = "0.0.0.0";
      port = 3000;

      openFirewall = true;

      settings = {
        dns = {
          bind_hosts = ["0.0.0.0"];
          port = 53;

          upstream_dns = [
            "https://dns.cloudflare.com/dns-query"
            "https://dns.google/dns-query"
          ];

          bootstrap_dns = ["1.1.1.1" "8.8.8.8"];

          # Keep clients (yoga/legion) identifiable by hostname.
          use_private_ptr_resolvers = true;
        };

        # Blocklists are configured in the web UI on first run.
        filtering.filtering_enabled = true;

        # DHCP off; the router owns the LAN.
        dhcp.enabled = false;
      };
    };

    networking.firewall.allowedTCPPorts = [
      53 # dns
    ];
    networking.firewall.allowedUDPPorts = [
      53
    ];
  };
}
