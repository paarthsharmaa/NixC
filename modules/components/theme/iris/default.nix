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
    }
  );

  perSystem = {pkgs, ...}: let
    swayncTemplate =
      pkgs.runCommand "iris-swaync-template.css" {} ''
        install -m 0644 \
          ${pkgs.swaynotificationcenter}/etc/xdg/swaync/style.css \
          "$out"

        cat >> "$out" <<'EOF'

        :root {
          --cc-bg: rgba({bg.rgb}, 0.96);

          --noti-border-color: rgba({fg.rgb}, 0.14);
          --noti-bg: {surface.rgb};
          --noti-bg-alpha: 0.94;
          --noti-bg-darker: {bg};
          --noti-bg-hover: {color8};
          --noti-bg-focus: rgba({accent.rgb}, 0.22);

          --noti-close-bg: {surface};
          --noti-close-bg-hover: {red};

          --text-color: {fg};
          --text-color-disabled: {dim};

          --bg-selected: {accent};
        }
        EOF
      '';
  in {
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

        # Make the templates built-in so the normal `iris` command
        # finds them without ~/.config/iris.
        postInstall = ''
          template_dir="$out/${pkgs.python3.sitePackages}/iris/templates"

          mkdir -p "$template_dir"

          install -m644 \
            ${./templates/quickshell.json} \
            "$template_dir/quickshell.json"

          install -m644 \
            ${swayncTemplate} \
            "$template_dir/swaync.css"
        '';
      };
  };
}
