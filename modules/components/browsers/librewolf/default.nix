{moduleWithSystem, ...}: {
  flake.nixosModules.librewolf = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.librewolf
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.librewolf = pkgs.librewolf;
  };
}
