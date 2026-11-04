# Power menu. wlogout only looks for its layout in ~/.config/wlogout and in
# its own package (not /etc/xdg), so the layout is passed as a flag.
# The style (colors + recolored icons) is written to ~/.config/wlogout by
# theme-apply; before any theme is applied, wlogout's stock style is used.
{
  inputs,
  lib,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.wlogout = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.wlogout];
    }
  );

  perSystem = {pkgs, ...}: let
    # wlogout's layout is NOT a JSON array: it's one JSON object per button,
    # back to back. So each button is encoded on its own and joined.
    layout = pkgs.writeText "wlogout-layout" (lib.concatMapStringsSep "\n" builtins.toJSON [
      {
        label = "lock";
        action = "hyprlock";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "logout";
        action = "uwsm stop";
        text = "Logout";
        keybind = "e";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "Suspend";
        keybind = "s";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        keybind = "x";
      }
    ]);
  in {
    packages.wlogout = inputs.wrappers.lib.wrapPackage (
      {...}: {
        inherit pkgs;
        package = pkgs.wlogout;
        flags = {
          "--layout" = "${layout}";
          "--buttons-per-row" = "5";
          # One centered row instead of full-height buttons.
          "--margin-top" = "380";
          "--margin-bottom" = "380";
          "--margin-left" = "160";
          "--margin-right" = "160";
          "--column-spacing" = "24";
        };
      }
    );
  };
}
