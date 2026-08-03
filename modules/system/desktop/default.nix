{self, ...}: {
  flake.nixosModules.desktop = {
    modules = with self.nixosModules; [
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
