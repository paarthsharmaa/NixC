{...}: {
  flake.nixosModules.lazarusConfiguration = {...}: {
    networking.hostName = "lazarus";
    system.stateVersion = "26.05";
  };
}
