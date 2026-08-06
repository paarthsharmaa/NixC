{moduleWithSystem, ...}: {
  flake.nixosModules.librewolf = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.librewolf
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.librewolf = pkgs.librewolf.override {
      extraPrefs = ''
        // Keep normal persistent cookies.
        pref("network.cookie.lifetimePolicy", 0);

        // Do not delete authentication and site storage on shutdown.
        pref("privacy.clearOnShutdown.cookies", false);
        pref("privacy.clearOnShutdown.offlineApps", false);
        pref("privacy.clearOnShutdown.sessions", false);
        pref("privacy.clearOnShutdown.siteSettings", false);

        // Current combined cookie/storage shutdown category.
        pref("privacy.clearOnShutdown_v2.cookiesAndStorage", false);
      '';
    };
  };
}
