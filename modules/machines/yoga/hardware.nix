{inputs, ...}: {
  flake.nixosModules.yogaHardware = {
    config,
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")

      inputs.nixos-hardware.nixosModules.lenovo-yoga-6-13ALC6
    ];

    # boot.initrd.availableKernelModules
    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod"];
    boot.initrd.kernelModules = [];

    # boot.kernelModules
    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [];

    # fileSystems
    fileSystems."/" = {
      device = "/dev/disk/by-uuid/88cdd806-1bbf-4184-9621-a6847c7b2ebc";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/735E-4A9D";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    # swapDevices
    swapDevices = [
      {device = "/dev/disk/by-uuid/3cf2dd48-2d32-472c-9d2c-eb730eecb702";}
    ];

    # nixpkgs.hostPlatform
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    # CPU microcode option
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
