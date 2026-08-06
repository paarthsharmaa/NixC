{self, ...}: {
  flake.nixosModules.workstation = {pkgs, ...}: {
    imports = with self.nixosModules; [
      desktop
      development
      qol
      ai
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
    ];
  };
}
