{moduleWithSystem, ...}: {
  flake.nixosModules.rg = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.rg
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.rg = pkgs.ripgrep;
  };
}
