{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.yoga = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      workstation
      limine
      yogaConfiguration
      yogaHardware
    ];
  };
}
