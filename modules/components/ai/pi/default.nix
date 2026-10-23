{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.pi = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.pi];
    }
  );

  perSystem = {pkgs, inputs', ...}: {
    packages.pi = inputs.wrappers.lib.wrapPackage (
      {...}: {
        inherit pkgs;
        package = inputs'.llm-agents.packages.pi;
      }
    );
  };
}
