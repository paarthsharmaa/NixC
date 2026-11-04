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

        # On start the daemon restores the last wallpaper by running the
        # `awww` client, so the client must be on the service's PATH (user
        # services get a minimal PATH). Without it: "exec: awww: not found"
        # and a blank wallpaper after every reboot.
        path = [self'.packages.awww];

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
