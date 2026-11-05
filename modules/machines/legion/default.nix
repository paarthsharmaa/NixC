{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.legion = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      workstation
      limine
      legionConfiguration
      legionHardware
    ];
  };
}
