{...}: {
  flake.nixosModules.syncthing = {...}: {
    services.syncthing = {
      enable = true;

      user = "paarth";
      group = "users";

      dataDir = "/home/paarth/.local/share/syncthing";
      configDir = "/home/paarth/.config/syncthing";

      overrideDevices = true;
      overrideFolders = true;

      settings = {
        gui = {
          enabled = true;
          address = "0.0.0.0:8384";
        };

        options = {
          # Relays/fallback only for non-tailnet peers.
          relaysEnabled = true;
          urAccepted = -1; # don't phone home for usage reporting
        };
      };
    };

    networking.firewall.allowedTCPPorts = [
      8384 # web UI
      22000 # sync protocol (tcp)
    ];
    networking.firewall.allowedUDPPorts = [
      22000 # sync protocol (quic)
      21027 # local discovery
    ];
  };
}
