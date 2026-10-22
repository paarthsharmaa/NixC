{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.devenv = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.devenv];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.devenv = inputs.wrappers.lib.wrapPackage (
      {...}: {
        package = pkgs.devenv;
        inherit pkgs;
      }
    );
  };
}
