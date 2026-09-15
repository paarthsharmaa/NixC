{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.iris = moduleWithSystem (
    {self', ...}: {lib, ...}: {
      environment.systemPackages = [
        self'.packages.iris
        self'.packages.iris-apply
      ];

      programs.dconf.enable = true;

      systemd.user.services.iris-restore = {
        description = "Re-apply iris colors after login";

        wantedBy = ["graphical-session.target"];
        partOf = ["graphical-session.target"];
        after = ["graphical-session.target"];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.getExe' self'.packages.iris-apply "iris-apply"} --restore";
        };
      };
    }
  );

  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: let
    # wlogout theme template. Icon fills are recolored at runtime by
    # iris-apply (to the palette fg), so urls are relative to the
    # rendered css location (~/.cache/iris/).
    wlogoutTemplate =
      pkgs.writeText "wlogout.css" ''
        * {
          all: unset;
          font-family: "JetBrainsMono Nerd Font";
        }

        window {
          background-color: rgba({bg.rgb}, 0.88);
        }

        button {
          background-color: rgba({surface.rgb}, 0.0);
          background-repeat: no-repeat;
          background-position: center;
          background-size: 24%;
          border-radius: 24px;
          transition: all 0.25s ease;
        }

        button:focus, button:active, button:hover {
          background-color: rgba({surface.rgb}, 0.65);
          background-size: 36%;
        }

        #lock { background-image: url("icons/lock.svg"); }
        #logout { background-image: url("icons/logout.svg"); }
        #suspend { background-image: url("icons/suspend.svg"); }
        #reboot { background-image: url("icons/reboot.svg"); }
        #shutdown { background-image: url("icons/shutdown.svg"); }
      '';

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

          install -m644 \
            ${./templates/gtk.css} \
            "$template_dir/gtk.css"

          install -m644 \
            ${./templates/Iris.kvconfig} \
            "$template_dir/Iris.kvconfig"

          install -m644 \
            ${./templates/hyprlock.conf} \
            "$template_dir/hyprlock.conf"

          install -m644 \
            ${./templates/kdeglobals} \
            "$template_dir/kdeglobals"

          install -m644 \
            ${wlogoutTemplate} \
            "$template_dir/wlogout.css"
        '';
      };

    packages.iris-apply = let
      binPath = lib.makeBinPath [
        self'.packages.iris
        self'.packages.kitty
        pkgs.hyprland
        pkgs.glib
        pkgs.gsettings-desktop-schemas
        pkgs.swaynotificationcenter
        pkgs.coreutils
        pkgs.gnused
        pkgs.wlogout
      ];
      # the wrapped kitty bin dir has no `kitten` (remote-control client),
      # so call the real one directly - `kitty @` spawns an error window
      # when kitten is missing from PATH.
      kitten = lib.getExe' pkgs.kitty "kitten";
    in
      pkgs.writeShellScriptBin "iris-apply" ''
        export PATH=${binPath}:$PATH
        export XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:$XDG_DATA_DIRS

        # restore mode: re-run iris on the last wallpaper, then re-apply
        if [ "''${1:-}" = "--restore" ]; then
          [ -f "$HOME/.cache/iris/last-cmd" ] || exit 0
          set -- $(cat "$HOME/.cache/iris/last-cmd")
        else
          printf '%s\0' "$@" > "$HOME/.cache/iris/last-cmd"
        fi

        wallpaper="$1"
        [ -n "$wallpaper" ] || exit 0

        iris "$@"
        . "$HOME/.cache/iris/colors.sh"

        # wallpaper symlink for hyprlock
        ln -sf "$wallpaper" "$HOME/.cache/iris/wallpaper"

        # GTK css (running apps pick it up on next launch)
        mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
        ln -sf "$HOME/.cache/iris/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
        ln -sf "$HOME/.cache/iris/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"

        # KDE palette (dolphin etc.) - plain file, no store symlinks here
        cp -f "$HOME/.cache/iris/kdeglobals" "$HOME/.config/kdeglobals"

        # wlogout icons recolored to the palette fg at runtime, so they
        # stay visible on both dark and light themes. Relative "icons/"
        # urls in the css resolve from the css location.
        rm -rf "$HOME/.cache/iris/icons"
        mkdir -p "$HOME/.cache/iris/icons"
        for f in ${pkgs.wlogout}/share/wlogout/assets/*.svg; do
          sed "s|<path |<path fill=\"''${fg}\" |g" "$f" \
            > "$HOME/.cache/iris/icons/$(basename "$f")"
        done
        mkdir -p "$HOME/.config/wlogout"
        ln -sfn "$HOME/.cache/iris/icons" "$HOME/.config/wlogout/icons"
        ln -sf "$HOME/.cache/iris/wlogout.css" "$HOME/.config/wlogout/style.css"

        # hyprlock config (re-read on every lock)
        mkdir -p "$HOME/.config/hypr"
        ln -sf "$HOME/.cache/iris/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"

        # Kvantum theme
        # rm -f: old home-manager generations left a read-only store symlink here
        rm -f "$HOME/.config/Kvantum/kvantum.kvconfig"
        mkdir -p "$HOME/.config/Kvantum/Iris"
        cp "$HOME/.cache/iris/Iris.kvconfig" \
          "$HOME/.config/Kvantum/Iris/Iris.kvconfig"
        printf '[General]\ntheme=Iris\n' > "$HOME/.config/Kvantum/kvantum.kvconfig"

        # kitty — live recolor of all open windows
        # kitty appends its PID to the listen_on socket, so glob for every instance
        for sock in /tmp/iris-kitty.sock*; do
          [ -S "$sock" ] && \
            ${kitten} @ --to "unix:$sock" set-colors \
              --all "$HOME/.cache/iris/colors-kitty.conf" 2>/dev/null
        done || true

        # hyprland borders — hot via the lua parser (hyprctl keyword is
        # rejected with lua configs: "keyword can't work with non-legacy parsers").
        # active border is a two-color gradient from the palette so the
        # theme change is visible across wallpapers.
        if [ -f "$HOME/.cache/iris/colors.sh" ]; then
          . "$HOME/.cache/iris/colors.sh"
          if hyprctl activewindow >/dev/null 2>&1; then
            hyprctl eval "hl.config({general = {col = {active_border = {colors = {\"rgba(''${accent#"#"}ff)\", \"rgba(''${color6#"#"}ff)\"}, angle = 45}, inactive_border = \"rgba(''${surface#"#"}aa)\"}}})" >/dev/null
          fi
        fi

        # swaync — css + config reload
        swaync-client -rs -R 2>/dev/null || true

        # GTK color scheme preference (moved from Wallpaper.qml)
        case " $* " in
          *" --dark 1 "*)
            gsettings set org.gnome.desktop.interface color-scheme prefer-dark || true
            ;;
          *" --dark 0 "*)
            gsettings set org.gnome.desktop.interface color-scheme default || true
            ;;
        esac
      '';
  };
}
