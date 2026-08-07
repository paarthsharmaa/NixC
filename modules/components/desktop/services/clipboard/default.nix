{moduleWithSystem, ...}: {
  flake.nixosModules.clipboard = moduleWithSystem (
    {
      self',
      pkgs,
      ...
    }: {...}: {
      environment.systemPackages = [
        pkgs.wl-clipboard
        pkgs.cliphist
        pkgs.fuzzel
        self'.packages.clipboard-picker
      ];

      systemd.user.services = {
        cliphist-text = {
          description = "Store text clipboard history";

          wantedBy = ["graphical-session.target"];
          after = ["graphical-session.target"];
          partOf = ["graphical-session.target"];

          serviceConfig = {
            ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";
            Restart = "on-failure";
          };
        };

        cliphist-image = {
          description = "Store image clipboard history";

          wantedBy = ["graphical-session.target"];
          after = ["graphical-session.target"];
          partOf = ["graphical-session.target"];

          serviceConfig = {
            ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store";
            Restart = "on-failure";
          };
        };
      };
    }
  );

  perSystem = {pkgs, ...}: {
    packages.clipboard-picker = pkgs.writeShellApplication {
      name = "clipboard-picker";

      runtimeInputs = with pkgs; [
        cliphist
        fuzzel
        wl-clipboard
      ];

      text = ''
        cliphist list \
          | fuzzel --dmenu --with-nth 2 --prompt "Clipboard > " \
          | cliphist decode \
          | wl-copy
      '';
    };
  };
}
