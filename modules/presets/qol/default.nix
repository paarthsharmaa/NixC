{self, ...}: {
  flake.nixosModules.qol = {
    imports = with self.nixosModules; [
      qtTheme

      dolphin
      superfile
      fuzzel
      
      iris
      swaync
      awww

      brave
      librewolf
      defaultApps
      
      screenshots
      clipboard
    ];
  };
}
