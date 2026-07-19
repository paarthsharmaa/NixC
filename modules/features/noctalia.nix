{ inputs, ... }:

{
  # Machine-level Noctalia setup.
  flake.nixosModules.noctalia =
    { ... }:

    {
      imports = [
        inputs.noctalia.nixosModules.default
      ];

      programs.noctalia = {
        enable = true;

        # Enables services needed for:
        # Wi-Fi, Bluetooth, battery and power profiles.
        recommendedServices.enable = true;

        # Niri will start Noctalia directly.
        systemd.enable = false;
      };
    };

  # User-level Noctalia configuration.
  flake.homeModules.noctalia =
    { ... }:

    {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      programs.noctalia = {
        enable = true;

        # Again, Niri handles startup.
        systemd.enable = false;

        settings = {
          theme = {
            mode = "dark";
            source = "builtin";
            builtin = "Catppuccin";
          };
        };
      };
    };
}
