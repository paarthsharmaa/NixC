{ ... }: {
  flake.nixosModules.yogaConfiguration = {...}: {
    networking.hostName = "yoga";
  };
}
