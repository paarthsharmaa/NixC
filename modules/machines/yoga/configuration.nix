{...}: {
  flake.nixosModules.yogaConfiguration = {...}: {
    networking.hostName = "yoga";
    system.stateVersion = "26.05";
  };
}
