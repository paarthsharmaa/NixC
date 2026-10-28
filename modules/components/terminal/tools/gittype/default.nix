{moduleWithSystem, ...}: {
  flake.nixosModules.gittype = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.gittype];
    }
  );

  perSystem = {inputs', ...}: {
    packages.gittype = inputs'.gittype.packages.default;
  };
}
