{...}: {
  flake.nixosModules.legionConfiguration = {...}: {
    networking.hostName = "legion";
  };
}
