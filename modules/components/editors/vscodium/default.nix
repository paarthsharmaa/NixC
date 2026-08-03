{moduleWithSystem, ...}: {
  flake.nixosModules.vscodium = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.vscodium
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.vscodium = pkgs.vscodium;
  };
}
