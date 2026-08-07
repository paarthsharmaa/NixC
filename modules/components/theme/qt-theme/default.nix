{moduleWithSystem, ...}: {
  flake.nixosModules.qtTheme = moduleWithSystem (
    {pkgs, ...}: {...}: {
      environment.systemPackages = with pkgs; [
        # Configuration GUIs
        kdePackages.qt6ct
        libsForQt5.qt5ct

        # Kvantum style engines
        kdePackages.qtstyleplugin-kvantum
        libsForQt5.qtstyleplugin-kvantum
      ];

      environment.sessionVariables = {
        # Most of your new Qt applications will be Qt 6.
        QT_QPA_PLATFORMTHEME = "qt6ct";
        QT_STYLE_OVERRIDE = "kvantum";
      };
    }
  );
}
