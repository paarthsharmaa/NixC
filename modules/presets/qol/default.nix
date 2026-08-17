{self, ...}: {
  flake.nixosModules.qol = {
    imports = with self.nixosModules; [
      iris
      qtTheme

      dolphin
      yazi
      fuzzel
      

      brave
      librewolf
      defaultApps
    ];
  };
}
