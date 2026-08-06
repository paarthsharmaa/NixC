{moduleWithSystem, ...}: {
  flake.nixosModules.zoxide = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.zoxide
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.zoxide = pkgs.zoxide;
  };
}
