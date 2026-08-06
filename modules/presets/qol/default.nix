{self, ...}: {
  flake.nixosModules.qol = {
    imports = with self.nixosModules; [
      qtTheme

      dolphin
      superfile
      fuzzel

      brave
      librewolf
      defaultApps
      
      screenshots
      clipboard
    ];
  };
}
