{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.mpv = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.mpv];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.mpv = inputs.wrappers.lib.wrapPackage (
      {...}: {
        inherit pkgs;
        package = pkgs.mpv;
      }
    );
  };
}
