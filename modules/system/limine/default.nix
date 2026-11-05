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

      boot.loader.limine = {
        enable = true;
        efiSupport = true;
        # Each generation's kernel + initrd is copied to the 1 GiB ESP;
        # 10 keeps it from filling up. Older ones stay bootable via
        # `nixos-rebuild --rollback` as long as they aren't garbage collected.
        maxGenerations = 10;

        # The firmware's fallback path (used if the "Limine" boot entry is
        # ever lost, e.g. after a firmware reset) gets a copy of Limine.
        # This runs after the installer has signed Limine and enrolled the
        # config hash, so the copy works under Secure Boot too, and it finds
        # the same /limine/limine.conf on the ESP.
        extraInstallCommands = let
          esp = config.boot.loader.efi.efiSysMountPoint;
        in ''
          mkdir -p ${esp}/EFI/BOOT
          cp ${esp}/EFI/limine/BOOTX64.EFI ${esp}/EFI/BOOT/BOOTX64.EFI
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
