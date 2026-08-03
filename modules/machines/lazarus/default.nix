{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.lazarus = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      core
      network
      nix-ld
      development

      lazarusConfiguration
      lazarusHardware
    ];
  };
}
