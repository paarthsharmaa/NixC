{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.legion = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      workstation
      legionConfiguration
      legionHardware
    ];
  };
}
