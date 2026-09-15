{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.wiremix = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.wiremix
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.wiremix = inputs.wrappers.lib.wrapPackage (
      {...}: {
        inherit pkgs;

        package = pkgs.wiremix;
      }
    );
  };
}
