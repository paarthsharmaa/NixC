{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.fastfetch = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.fastfetch];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.fastfetch = inputs.wrappers.lib.wrapPackage (
      inherit pkgs;
      package = pkgs.fastfetch;
    );
  };
}
