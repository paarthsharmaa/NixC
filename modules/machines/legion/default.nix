{ self, inputs, ... }: {

  flake.nixosConfigurations.legion = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
			desktop
      legionConfiguration
			legionHardware

    ];
  };

}
