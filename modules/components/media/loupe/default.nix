{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.loupe = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.loupe];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.loupe = inputs.wrappers.lib.wrapPackage (
      {...}: {
        inherit pkgs;
        package = pkgs.loupe;
      }
    );
  };
}
