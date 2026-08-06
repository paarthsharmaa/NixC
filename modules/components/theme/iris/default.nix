{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.iris = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.iris
      ];

      programs.dconf.enable = true;

      environment.etc = {
        "xdg/iris/templates/quickshell.json".source =
          ./templates/quickshell.json;

        "xdg/iris/templates/swaync.css".source =
          ./templates/swaync.css;
      };
    }
  );

  perSystem = {pkgs, ...}: {
    packages.iris =
      pkgs.python3Packages.buildPythonApplication {
        pname = "iris-colors";
        version = "0.1.0";

        src = inputs.iris;
        pyproject = true;

        build-system = with pkgs.python3Packages; [
          hatchling
        ];

        dependencies = with pkgs.python3Packages; [
          numpy
          pillow
        ];
      };
  };
}
