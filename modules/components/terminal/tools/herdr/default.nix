{moduleWithSystem, ...}: {
  flake.nixosModules.herdr = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.herdr
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.herdr = pkgs.herdr;
  };
}
