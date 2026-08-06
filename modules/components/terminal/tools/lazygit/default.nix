{moduleWithSystem, ...}: {
  flake.nixosModules.lazygit = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.lazygit
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.lazygit = pkgs.lazygit;
  };
}
