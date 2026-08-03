{withModuleSystem, ...}: {
  flake.nixosModules.vscodium = withModuleSystem (
    {self', ...}: {...}: {
      environment.packages = [
        self'.packages.vscodium
      ];
    }
  );
  perSystem = {pkgs, ...}: {
    packages.vscodium = pkgs.vscodium;
  };
}
