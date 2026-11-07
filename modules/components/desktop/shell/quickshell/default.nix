{moduleWithSystem, ...}: {
  flake.nixosModules.quickshell = moduleWithSystem (
    {
      self',
      pkgs,
      ...
    }: {lib, ...}: let
      # Shell settings defaults (the declarative baseline). The shell reads
      # them from defaults.json and layers runtime overrides on top from
      # ~/.local/state/nixc/shell.json (see config/services/Settings.qml),
      # so a settings UI can change things without touching the store.
      defaults = {
        bar = {
          style = "notch"; # "notch" | "pill"
          notchColor = "theme"; # "theme" | "black"
          workspaces = 5; # minimum workspace slots shown
        };
        motion.duration = 260; # ms
      };

      # ./config plus the generated defaults.json, as one store path.
      configDir = pkgs.runCommand "quickshell-config" {} ''
        cp -r ${./config} $out
        chmod u+w $out
        cp ${pkgs.writeText "defaults.json" (builtins.toJSON defaults)} $out/defaults.json
      '';
    in {
      environment.etc."xdg/quickshell".source = configDir;

      environment.systemPackages = [
        self'.packages.quickshell

        # Keep this available as a normal command too.
        pkgs.brightnessctl
      ];

      systemd.user.services.quickshell = {
        description = "Quickshell desktop shell";

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
          self'.packages.theme-apply
          self'.packages.swaync
          self'.packages.clipboard-helper

          # Apps launched from the launcher. `uwsm app` checks that a
          # desktop entry's Exec (e.g. `dolphin`) exists in *its* PATH,
          # which is inherited from this service, so the system and user
          # profiles must be on it. (makeBinPath adds the /bin.)
          "/run/wrappers"
          "/etc/profiles/per-user/paarth"
          "/run/current-system/sw"
        ];

        # Icon theme used by Quickshell.iconPath (launcher app icons).
        environment.QS_ICON_THEME = "Papirus-Dark";

        serviceConfig = {
          ExecStart = ''
            ${lib.getExe self'.packages.quickshell} \
              --path /etc/xdg/quickshell/shell.qml
          '';

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
