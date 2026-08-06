{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.dolphin = moduleWithSystem (
    {
      self',
      pkgs,
      ...
    }: {...}: {
      environment.systemPackages = [
        self'.packages.dolphin

        # Archive support
        pkgs.kdePackages.ark
        pkgs.p7zip
        pkgs.unzip

        # Network protocols and richer KIO support
        pkgs.kdePackages.kio-extras

        # File previews
        pkgs.kdePackages.kdegraphics-thumbnailers
        pkgs.ffmpegthumbnailer
        pkgs.poppler-utils
      ];

      # Required for mounting and inspecting removable storage.
      services.udisks2.enable = true;

      xdg.mime.defaultApplications = {
        "inode/directory" = "org.kde.dolphin.desktop";
      };
    }
  );

  perSystem = {pkgs, ...}: {
    packages.dolphin = inputs.wrappers.lib.wrapPackage (
      {...}: {
        inherit pkgs;

        package = pkgs.kdePackages.dolphin;

        env = {
          QT_QPA_PLATFORMTHEME = "qt6ct";
          QT_STYLE_OVERRIDE = "kvantum";
        };
      }
    );
  };
}
