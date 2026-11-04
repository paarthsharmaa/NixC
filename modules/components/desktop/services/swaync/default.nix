{
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.swaync = moduleWithSystem (
    {self', ...}: {lib, ...}: {
      environment.systemPackages = [
        self'.packages.swaync
      ];

      environment.etc = {
        "xdg/swaync/config.json".source =
          ./config.json;

        # Fallback when no theme has been applied yet; theme-apply links a
        # matugen-colored copy to ~/.config/swaync/style.css, which wins.
        "xdg/swaync/style.css".source =
          "${self'.packages.swaync}/etc/xdg/swaync/style.css";
      };

      systemd.user.services.swaync = {
        description = "Sway Notification Center";

        wantedBy = ["graphical-session.target"];
        partOf = ["graphical-session.target"];
        after = ["graphical-session.target"];

        serviceConfig = {
          ExecStart =
            lib.getExe self'.packages.swaync;

          Restart = "on-failure";
          RestartSec = 2;
        };
      };
    }
  );

  perSystem = {pkgs, ...}: {
    # swaync with two small source patches (overrideAttrs rebuilds the
    # nixpkgs package with our extra postPatch step):
    # - plain c / d clear notifications / toggle Do Not Disturb inside the
    #   panel (upstream only reacts to Shift+C / Shift+D). Handled by the
    #   panel itself, so no global keybinds are captured.
    # - the panel ignores other surfaces' reserved space (quickshell's pill
    #   reserves the top 60px), so it can sit in the top-right corner.
    #   Upstream's "exclusive-zone": false means a 100px zone instead.
    packages.swaync = pkgs.swaynotificationcenter.overrideAttrs (old: {
      postPatch =
        (old.postPatch or "")
        + ''
          substituteInPlace src/controlCenter/widgets/notifications/notifications.vala \
            --replace-fail 'case "C" :' 'case "c" : case "C" :' \
            --replace-fail 'case "D" :' 'case "d" : case "D" :'
          substituteInPlace src/controlCenter/controlCenter.vala \
            --replace-fail 'case "D":' 'case "d": case "D":' \
            --replace-fail 'control_center_exclusive_zone ? 0 : 100' 'control_center_exclusive_zone ? 0 : -1'
        '';
    });
  };
}
