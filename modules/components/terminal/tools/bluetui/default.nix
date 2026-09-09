{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.bluetui = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.bluetui];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.bluetui = inputs.wrappers.lib.wrapPackage (
      {...}: {
        package = pkgs.bluetui;
        inherit pkgs;
      }
    );
  };
}
