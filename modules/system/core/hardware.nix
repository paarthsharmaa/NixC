{
  self, 
  inputs,
  ...
}: {
  flake.nixosModuels.hardware = {
    pkgs,
    lib,
    ...
  }: {
    hardware = {
      bluetooth.enable = true;
    };
  };
}
