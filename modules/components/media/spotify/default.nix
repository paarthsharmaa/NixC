{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.spotify = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.spotify];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.spotify = inputs.wrappers.lib.wrapPackage (
      {...}: {
        inherit pkgs;
        package = pkgs.spotify;
      }
    );
  };
}
