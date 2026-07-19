{ self, inputs, ... }:

{
  flake.nixosModules.niri =
    { pkgs, ... }:
    {
      programs.niri = {
        enable = true;
        package =
          self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
      };

      environment.systemPackages = with pkgs; [
        foot
        xwayland-satellite
      ];
    };

  perSystem =
    { pkgs, lib, ... }:

    let
      noctalia =
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      packages.myNiri =
        inputs.wrapper-modules.wrappers.niri.wrap {
          inherit pkgs;

          v2-settings = true;

          settings = {
            spawn-at-startup = [
              (lib.getExe noctalia)
            ];

            xwayland-satellite.path =
              lib.getExe pkgs.xwayland-satellite;

            input = {
              keyboard.xkb.layout = "us";

              touchpad = {
                tap = _: { };
              };
            };

            layout.gaps = 8;

            binds = {
              "Mod+Return".spawn-sh =
                lib.getExe pkgs.foot;

              "Mod+Q".close-window =
                _: { };

              "Mod+O".toggle-overview =
                _: { };

              "Mod+Space".spawn-sh =
                "${lib.getExe noctalia} msg panel-toggle launcher";

              "Mod+S".spawn-sh =
                "${lib.getExe noctalia} msg panel-toggle control-center";

              "Mod+Comma".spawn-sh =
                "${lib.getExe noctalia} msg settings-toggle";
            };
          };
        };
    };
}
