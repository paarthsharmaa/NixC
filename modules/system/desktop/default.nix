{self, ...}: {
  flake.nixosModules.desktop = {
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
    ];
  };
}
