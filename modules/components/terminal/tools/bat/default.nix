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
      {...}: {
        inherit pkgs;

        package = pkgs.bat;

        flags = {
          "--style" = "plain";
          "--paging" = "never";
          # Use the terminal's 16 colors, so bat follows the matugen
          # palette in kitty.
          "--theme" = "ansi";
        };

        flagSeparator = "=";
      }
    );
  };
}
