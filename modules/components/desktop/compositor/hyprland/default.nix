{moduleWithSystem, ...}: {
  flake.nixosModules.hyprland =
    moduleWithSystem (
      {self', ...}: {...}: {
        programs.hyprland = {
          enable = true;
          withUWSM = true;

          xwayland.enable = true;

          package =
            self'.packages.hyprland;
        };

        programs.uwsm.waylandCompositors.hyprland = {
          prettyName = "Hyprland";

          comment =
            "Hyprland compositor managed by UWSM";

          binPath =
            "/run/current-system/sw/bin/Hyprland";
        };

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
