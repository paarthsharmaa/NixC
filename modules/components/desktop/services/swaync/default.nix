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

        "xdg/swaync/style.css".source =
          ./style.css;
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
    packages.swaync =
      pkgs.swaynotificationcenter;
  };
}
