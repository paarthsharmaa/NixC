{inputs, ...}: {
  flake.nixosModules.legionHardware = {
    config,
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
      inputs.nixos-hardware.nixosModules.lenovo-legion-16ach6h
    ];

    # boot.initrd.availableKernelModules
    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
    boot.initrd.kernelModules = [];

    # boot.kernelModules
    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [];

    # fileSystems
    fileSystems."/" = {
      device = "/dev/disk/by-uuid/4ee702e5-82f4-45d7-b58d-55f1b148e98c";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/ACFC-DE76";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    # swapDevices
    swapDevices = [
      {device = "/dev/disk/by-uuid/ecdbc779-4f5f-4a70-8749-caa4463bf604";}
    ];

    # nixpkgs.hostPlatform
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    # CPU microcode option
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
