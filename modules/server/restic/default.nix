{...}: {
  flake.nixosModules.restic = {
    config,
    lib,
    pkgs,
    ...
  }: {
    # Dump PostgreSQL immediately before restic reads it; copying a live
    # PostgreSQL data directory does not produce a consistent backup.
    services.postgresqlBackup = lib.mkIf config.services.postgresql.enable {
      enable = true;
      startAt = [];
    };

    # Local disk backup target; swap `path` for a B2/S3 URI when you
    # want off-site copies (restic supports s3://, b2:, rest:).
    services.restic.backups.lazarus-local = {
      initialize = true;

      repository = "/mnt/backups/${config.networking.hostName}";

      passwordFile = "/etc/nixos/restic-password";

      paths =
        ["/etc/nixos"]
        ++ lib.optional config.services.forgejo.enable config.services.forgejo.stateDir
        ++ lib.optional config.services.postgresql.enable config.services.postgresqlBackup.location
        ++ lib.optionals config.services.syncthing.enable [
          config.services.syncthing.dataDir
          config.services.syncthing.configDir
        ];

      backupPrepareCommand = ''
        #!${pkgs.runtimeShell}
        set -eu
        # The disk is optional at boot; never write backups onto the root disk.
        ${pkgs.util-linux}/bin/mountpoint -q /mnt/backups
        ${lib.optionalString config.services.postgresql.enable ''
          ${pkgs.systemd}/bin/systemctl start postgresqlBackup.service
        ''}
      '';

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

    systemd.services.restic-backups-lazarus-local.unitConfig.RequiresMountsFor = ["/mnt/backups"];
  };
}
