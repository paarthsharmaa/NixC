{moduleWithSystem, ...}: {
  flake.nixosModules.gitlogue = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.gitlogue];
    }
  );

  perSystem = {inputs', ...}: {
    packages.gitlogue = inputs'.gitlogue.packages.default;
  };
}
