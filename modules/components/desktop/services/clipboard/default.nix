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
        # Fallback picker (fuzzel) when quickshell isn't running.
        self'.packages.clipboard-picker
        self'.packages.clipboard-helper
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

    # Backend for quickshell's clipboard panel (list, preview, copy,
    # delete). The script lives next to this file; import-tree only loads
    # .nix files, so a .sh here is just data that readFile pulls in.
    # writeShellApplication puts runtimeInputs first on PATH and runs
    # shellcheck at build time. LibreOffice is not listed: office previews
    # use `soffice` from the system if it's installed (qol preset).
    packages.clipboard-helper = pkgs.writeShellApplication {
      name = "clipboard-helper";

      runtimeInputs = with pkgs; [
        cliphist
        wl-clipboard
        coreutils
        findutils
        gnugrep
        gnused
        file
        poppler-utils # pdftoppm, pdfinfo
        ffmpegthumbnailer
      ];

      text = builtins.readFile ./clipboard-helper.sh;
    };
  };
}
