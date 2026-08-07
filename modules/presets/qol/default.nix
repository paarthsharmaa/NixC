{self, ...}: {
  flake.nixosModules.qol = {
    imports = with self.nixosModules; [
      iris
      qtTheme

      dolphin
      superfile
      fuzzel
      

      brave
      librewolf
      defaultApps
    ];
  };
}
