{...}: {
  flake.nixosModules.bootloader = {
    lib,
    pkgs,
    ...
  }: {
    boot = {
      loader = {
        # mkDefault: hosts importing `limine` switch it off.
        systemd-boot.enable = lib.mkDefault true;
        efi.canTouchEfiVariables = true;
      };

      kernelPackages = pkgs.linuxPackages_latest;
    };
  };
}
