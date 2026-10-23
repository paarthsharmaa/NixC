{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.obsidian = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.obsidian];

      xdg.mime.defaultApplications."x-scheme-handler/obsidian" = "md.obsidian.Obsidian.desktop";
    }
  );

  perSystem = {pkgs, ...}: {
    packages.obsidian = inputs.wrappers.lib.wrapPackage (
      {...}: {
        inherit pkgs;
        package = pkgs.obsidian;
      }
    );
  };
}
