{moduleWithSystem, ...}: {
  flake.nixosModules.hyprland =
    moduleWithSystem (
      {self', ...}: {lib, pkgs, ...}: {
        programs.hyprland = {
          enable = true;
          withUWSM = true;

          xwayland.enable = true;

          package =
            self'.packages.hyprland;
        };

        services.displayManager.sessionPackages = [
          (pkgs.writeTextFile {
            name = "hyprland-uwsm-session";
            destination = "/share/wayland-sessions/hyprland-uwsm.desktop";
            text = ''
              [Desktop Entry]
              Name=Hyprland (UWSM)
              Comment=Hyprland compositor managed by UWSM
              Exec=${lib.getExe pkgs.uwsm} start -F -- /run/current-system/sw/bin/start-hyprland
              Type=Application
              DesktopNames=Hyprland
            '';
            derivationArgs.passthru.providedSessions = ["hyprland-uwsm"];
          })
        ];

        services.displayManager.defaultSession =
          "hyprland-uwsm";

        programs.hyprlock.enable =
          true;

        environment.etc."xdg/hypr/nixc".source =
          ./config;

        environment.etc."xdg/uwsm/env-hyprland".text = ''
          export HYPRLAND_CONFIG=/etc/xdg/hypr/nixc/hyprland.lua
        '';
      }
    );

  perSystem = {pkgs, ...}: {
    packages.hyprland =
      pkgs.hyprland;
  };
}
