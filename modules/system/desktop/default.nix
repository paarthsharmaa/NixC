{self, ...}: {
  flake.nixosModules.desktop = {
    imports = with self.nixosModules; [
      core

      audio
      network
      nix-ld

      sddm
      hyprland
      quickshell
    ];
  };
}
