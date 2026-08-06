{moduleWithSystem, ...}: {
  flake.nixosModules.codex = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.codex
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.codex = pkgs.codex;
  };
}
