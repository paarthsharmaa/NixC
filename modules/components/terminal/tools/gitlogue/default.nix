{moduleWithSystem, ...}: {
  flake.nixosModules.gitlogue = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.gitlogue];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.gitlogue = pkgs.gitlogue;
  };
}
