{self, ...}: {
  flake.nixosModules.qol = {
    imports = with self.nixosModules; [
      iris
      qtTheme

      dolphin
      fuzzel

      brave
      librewolf
      defaultApps

      # Documents
      zathura
      libreoffice
      lokus
      obsidian

      # Media
      mpv
      spotify
      loupe
      persepolis
    ];
  };
}
