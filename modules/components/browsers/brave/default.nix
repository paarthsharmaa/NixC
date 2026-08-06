{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.brave = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.brave
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.brave = inputs.wrappers.lib.wrapPackage (
      {pkgs, ...}: {
        inherit pkgs;

        package = pkgs.brave;

        # Portable across Wayland and X11 sessions.
        flags = {
          "--ozone-platform-hint" = "auto";
        };

        flagSeparator = "=";
      }
    );
  };
}
