# Limine boot menu, CachyOS-style: blurred splash, Catppuccin Mocha colors,
# newest NixOS generation first, optional Windows entry for dual boot.
#
# Opt in per host by importing `limine` (replaces core's systemd-boot).
# Secure Boot is a separate per-host switch, turned on only after keys are
# enrolled (see docs/roadmap-hardening.md, "Secure Boot"):
#   boot.loader.limine.secureBoot.enable = true;
#
# With Secure Boot, Limine enrolls a hash of limine.conf into its own signed
# binary and every file it loads carries a hash, so the menu look is fixed
# at rebuild time. That's why the theme is static (no matugen here).
{...}: {
  flake.nixosModules.limine = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.nixc.boot;
  in {
    options.nixc.boot.windowsEsp = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "736b5698-5ae1-4dff-be2c-ef8f44a61c52";
      description = ''
        PARTUUID of the EFI partition that holds Windows Boot Manager (find it
        with `lsblk -o NAME,PARTUUID,PARTTYPENAME`). Adds a "Windows" entry;
        it can be on another drive. Null = no Windows entry.
      '';
    };

    config = {
      # core sets systemd-boot with mkDefault, so this plain value wins.
      boot.loader.systemd-boot.enable = false;

      # Menu countdown in seconds (NixOS default: 5). Limine stops the
      # countdown on any key press, so the menu stays open once you touch
      # an arrow key.
      boot.loader.timeout = lib.mkDefault 10;

      boot.loader.limine = {
        enable = true;
        efiSupport = true;
        # Each generation's kernel + initrd is copied to the 1 GiB ESP;
        # 10 keeps it from filling up (5 shown, 5 in "Older generations",
        # see extraInstallCommands). Older ones stay bootable via
        # `nixos-rebuild --rollback` as long as they aren't garbage collected.
        maxGenerations = 10;

        # Runs after nixpkgs' installer has written limine.conf, enrolled
        # its hash into Limine and (under Secure Boot) signed Limine.
        # The install script runs with an empty PATH, so tools need full
        # store paths.
        extraInstallCommands = let
          esp = config.boot.loader.efi.efiSysMountPoint;
          lim = config.boot.loader.limine;
          bin = "${pkgs.coreutils}/bin";
          conf = "${esp}/limine/limine.conf";
          efi = "${esp}/EFI/limine/BOOTX64.EFI";
          distro = config.system.nixos.distroName;
          visibleGenerations = 5;
        in ''
          # 1. Menu group: "NixOS" instead of nixpkgs' hard-coded
          #    "NixOS default profile".
          ${pkgs.gnused}/bin/sed -i 's|^/+${distro} default profile$|/+${distro}|' ${conf}

          # 2. Only the newest ${toString visibleGenerations} generations sit at the top;
          #    the rest move one level down into a collapsed "Older
          #    generations" folder (Enter opens it, arrows scroll).
          #    Generations are `//Generation N` lines, newest first, and the
          #    number of leading `/` is the nesting depth.
          ${pkgs.gawk}/bin/awk -v keep=${toString visibleGenerations} '
            /^# .* boot entries end here/ { inmenu = 0 }
            inmenu && /^\/\/[^\/]/ { if (++gen == keep + 1) print "//Older generations" }
            inmenu && gen > keep && /^\// { $0 = "/" $0 }
            { print }
            /^\/\+/ { inmenu = 1 }
          ' ${conf} > ${conf}.tmp
          ${bin}/mv ${conf}.tmp ${conf}

          # 3. Those edits changed limine.conf, so its enrolled hash no longer
          #    matches. Redo the installer's last steps on a fresh Limine:
          #    enroll the new hash (same BLAKE2B the installer computes)
          #    and re-sign it for Secure Boot.
          ${lib.optionalString lim.enrollConfig ''
            ${bin}/cp --no-preserve=mode ${lim.package}/share/limine/BOOTX64.EFI ${efi}
            ${lim.package}/bin/limine enroll-config ${efi} \
              "$(${bin}/b2sum ${conf} | ${bin}/cut -d' ' -f1)"
          ''}
          ${lib.optionalString lim.secureBoot.enable ''
            ${lim.secureBoot.sbctl}/bin/sbctl sign ${efi}
          ''}

          # 4. The firmware's fallback path (used if the "Limine" boot entry
          #    is ever lost, e.g. after a firmware reset) gets a copy of the
          #    finished (enrolled + signed) Limine; it reads the same
          #    /limine/limine.conf on the ESP.
          ${bin}/mkdir -p ${esp}/EFI/BOOT
          ${bin}/cp ${efi} ${esp}/EFI/BOOT/BOOTX64.EFI
        '';

        # Windows Boot Manager on its own ESP (any drive). Under Secure Boot
        # the firmware checks Microsoft's signature on it, so no Limine hash
        # is needed and Windows updates don't break the entry.
        extraEntries = lib.optionalString (cfg.windowsEsp != null) ''
          /Windows
            comment: Windows Boot Manager
            protocol: efi
            path: guid(${cfg.windowsEsp}):/EFI/Microsoft/Boot/bootmgfw.efi
        '';

        style = {
          wallpapers = [./limine-splash.png];
          wallpaperStyle = "stretched";

          interface = {
            branding = config.networking.hostName;
            brandingColor = "6c7086"; # overlay0
            helpColor = "a6e3a1"; # green: "ARROWS Select"
          };

          graphicalTerminal = {
            # No font.scale: Limine picks it from each machine's resolution
            # (1x below 2560x1440, 2x from there, 4x from 5120x2880), so
            # text stays about the same physical size on every screen.
            # Catppuccin Mocha: black red green yellow blue pink teal text.
            palette = "1e1e2e;f38ba8;a6e3a1;f9e2af;89b4fa;f5c2e7;94e2d5;cdd6f4";
            brightPalette = "585b70;f38ba8;a6e3a1;f9e2af;89b4fa;f5c2e7;94e2d5;ffffff";
            foreground = "cdd6f4";
            brightForeground = "ffffff";
            # TTRRGGBB, TT = transparency: ff = fully see-through, so the
            # splash shows behind the text instead of Limine's grey box.
            background = "ff000000";
            brightBackground = "1e1e2e";
            margin = 0;
            marginGradient = 0;
          };
        };
      };

      # Secure Boot key tool: `sbctl status`, `sbctl create-keys`,
      # `sbctl enroll-keys --microsoft`, `sbctl verify`.
      environment.systemPackages = [pkgs.sbctl];
    };
  };
}
