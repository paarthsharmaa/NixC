{...}: {
  flake.nixosModules.hardware = {...}: {
    hardware.bluetooth.enable = true;
  };
}
