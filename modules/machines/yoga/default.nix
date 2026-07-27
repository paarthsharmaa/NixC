{ self, inputs, ... }: {

  flake.nixosConfigurations.yoga = inputs.nixpkgs.lib.nixosSystem {
    modules = [
			self.nixosModules.yogaConfiguration		
		];
  };

}
