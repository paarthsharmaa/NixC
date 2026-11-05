{self, ...}: {
  flake.nixosModules.desktop = {pkgs, ...}: {
    # App scaling has one source: the per-host monitor `scale` in
    # hyprland/config/hosts/<host>.lua. Native Wayland apps (GTK, Qt,
    # Firefox, Electron) all follow it, so no per-app scale flags.
    environment.sessionVariables = {
      # nixpkgs' Electron/Chromium wrappers then run on Wayland directly
      # (instead of possibly via XWayland, which ignores fractional scale
      # and looks blurry).
      NIXOS_OZONE_WL = "1";
      # Lets GTK and Electron apps read the desktop settings (font, color
      # scheme) theme-apply writes with gsettings; without the schemas on
      # XDG_DATA_DIRS they fall back to built-in defaults.
      XDG_DATA_DIRS = [
        "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
      ];
    };

    imports = with self.nixosModules; [
      core

      audio
      network
      power
      nix-ld

      sddm

      hyprland
      quickshell
      awww
      swaync
      hyprsunset
      clipboard
      screenshots

      wlogout
    ];
  };
}
