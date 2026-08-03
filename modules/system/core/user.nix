{...}: {
  flake.nixosModules.user = {...}: {
    users.users.paarth = {
      isNormalUser = true;
      description = "Paarth Sharma";

      extraGroups = [
        "audio"
        "networkmanager"
        "video"
        "wheel"
      ];
    };
  };
}
