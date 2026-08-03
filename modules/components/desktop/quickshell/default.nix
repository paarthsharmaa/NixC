{moduleWithSystem, ...}: {
  flake.nixosModules.quickshell = moduleWithSystem (
    {self', ...}: {lib, ...}: {
      # Install your config as a named XDG Quickshell configuration.
      environment.etc."xdg/quickshell/nixc".source = ./config;

      environment.systemPackages = [
        self'.packages.quickshell
      ];

      # UWSM activates graphical-session.target after the Wayland
      # environment is ready.
      systemd.user.services.nixc-quickshell = {
        description = "Paarth's Quickshell";

        wantedBy = [
          "graphical-session.target"
        ];

        partOf = [
          "graphical-session.target"
        ];

        after = [
          "graphical-session.target"
        ];

        serviceConfig = {
          ExecStart =
            lib.getExe self'.packages.quickshell;

          Restart = "on-failure";
          RestartSec = 2;
        };
      };
    }
  );

  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.quickshell = pkgs.writeShellApplication {
      name = "nixc-qs";

      text = ''
        exec ${lib.getExe pkgs.quickshell} \
          --config nixc \
          "$@"
      '';

      derivationArgs.meta = {
        mainProgram = "nixc-qs";
        description = "Paarth's Quickshell configuration";
      };
    };
  };
}
