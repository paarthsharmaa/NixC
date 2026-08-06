{moduleWithSystem, ...}: {
  flake.nixosModules.defaultApps = moduleWithSystem (
    {
      self',
      lib,
      ...
    }: {...}: {
      environment.sessionVariables = {
        BROWSER = lib.getExe self'.packages.librewolf;
      };

      xdg.mime.defaultApplications = {
        "text/html" = "librewolf.desktop";
        "x-scheme-handler/http" = "librewolf.desktop";
        "x-scheme-handler/https" = "librewolf.desktop";
        "x-scheme-handler/about" = "librewolf.desktop";
        "x-scheme-handler/unknown" = "librewolf.desktop";

        "inode/directory" = "org.kde.dolphin.desktop";
      };
    }
  );
}
