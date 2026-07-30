{ inputs, ... }: {
  flake.nixosModules.yogaHardware = {...}: {
    imports = [
      inputs.nixos-hardware.nixosModules.lenovo-yoga-6-13ALC6
    ];
  };
}

