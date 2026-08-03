{self, ...}: {
  flake.nixosModules.workstation = {pkgs, ...}: {
    imports = with self.nixosModules; [
      desktop
      development

      kitty
      librewolf
      vscodium
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
    ];
  };
}
