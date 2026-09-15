{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.lazarus = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      server
      nix-ld
      development

      lazarusConfiguration
      lazarusHardware
    ];
  };
}
