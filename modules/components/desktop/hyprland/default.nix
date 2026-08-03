{moduleWithSystem, ...}: {
  flake.nixosModules.hyprland = moduleWithSystem (
    {self', ...}: {pkgs, ...}: {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;

        package = self'.packages.hyprland;
      };

      # Stable path that can point at a new store version after rebuilding.
      environment.etc."xdg/hypr/nixc".source = ./config;

      # UWSM loads compositor-specific environment files from XDG config
      # directories before launching Hyprland.
      environment.etc."xdg/uwsm/env-hyprland".text = ''
        export HYPRLAND_CONFIG=/etc/xdg/hypr/nixc/hyprland.lua
      '';

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
      };

      environment.systemPackages = with pkgs; [
        brightnessctl
        fuzzel
        grim
        hyprlock
        playerctl
        slurp
        wireplumber
        wl-clipboard
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.hyprland = pkgs.hyprland;
  };
}
