{
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.hyprsunset =
    moduleWithSystem (
      {pkgs, ...}: {lib, ...}: {
        environment.systemPackages = [
          pkgs.hyprsunset
        ];

        systemd.user.services.hyprsunset = {
          description =
            "HyprSunset blue-light filter";

          wantedBy = [
            "graphical-session.target"
          ];

          partOf = [
            "graphical-session.target"
          ];

          requires = [
            "graphical-session.target"
          ];

          after = [
            "graphical-session.target"
          ];

          unitConfig = {
            ConditionEnvironment =
              "WAYLAND_DISPLAY";
          };

          serviceConfig = {
            ExecStart =
              "${lib.getExe pkgs.hyprsunset} --identity";

            Slice =
              "session.slice";

            Restart =
              "on-failure";

            RestartSec =
              2;
          };
        };
      }
    );
}
