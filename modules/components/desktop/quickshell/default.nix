{
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.quickshell = moduleWithSystem (
    {
      self',
      pkgs,
      ...
    }: {lib, ...}: {
      # Bare XDG config deliberately permits running plain `qs`.
      environment.etc."xdg/quickshell".source =
        ./config;

      environment.systemPackages = [
        self'.packages.quickshell
        self'.packages.awww
        self'.packages.iris
        self'.packages.swaync
        self'.packages.kitty

        # Shell and standard command dependencies
        pkgs.bash
        pkgs.coreutils
        pkgs.findutils
        pkgs.gawk
        pkgs.gnugrep
        pkgs.gnused
        pkgs.procps
        pkgs.iproute2

        # Services called from QML
        pkgs.pamixer
        pkgs.brightnessctl
        pkgs.playerctl
        pkgs.networkmanager
        pkgs.power-profiles-daemon
        pkgs.hyprsunset

        # Visualizer and wallpaper thumbnails
        pkgs.cava
        pkgs.perl
        pkgs.imagemagick

        # Notifications and appearance
        pkgs.libnotify
        pkgs.glib
      ];

      services.power-profiles-daemon.enable = true;

      systemd.user.services.quickshell = {
        description = "Quickshell desktop shell";

        wantedBy = ["graphical-session.target"];
        partOf = ["graphical-session.target"];

        wants = [
          "awww.service"
          "swaync.service"
        ];

        after = [
          "graphical-session.target"
          "awww.service"
          "swaync.service"
        ];

        path = [
          # Shell + normal Unix utilities used by QML.
          pkgs.bash
          pkgs.coreutils
          pkgs.findutils
          pkgs.gawk
          pkgs.gnugrep
          pkgs.gnused
          pkgs.procps
          pkgs.iproute2

          # Hardware / desktop controls.
          pkgs.pamixer
          pkgs.brightnessctl
          pkgs.playerctl
          pkgs.networkmanager
          pkgs.power-profiles-daemon
          pkgs.hyprsunset

          # Shell Island extras.
          pkgs.cava
          pkgs.perl
          pkgs.imagemagick

          # Commands called from panels.
          pkgs.systemd
          pkgs.glib

          # Your configured packages called from QML.
          self'.packages.awww
          self'.packages.iris
          self'.packages.swaync
          self'.packages.kitty
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

  perSystem = {pkgs, ...}: {
    packages.quickshell =
      pkgs.quickshell;
  };
}
