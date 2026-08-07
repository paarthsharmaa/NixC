{
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.quickshell =
    moduleWithSystem (
      {
        self',
        pkgs,
        ...
      }: {lib, ...}: {
        environment.etc."xdg/quickshell".source =
          ./config;

        environment.systemPackages = [
          self'.packages.quickshell

          # Keep this available as a normal command too.
          pkgs.brightnessctl
        ];

        systemd.user.services.quickshell = {
          description =
            "Quickshell desktop shell";

          wantedBy = [
            "graphical-session.target"
          ];

          partOf = [
            "graphical-session.target"
          ];

          after = [
            "graphical-session.target"
          ];

          path = [
            # Remaining shell helpers.
            pkgs.bash
            pkgs.coreutils
            pkgs.findutils
            pkgs.gawk
            pkgs.gnugrep
            pkgs.gnused
            pkgs.procps
            pkgs.iproute2

            # Brightness still has no QS native API.
            pkgs.brightnessctl

            # nmtui panel.
            pkgs.networkmanager

            # Shell Island extras.
            pkgs.cava
            pkgs.perl
            pkgs.imagemagick

            # Wallpaper / notification integration.
            pkgs.glib
            pkgs.libnotify

            # systemctl + UWSM app launching.
            pkgs.systemd
            pkgs.uwsm

            # hyprctl used by HyprSunset UI.
            self'.packages.hyprland

            # Commands directly used by QML.
            self'.packages.awww
            self'.packages.iris
            self'.packages.swaync
            self'.packages.kitty
          ];

          serviceConfig = {
            ExecStart =
              lib.getExe self'.packages.quickshell;

            Restart =
              "on-failure";

            RestartSec =
              2;
          };
        };
      }
    );

  perSystem = {pkgs, ...}: {
    packages.quickshell =
      pkgs.quickshell;
  };
}
