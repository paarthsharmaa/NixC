{ inputs, ... }: 
{
  flake.nixosModules.legionHardware = {...}: {
    imports = [
      inputs.nixos-hardware.nixosModules.lenovo-legion-16ach6h
    ];
  };
}
