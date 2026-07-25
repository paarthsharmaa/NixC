{ self, inputs, ... }: {

  flake.nixosConfigurations.legion = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosConfigurations.legionConfiguration
    ];
  };

}
