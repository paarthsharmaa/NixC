{...}: {
  flake.nixosModules.loupe = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.loupe
    ];
  };
}
