{moduleWithSystem, ...}: {
  flake.nixosModules.eza = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.eza
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.eza = pkgs.eza;
  };
}
