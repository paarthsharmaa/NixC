{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.kitty = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.kitty
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.kitty = let
      jetbrainsMono =
        pkgs.nerd-fonts.jetbrains-mono;

      fontsConf = pkgs.makeFontsConf {
        fontDirectories = [
          jetbrainsMono
        ];
      };
    in
      inputs.wrappers.wrappers.kitty.wrap {
        inherit pkgs;

        environment = {
          FONTCONFIG_FILE = "${fontsConf}";
        };

        font = {
          name = "JetBrainsMono Nerd Font Mono";
          size = 12;
        };

        settings = {
          scrollback_lines = 10000;

          window_padding_width = 9;
          background_opacity = 0.50;
          confirm_os_window_close = 0;
          enable_audio_bell = false;

          cursor_trail = 1;
          cursor_trail_start_threshold = 1;
          cursor_trail_color = "#cba6f7";
          cursor_shape = "beam";

          allow_remote_control = true;
        };

        keybindings = {
          "ctrl+backspace" = "send_text all \\x17";
        };

        themeFile = "Catppuccin-Mocha";
      };
  };
}
