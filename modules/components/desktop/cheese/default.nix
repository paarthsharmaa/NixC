{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.cheese = moduleWithSystem (
    {self', ...}: {
      environment.systemPackages = [self'.packages.cheese];
    }
  );
  perSystem = {pkgs, ...}: {
    packages.cheese = inputs.wrappers.lib.wrapPackage (
      {...}: {
        package = pkgs.cheese;
        inherit pkgs;
      }
    );
  };
}
