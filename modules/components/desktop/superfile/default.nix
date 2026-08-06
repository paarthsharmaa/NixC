{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.superfile = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.superfile
      ];
    }
  );

  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: let
    configFile = pkgs.writeText "superfile-config.toml" (
      builtins.readFile ./config.toml
    );
  in {
    packages.superfile = inputs.wrappers.lib.wrapPackage (
      {...}: {
        inherit pkgs;

        package = pkgs.superfile;

        # These become available specifically when Superfile runs.
        runtimePkgs = with pkgs; [
          bat
          exiftool
          file
          mediainfo
          xdg-utils
          zoxide
        ];

        env = {
          EDITOR = lib.getExe self'.packages.nvim;
          VISUAL = lib.getExe self'.packages.nvim;
        };

        flags = {
          "--config-file" = configFile;
        };
      }
    );
  };
}
