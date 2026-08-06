{
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.quickshell = moduleWithSystem (
    {self', ...}: {lib, ...}: {
      # Contents become:
      # /etc/xdg/quickshell/shell.qml
      # /etc/xdg/quickshell/Pill.qml
      # /etc/xdg/quickshell/panels/...
      # /etc/xdg/quickshell/services/...
      environment.etc."xdg/quickshell".source =
        ./config;

      environment.systemPackages = [
        self'.packages.quickshell
      ];

      environment.sessionVariables = {
        WALLPAPER_DIR = "$HOME/Pictures/Wallpapers";
      };

      systemd.user.services.quickshell = {
        description = "Quickshell desktop shell";

        wantedBy = ["graphical-session.target"];
        partOf = ["graphical-session.target"];
        after = ["graphical-session.target"];

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
    packages.quickshell = pkgs.quickshell;
  };
}
