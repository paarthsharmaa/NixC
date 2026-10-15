{...}: {
  flake.nixosModules.headscale = {pkgs, ...}: {
    services.headscale = {
      enable = true;

      # 0.0.0.0 so LAN clients can join before the tailnet exists;
      # traffic is WireGuard-encrypted once clients are on the tailnet.
      address = "0.0.0.0";
      port = 8080;

      settings = {
        # No reverse proxy yet: plain HTTP. Replace `lazarus` with the
        # machine's LAN IP (or an mDNS/hosts name) so clients resolve it.
        server_url = "http://lazarus:8080";

        dns = {
          magic_dns = true;
          base_domain = "ts.lazarus";
          nameservers.global = ["1.1.1.1" "8.8.8.8"];
        };

        prefixes = {
          v4 = "100.64.0.0/10";
          v6 = "fd7a:115c:a1e0::/48";
        };

        derp = {
          # Embedded DERP requires HTTPS. Use public relays until TLS is set up.
          server.enabled = false;
          urls = ["https://controlplane.tailscale.com/derpmap/default"];
          auto_update_enabled = true;
        };
      };
    };

    environment.systemPackages = [
      pkgs.headscale
    ];

    networking.firewall.allowedTCPPorts = [
      8080 # headscale control plane
    ];
  };
}
