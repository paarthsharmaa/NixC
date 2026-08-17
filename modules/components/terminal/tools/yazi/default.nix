{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.yazi = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.yazi
      ];
    }
  );

  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    packages.yazi = inputs.wrappers.lib.wrapPackage (
      {...}: {
        inherit pkgs;

        package = pkgs.yazi;

        runtimePkgs = with pkgs; [
          # Wayland clipboard integration
          wl-clipboard

          # Opening files/URLs with desktop applications
          xdg-utils
        ];

        env = {
          EDITOR = lib.getExe self'.packages.nvim;
          VISUAL = lib.getExe self'.packages.nvim;
        };
      }
    );
  };
}
