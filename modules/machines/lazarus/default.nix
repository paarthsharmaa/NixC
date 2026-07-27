{ self, inputs, ...}: {

  flake.nixosConfigurations.lazarus = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.lazarusConfiguration
    ];
  };

}
