{self, ...}: {
  flake.nixosModules.workstation = {pkgs, ...}: {
    imports = with self.nixosModules; [
      desktop
      development
      qol
      ai

      kitty
      vscodium
      tools
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
    ];
  };
}
