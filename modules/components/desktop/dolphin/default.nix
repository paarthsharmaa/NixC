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

        # KIO protocol support
        pkgs.kdePackages.kio-extras
        pkgs.kdePackages.kio-fuse

        # File previews
        pkgs.kdePackages.kdegraphics-thumbnailers
        pkgs.ffmpegthumbnailer
        pkgs.poppler-utils
      ];

      # USB/removable-storage management
      services.udisks2.enable = true;

      # Required by kio-fuse / non-local KIO URLs
      programs.fuse.enable = true;

      # Android phones, cameras, media players, etc.
      services.udev.packages = [
        pkgs.libmtp.out
        pkgs.media-player-info
      ];

      # iPhone / iPad USB communication
      services.usbmuxd.enable = true;

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
