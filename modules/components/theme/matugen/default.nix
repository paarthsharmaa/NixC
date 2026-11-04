# Wallpaper-based theming with matugen (Material You colors).
#
# `theme-apply <wallpaper> [dark|light]` runs matugen, which renders every
# template below into ~/.cache/matugen, then links/copies those files to where
# each app looks and live-reloads what can be reloaded. The quickshell
# wallpaper picker calls it, and the `theme-restore` user service re-runs the
# last call on every login.
{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.matugen = moduleWithSystem (
    {self', ...}: {lib, ...}: {
      environment.systemPackages = [
        self'.packages.matugen
        self'.packages.theme-apply
      ];

      # gsettings (GTK dark/light preference) needs dconf.
      programs.dconf.enable = true;

      systemd.user.services.theme-restore = {
        description = "Re-apply the last matugen theme after login";

        wantedBy = ["graphical-session.target"];
        partOf = ["graphical-session.target"];
        after = ["graphical-session.target"];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.getExe self'.packages.theme-apply} --restore";
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
    out = name: "~/.cache/matugen/${name}";

    # swaync: keep upstream's (good) stylesheet and append our palette
    # overrides, so only colors and a few details change.
    swayncTemplate = pkgs.runCommand "matugen-swaync.css" {} ''
      cat ${pkgs.swaynotificationcenter}/etc/xdg/swaync/style.css \
        ${./templates/swaync-colors.css} > "$out"
    '';

    # Small shell-readable palette for theme-apply's own steps.
    colorsSh = pkgs.writeText "colors.sh" ''
      on_surface='{{colors.on_surface.default.hex}}'
    '';

    template = input: name: {
      input_path = input;
      output_path = out name;
    };

    # matugen's config file. Paths become /nix/store paths when this is
    # turned into TOML, so templates are read straight from the store.
    config = (pkgs.formats.toml {}).generate "matugen.toml" {
      # Extra colors (for terminals etc.), shifted towards the wallpaper's
      # hue so they match the rest of the palette.
      config.custom_colors = {
        red = "#e5534b";
        green = "#57ab5a";
        yellow = "#c69026";
        blue = "#539bf5";
        magenta = "#b083f0";
        cyan = "#39c5cf";
      };

      templates = {
        quickshell = template ./templates/quickshell.json "quickshell.json";
        swaync = template swayncTemplate "swaync.css";
        gtk = template ./templates/gtk.css "gtk.css";
        kdeglobals = template ./templates/kdeglobals "kdeglobals";
        qt = template ./templates/qt-colors.conf "qt-colors.conf";
        hyprland = template ./templates/hyprland-colors.lua "hyprland-colors.lua";
        hyprlock = template ./templates/hyprlock.conf "hyprlock.conf";
        wlogout = template ./templates/wlogout.css "wlogout.css";
        kitty = template ./templates/kitty-colors.conf "kitty-colors.conf";
        nvim = template ./templates/nvim-colors.lua "nvim-colors.lua";
        tmux = template ./templates/tmux-colors.conf "tmux-colors.conf";
        sddm = template ./templates/sddm-theme.conf "sddm-theme.conf";
        shell = template colorsSh "colors.sh";
      };
    };

    cursor = "BreezeX-RosePine-Linux";
    cursorSize = "24";
    uiFont = "Noto Sans";
  in {
    # `matugen ...` with our config baked in.
    packages.matugen = inputs.wrappers.lib.wrapPackage (
      {...}: {
        inherit pkgs;
        package = pkgs.matugen;
        flags."--config" = "${config}";
      }
    );

    packages.theme-apply = pkgs.writeShellApplication {
      name = "theme-apply";

      runtimeInputs = [
        self'.packages.matugen
        self'.packages.hyprland
        pkgs.coreutils
        pkgs.gnused
        pkgs.glib # gsettings
        pkgs.librsvg # rsvg-convert, for wlogout's icons
        pkgs.neovim-unwrapped # only as a remote client to running nvims
        self'.packages.tmux # same socket location as the user's tmux
        pkgs.swaynotificationcenter # swaync-client
      ];

      # Colors come from the sourced colors.sh, which shellcheck can't see.
      excludeShellChecks = ["SC2154"];

      text = ''
        # gsettings needs the GNOME interface schema.
        export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:''${XDG_DATA_DIRS:-}"

        cache="$HOME/.cache/matugen"
        config="$HOME/.config"
        mkdir -p "$cache"

        # --restore: replay the last wallpaper/mode (used at login).
        if [ "''${1:-}" = "--restore" ]; then
          [ -f "$cache/last-args" ] || exit 0
          mapfile -d "" -t last < "$cache/last-args"
          set -- "''${last[@]}"
        fi

        wallpaper="''${1:-}"
        mode="''${2:-dark}"

        if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
          echo "usage: theme-apply <wallpaper> [dark|light]" >&2
          exit 1
        fi

        # Material scheme: tonal-spot (balanced, soft accents; MATUGEN_SCHEME
        # overrides). Light mode also gets --lightness-light, which pulls
        # every tone ~7% darker: stock Material light surfaces are tone 98,
        # almost pure white; this turns them into soft wallpaper tints.
        scheme="''${MATUGEN_SCHEME:-scheme-tonal-spot}"
        case "$mode" in
          dark)
            icons="Papirus-Dark"; gtk_theme="adw-gtk3-dark"; prefer_dark=1
            lightness=(--lightness-dark 0)
            ;;
          light)
            icons="Papirus-Light"; gtk_theme="adw-gtk3"; prefer_dark=0
            lightness=(--lightness-light -0.07)
            ;;
          *) echo "mode must be dark or light" >&2; exit 1 ;;
        esac

        printf '%s\0' "$wallpaper" "$mode" > "$cache/last-args"

        # Pick the source color. matugen lists the wallpaper's main colors
        # best-first (Material's own ranking, which already weighs how much
        # of the image each color covers). Keep its top pick unless that one
        # is really grey (HSL saturation < 12%, e.g. a grey photo with a red
        # car); then take the most saturated candidate. Saturation, not raw
        # RGB spread, so dark-but-tinted colors (navy, slate) count as
        # colors: a mostly black-and-slate wallpaper gives a slate theme, not
        # one tinted by a small red detail. An explicit index also stops
        # matugen from asking interactively.
        saturation() {
          local hex="''${1#\#}" r g b max min sum
          r=$((16#''${hex:0:2})); g=$((16#''${hex:2:2})); b=$((16#''${hex:4:2}))
          max=$r; min=$r
          for c in $g $b; do
            [ "$c" -gt "$max" ] && max=$c
            [ "$c" -lt "$min" ] && min=$c
          done
          sum=$((max + min))
          [ "$sum" -gt 255 ] && sum=$((510 - sum))
          [ "$sum" -eq 0 ] && { echo 0; return; }
          echo $((100 * (max - min) / sum))
        }
        mapfile -t candidates < <(matugen image "$wallpaper" --show-source-colors 2>/dev/null | grep -oE '#[0-9a-fA-F]{6}')
        index=0
        if [ "''${#candidates[@]}" -gt 0 ] && [ "$(saturation "''${candidates[0]}")" -lt 12 ]; then
          best_sat=12
          for i in "''${!candidates[@]}"; do
            sat=$(saturation "''${candidates[$i]}")
            if [ "$sat" -gt "$best_sat" ]; then
              index=$i
              best_sat=$sat
            fi
          done
        fi

        matugen image "$wallpaper" \
          --mode "$mode" \
          --type "$scheme" \
          --source-color-index "$index" \
          "''${lightness[@]}" \
          --quiet

        # shellcheck source=/dev/null
        . "$cache/colors.sh"

        # Replace a file even if it is a stale (read-only) home-manager link.
        put() { mkdir -p "$(dirname "$2")"; rm -f "$2"; cp -f "$1" "$2"; }
        link() { mkdir -p "$(dirname "$2")"; ln -sfn "$1" "$2"; }

        # SDDM (login screen): same wallpaper and colors. It runs as its own
        # user and can't read ~, so both go to /var/lib/nixc-theme (made
        # writable for us by the sddm module); pixie reads theme.conf.user.
        sddm_dir=/var/lib/nixc-theme
        if [ -w "$sddm_dir" ]; then
          ext="''${wallpaper##*.}"
          rm -f "$sddm_dir"/wallpaper.*
          cp -f "$wallpaper" "$sddm_dir/wallpaper.$ext"
          chmod 644 "$sddm_dir/wallpaper.$ext"
          sed "s|@WALLPAPER@|$sddm_dir/wallpaper.$ext|" "$cache/sddm-theme.conf" \
            > "$sddm_dir/theme.conf.user.tmp"
          chmod 644 "$sddm_dir/theme.conf.user.tmp"
          mv -f "$sddm_dir/theme.conf.user.tmp" "$sddm_dir/theme.conf.user"
        fi

        # hyprlock reads ~/.cache/matugen/wallpaper as its background.
        ln -sfn "$wallpaper" "$cache/wallpaper"
        link "$cache/hyprlock.conf" "$config/hypr/hyprlock.conf"

        # GTK 3/4: theme, icons, cursor, dark preference and colors.
        for v in 3.0 4.0; do
          link "$cache/gtk.css" "$config/gtk-$v/gtk.css"
          rm -f "$config/gtk-$v/settings.ini"
          printf '%s\n' \
            "[Settings]" \
            "gtk-theme-name=$gtk_theme" \
            "gtk-icon-theme-name=$icons" \
            "gtk-cursor-theme-name=${cursor}" \
            "gtk-cursor-theme-size=${cursorSize}" \
            "gtk-font-name=${uiFont} 11" \
            "gtk-application-prefer-dark-theme=$prefer_dark" \
            > "$config/gtk-$v/settings.ini"
        done
        gsettings set org.gnome.desktop.interface color-scheme "prefer-$mode" || true
        gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme" || true
        gsettings set org.gnome.desktop.interface icon-theme "$icons" || true
        gsettings set org.gnome.desktop.interface cursor-theme "${cursor}" || true
        gsettings set org.gnome.desktop.interface cursor-size "${cursorSize}" || true

        # Qt: qt6ct/qt5ct palette + Breeze style + icons; KDE apps (Dolphin)
        # also read kdeglobals. Apps pick this up on next launch.
        sed "s/@ICON_THEME@/$icons/" "$cache/kdeglobals" > "$cache/kdeglobals.tmp"
        put "$cache/kdeglobals.tmp" "$config/kdeglobals"
        for qt in qt6ct qt5ct; do
          style=Darkly
          [ "$qt" = qt5ct ] && style=Fusion
          rm -f "$config/$qt/$qt.conf"
          mkdir -p "$config/$qt"
          printf '%s\n' \
            "[Appearance]" \
            "color_scheme_path=$cache/qt-colors.conf" \
            "custom_palette=true" \
            "icon_theme=$icons" \
            "standard_dialogs=default" \
            "style=$style" \
            "" \
            "[Fonts]" \
            "fixed=\"JetBrainsMono Nerd Font,11\"" \
            "general=\"${uiFont},11\"" \
            > "$config/$qt/$qt.conf"
        done

        # wlogout: GTK can't load SVGs in wlogout's environment, so render
        # the stock icons to PNG, colored like the text.
        rm -rf "$cache/icons"
        mkdir -p "$cache/icons"
        for f in ${pkgs.wlogout}/share/wlogout/assets/*.svg; do
          sed "s|<path |<path fill=\"$on_surface\" |g" "$f" \
            | rsvg-convert --width 256 --height 256 \
              --output "$cache/icons/$(basename "$f" .svg).png"
        done
        link "$cache/icons" "$config/wlogout/icons"
        link "$cache/wlogout.css" "$config/wlogout/style.css"

        # swaync reads ~/.config/swaync/style.css before /etc/xdg.
        link "$cache/swaync.css" "$config/swaync/style.css"
        swaync-client --reload-css >/dev/null 2>&1 || true

        # kitty: recolor every open window (each instance appends its PID
        # to the socket name). New windows include kitty-colors.conf.
        for sock in /tmp/kitty-theme.sock*; do
          [ -S "$sock" ] || continue
          ${lib.getExe' pkgs.kitty "kitten"} @ --to "unix:$sock" \
            set-colors --all --configured "$cache/kitty-colors.conf" >/dev/null 2>&1 || true
        done

        # tmux: re-source the colors in the running server (if any).
        tmux source-file -q "$cache/tmux-colors.conf" >/dev/null 2>&1 || true

        # Neovim: tell every running instance to reload its colors.
        for sock in "''${XDG_RUNTIME_DIR:-/run/user/$UID}"/nvim.*; do
          [ -S "$sock" ] || continue
          nvim --clean --headless --server "$sock" \
            --remote-expr 'execute("lua pcall(_G.MatugenReload)")' >/dev/null 2>&1 || true
        done

        # Hyprland: borders/shadow (also loaded at startup by common/theme.lua)
        # and the cursor.
        if hyprctl activewindow >/dev/null 2>&1; then
          hyprctl eval "dofile('$cache/hyprland-colors.lua')" >/dev/null || true
          hyprctl setcursor "${cursor}" "${cursorSize}" >/dev/null 2>&1 || true
        fi
      '';
    };
  };
}
