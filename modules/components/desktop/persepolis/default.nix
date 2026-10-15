{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.persepolis = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.persepolis];  
    }
  );

  perSystem = {pkgs, ...}: {
    packages.persepolis = inputs.wrappers.lib.wrapPackage (
      {...}: {
        package = pkgs.persepolis;
        inherit pkgs;
      }
    );
  };
}
