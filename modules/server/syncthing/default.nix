{...}: {
  flake.nixosModules.syncthing = {...}: {
    services.syncthing = {
      enable = true;

      user = "paarth";
      group = "users";

      dataDir = "/home/paarth/.local/share/syncthing";
      configDir = "/home/paarth/.config/syncthing";

      guiAddress = "0.0.0.0:8384";
      openDefaultPorts = true;

      # Peers and shares are managed through the web UI.
      overrideDevices = false;
      overrideFolders = false;

      settings = {
        gui = {
          enabled = true;
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
    ];
  };
}
