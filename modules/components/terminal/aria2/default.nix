{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.aria2 = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.aria2];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.aria2 = inputs.wrappers.lib.wrapPackage (
      {...}: {
        package = pkgs.aria2;
        inherit pkgs;
      }
    );
  };
}
