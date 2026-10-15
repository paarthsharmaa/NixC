{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.libreoffice = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.libreoffice];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.libreoffice = inputs.wrappers.lib.wrapPackage (
      {...}: {
        inherit pkgs;
        package = pkgs.libreoffice-qt;
      }
    );
  };
}
