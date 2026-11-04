{self, ...}: {
  flake.nixosModules.qol = {
    imports = with self.nixosModules; [
      matugen
      qtTheme

      dolphin
      fuzzel
      cheese

      brave
      librewolf
      defaultApps

      # Documents
      zathura
      libreoffice
      obsidian

      # Media
      mpv
      spotify
      loupe
      persepolis
    ];
  };
}
