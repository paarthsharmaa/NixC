{moduleWithSystem, ...}: {
  flake.nixosModules.lazydocker = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.lazydocker
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.lazydocker = pkgs.lazydocker;
  };
}
