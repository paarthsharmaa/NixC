{...}: {
  flake.nixosModules.legionConfiguration = {...}: {
    networking.hostName = "legion";
    system.stateVersion = "26.05";
  };
}
