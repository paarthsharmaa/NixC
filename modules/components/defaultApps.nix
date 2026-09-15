{moduleWithSystem, ...}: {
  flake.nixosModules.defaultApps = moduleWithSystem (
    {self', ...}:
    {lib, ...}: {
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

        # Documents
        "application/pdf" = "org.pwmt.zathura.desktop";
        "application/epub+zip" = "org.pwmt.zathura.desktop";
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "libreoffice-writer.desktop";
        "application/msword" = "libreoffice-writer.desktop";
        "application/rtf" = "libreoffice-writer.desktop";
        "application/vnd.oasis.opendocument.text" = "libreoffice-writer.desktop";
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "libreoffice-calc.desktop";
        "application/vnd.ms-excel" = "libreoffice-calc.desktop";
        "text/csv" = "libreoffice-calc.desktop";
        "application/vnd.oasis.opendocument.spreadsheet" = "libreoffice-calc.desktop";
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "libreoffice-impress.desktop";
        "application/vnd.ms-powerpoint" = "libreoffice-impress.desktop";
        "application/vnd.oasis.opendocument.presentation" = "libreoffice-impress.desktop";

        # Media
        "video/mp4" = "mpv.desktop";
        "video/mkv" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "video/webm" = "mpv.desktop";
        "video/quicktime" = "mpv.desktop";
        "audio/mpeg" = "mpv.desktop";
        "audio/mp4" = "mpv.desktop";
        "audio/x-wav" = "mpv.desktop";
        "audio/flac" = "mpv.desktop";
        "audio/ogg" = "mpv.desktop";
        "audio/x-flac" = "mpv.desktop";

        # Images
        "image/png" = "org.gnome.Loupe.desktop";
        "image/jpeg" = "org.gnome.Loupe.desktop";
        "image/gif" = "org.gnome.Loupe.desktop";
        "image/webp" = "org.gnome.Loupe.desktop";
        "image/svg+xml" = "org.gnome.Loupe.desktop";
        "image/bmp" = "org.gnome.Loupe.desktop";
        "image/heif" = "org.gnome.Loupe.desktop";
        "image/avif" = "org.gnome.Loupe.desktop";
      };
    }
  );
}
