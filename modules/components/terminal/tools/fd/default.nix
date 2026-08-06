{moduleWithSystem, ...}: {
  flake.nixosModules.fd = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.fd
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.fd = pkgs.fd;
  };
}
