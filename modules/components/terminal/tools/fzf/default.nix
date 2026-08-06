{moduleWithSystem, ...}: {
  flake.nixosModules.fzf = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.fzf
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.fzf = pkgs.fzf;
  };
}
