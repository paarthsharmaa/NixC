{
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.awww = moduleWithSystem (
    {self', ...}: {lib, ...}: {
      environment.systemPackages = [
        self'.packages.awww
      ];

      systemd.user.services.awww = {
        description = "AWWW wallpaper daemon";

        wantedBy = ["graphical-session.target"];
        partOf = ["graphical-session.target"];
        after = ["graphical-session.target"];

        serviceConfig = {
          ExecStart =
            lib.getExe' self'.packages.awww "awww-daemon";

          Restart = "on-failure";
          RestartSec = 2;
        };
      };
    }
  );

  perSystem = {pkgs, ...}: {
    packages.awww = pkgs.awww;
  };
}
