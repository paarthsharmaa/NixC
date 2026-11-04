# Look of GTK and Qt apps: widget style, icons and cursor.
# Colors come from matugen at runtime (see theme/matugen): theme-apply writes
# qt6ct/qt5ct palettes, kdeglobals and gtk.css into ~/.config.
{moduleWithSystem, ...}: {
  flake.nixosModules.qtTheme = moduleWithSystem (
    {pkgs, ...}: {...}: {
      environment.systemPackages = with pkgs; [
        # Qt: qt6ct/qt5ct apply the palette. Darkly (a rounded, flat Breeze
        # fork — the style end-4's dots use) is the Qt6 widget style; Breeze
        # stays installed as a fallback.
        kdePackages.qt6ct
        libsForQt5.qt5ct
        darkly
        kdePackages.breeze

        # GTK3 theme that matches libadwaita (GTK4) apps.
        adw-gtk3

        papirus-icon-theme
        rose-pine-cursor
      ];

      environment.sessionVariables = {
        QT_QPA_PLATFORMTHEME = "qt6ct";

        XCURSOR_THEME = "BreezeX-RosePine-Linux";
        XCURSOR_SIZE = "24";
      };
    }
  );
}
