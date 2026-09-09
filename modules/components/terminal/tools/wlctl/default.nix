{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.wlctl = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.wlctl];
    }
  );

  perSystem = {inputs', ...}: {
    packages.wlctl = inputs'.wlctl.packages.default;
  };
}
