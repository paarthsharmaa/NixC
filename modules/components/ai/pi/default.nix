{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.pi = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.pi];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.pi = inputs.wrappers.lib.wrapPackage (
      {...}: {
        inherit pkgs;
        package = pkgs.pi-coding-agent;
      }
    );
  };
}
