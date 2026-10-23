{inputs, moduleWithSystem, ...}: {
  flake.nixosModules.codex = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.codex];
    }
  );

  perSystem = {pkgs, inputs', self', ...}: {
    packages.codex = inputs.wrappers.lib.wrapPackage(
      {...}: {
        inherit pkgs;
        package = inputs'.llm-agents.packages.codex;
        runtimePkgs = [self'.packages.git];
      }
    );
  };
}
