{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.sddm = moduleWithSystem (
    {self', ...}: {
      pkgs,
      lib,
      ...
    }: let
      cursor = "BreezeX-RosePine-Linux";
      cursorSize = "24";

      # The login screen runs in weston (kiosk shell). NixOS's default
      # weston.ini has no cursor settings, so it's rebuilt here with one.
      westonIni = (pkgs.formats.ini {}).generate "weston.ini" {
        libinput.enable-tap = true;
        keyboard.keymap_layout = "us";
        shell = {
          cursor-theme = cursor;
          cursor-size = cursorSize;
        };
      };
    in {
      services.displayManager.sddm = {
        enable = true;
        package = pkgs.kdePackages.sddm;

        wayland.enable = true;

        theme = "pixie";
        extraPackages = with pkgs.kdePackages; [
          qtsvg
          qtdeclarative
          qt5compat
        ];

        settings = {
          # The greeter (a Qt app) picks its cursor from these.
          Theme = {
            CursorTheme = cursor;
            CursorSize = cursorSize;
          };
          # env sets the cursor path/theme for weston itself, which draws
          # the pointer.
          Wayland.CompositorCommand = lib.concatStringsSep " " [
            "${pkgs.coreutils}/bin/env"
            "XCURSOR_PATH=/run/current-system/sw/share/icons"
            "XCURSOR_THEME=${cursor}"
            "XCURSOR_SIZE=${cursorSize}"
            "${lib.getExe pkgs.weston} --shell=kiosk -c ${westonIni}"
          ];
        };
      };

      # theme-apply (run as the user) copies the current wallpaper and a
      # matugen-colored theme.conf.user here; SDDM runs as its own user and
      # can't read ~, so it needs a shared place. 0755: SDDM can read it.
      systemd.tmpfiles.rules = [
        "d /var/lib/nixc-theme 0755 paarth users - -"
      ];

      environment.systemPackages = [
        self'.packages.pixie-sddm
      ];
    }
  );

  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    # pixie with one addition: theme.conf.user -> /var/lib/nixc-theme.
    # SDDM reads theme.conf, then theme.conf.user on top of it, so the
    # login screen follows the wallpaper picked at runtime. The store copy
    # stays read-only; only the link's target changes. (If the target
    # doesn't exist yet, SDDM just uses pixie's defaults.)
    packages.pixie-sddm = let
      pixie = inputs'.pixie-sddm.packages.pixie-sddm;
    in
      pkgs.runCommand "pixie-sddm-nixc" {} ''
        mkdir -p $out/share/sddm/themes
        cp -r ${pixie}/share/sddm/themes/pixie $out/share/sddm/themes/pixie
        chmod u+w $out/share/sddm/themes/pixie
        ln -s /var/lib/nixc-theme/theme.conf.user \
          $out/share/sddm/themes/pixie/theme.conf.user
      '';
  };
}
