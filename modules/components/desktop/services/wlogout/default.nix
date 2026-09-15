{moduleWithSystem, ...}: {
  flake.nixosModules.wlogout = moduleWithSystem (
    {self', ...}: {lib, pkgs, ...}: let
      # wlogout ships black-fill svgs; recolor to white for the dark
      # static fallback theme (the iris user-level theme overrides this
      # with runtime-recoloring once it has run).
      wlogoutWhiteIcons = pkgs.runCommand "wlogout-white-icons" {} ''
        mkdir -p "$out"
        for f in ${pkgs.wlogout}/share/wlogout/assets/*.svg; do
          sed 's|<path |<path fill="#FFFFFF" |g' "$f" > "$out/$(basename "$f")"
        done
      '';
    in {
      environment.systemPackages = [pkgs.wlogout];

      environment.etc."xdg/wlogout/layout".text = builtins.toJSON [
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
      ];

      # Static fallback theme. The user-level ~/.config/wlogout/style.css
      # (symlinked by iris-apply) overrides this once iris has run.
      environment.etc."xdg/wlogout/style.css".text = ''
        * {
          all: unset;
          font-family: "JetBrainsMono Nerd Font";
        }

        window {
          background-color: rgba(17, 17, 23, 0.85);
        }

        button {
          background-color: rgba(255, 255, 255, 0.0);
          background-repeat: no-repeat;
          background-position: center;
          background-size: 24%;
          border: none;
          border-radius: 24px;
        }

        button:focus, button:active, button:hover {
          background-color: rgba(255, 255, 255, 0.12);
          background-size: 36%;
        }

        #lock { background-image: url("${wlogoutWhiteIcons}/lock.svg"); }
        #logout { background-image: url("${wlogoutWhiteIcons}/logout.svg"); }
        #suspend { background-image: url("${wlogoutWhiteIcons}/suspend.svg"); }
        #reboot { background-image: url("${wlogoutWhiteIcons}/reboot.svg"); }
        #shutdown { background-image: url("${wlogoutWhiteIcons}/shutdown.svg"); }
      '';
    }
  );
}
