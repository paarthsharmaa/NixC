{moduleWithSystem, ...}: {
  flake.nixosModules.hyprland = moduleWithSystem (
    {self', ...}: {pkgs, ...}: {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;

        package = self'.packages.hyprland;
      };
      environment.etc."xdg/uwsm/env-hyprland".text = ''
        export HYPRLAND_CONFIG=${./config/hyprland.lua}
      '';
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };
      environment.systemPackages = with pkgs; [
        brightnessctl
        fuzzel
        grim
        hyprlock
        playrctl
        slurp
        wl-clipboard
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.hyprland = pkgs.hyprland;
  };
}
