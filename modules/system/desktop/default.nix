{
  self, 
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.desktop = moduleWithSystem ({ ... }: let 
    modules =  with self.nixosModules; [
      core
      hyprland
      network
    ];
  in {
    imports = modules;
  });
}
