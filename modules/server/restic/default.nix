{...}: {
  flake.nixosModules.restic = {...}: {
    # Local disk backup target; swap `path` for a B2/S3 URI when you
    # want off-site copies (restic supports s3://, b2:, rest:).
    services.restic.backups.lazarus-local = {
      initialize = true;

      repository = "/mnt/backups/lazarus";

      passwordFile = "/etc/nixos/restic-password";

      paths = [
        "/var/lib/forgejo"
        "/var/lib/postgresql"
        "/home/paarth/.local/share/syncthing"
        "/etc/nixos"
      ];

      exclude = [
        "*.tmp"
        "node_modules"
      ];

      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
      ];
    };
  };
}
