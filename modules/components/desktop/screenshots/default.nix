{
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.screenshots = moduleWithSystem (
    {self', ...}: {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        grim
        slurp
        satty
        self'.packages.screenshot-region
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.screenshot-region = pkgs.writeShellApplication {
      name = "screenshot-region";

      runtimeInputs = with pkgs; [
        coreutils
        grim
        satty
        slurp
        wl-clipboard
      ];

      text = ''
        output_dir="$HOME/Pictures/Screenshots"
        mkdir -p "$output_dir"

        geometry="$(
          slurp \
            -o \
            -r \
            -c '#89b4faff'
        )" || exit 0

        grim -g "$geometry" -t ppm - |
          satty \
            --filename - \
            --copy-command wl-copy \
            --output-filename \
              "$output_dir/screenshot-%Y%m%d-%H%M%S.png"
      '';
    };
  };
}
