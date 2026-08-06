{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.iris = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.iris
        self'.packages.iris-apply
      ];

      # Provides the user settings database used by gsettings.
      programs.dconf.enable = true;
    }
  );

  perSystem = {
    pkgs,
    ...
  }: let
    iris = pkgs.python3Packages.buildPythonApplication {
      pname = "iris-colors";
      version = "0-unstable";

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

    irisApply = pkgs.writeShellApplication {
      name = "iris-apply";

      runtimeInputs = [
        iris
        pkgs.coreutils
        pkgs.glib
        pkgs.hyprland
        pkgs.python3
      ];

      text = ''
        set -euo pipefail

        if [[ $# -ne 1 ]]; then
          echo "Usage: iris-apply /path/to/wallpaper" >&2
          exit 1
        fi

        wallpaper="$(${pkgs.coreutils}/bin/realpath "$1")"

        if [[ ! -f "$wallpaper" ]]; then
          echo "Wallpaper does not exist: $wallpaper" >&2
          exit 1
        fi

        # Iris automatically determines whether the wallpaper should
        # produce a dark or light palette.
        iris "$wallpaper"

        mode="$(
          ${pkgs.python3}/bin/python3 <<'PY'
        import json
        from pathlib import Path

        colors_file = Path.home() / ".cache" / "iris" / "colors.json"
        colors = json.loads(colors_file.read_text())

        def luminance(value: str) -> float:
            value = value.lstrip("#")
            rgb = [
                int(value[index:index + 2], 16) / 255
                for index in (0, 2, 4)
            ]

            linear = [
                channel / 12.92
                if channel <= 0.04045
                else ((channel + 0.055) / 1.055) ** 2.4
                for channel in rgb
            ]

            return (
                0.2126 * linear[0]
                + 0.7152 * linear[1]
                + 0.0722 * linear[2]
            )

        background = luminance(colors["bg"])
        foreground = luminance(colors["fg"])

        print(
            "prefer-dark"
            if background < foreground
            else "default"
        )
        PY
        )"

        gsettings set \
          org.gnome.desktop.interface \
          color-scheme \
          "$mode"

        # Reload declarative Hyprland files that consume Iris outputs.
        if [[ -n "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
          hyprctl reload >/dev/null || true
        fi

        echo "Iris palette generated from: $wallpaper"
        echo "System colour scheme: $mode"
        echo "Palette directory: $HOME/.cache/iris"
      '';
    };
  in {
    packages = {
      inherit iris;
      iris-apply = irisApply;
    };
  };
}
