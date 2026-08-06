{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.bat = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.bat
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.bat = inputs.wrappers.lib.wrapPackage (
      {pkgs, ...}: {
        inherit pkgs;

        package = pkgs.bat;

        flags = {
          "--style" = "plain";
          "--paging" = "never";
        };

        flagSeparator = "=";
      }
    );
  };
}
