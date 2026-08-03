{...}: {
  flake.nixosModules.user = {pkgs, ...}: {
    users.users.paarth = {
      isNormalUser = true;
      description = "Paarth Sharma";
      shell = pkgs.bashInteractive;

      extraGroups = [
        "audio"
        "networkmanager"
        "video"
        "wheel"
      ];
    };
  };
}
