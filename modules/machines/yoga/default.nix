{ self, inputs, ... }: {

  flake.nixosConfigurations.yoga = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      yogaConfiguration
      yogaHardware
    ];
  };
}
