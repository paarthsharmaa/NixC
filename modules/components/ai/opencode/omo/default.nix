{
  inputs,
  moduleWithSystem,
  ...,
}: {
  flake.nixosModules.omo = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.omo]; 
    }
  );
  perSystem = {pkgs, inputs', self', ...}: {
    packages.omo = inputs.wrappers.lib.wrapPackage (
      {...}: {
        inherit pkgs;
        package = inputs'.llm-agents.packages.omo-ai;
        runtimePkgs = [self'.packages.git];
      }
    );
  };
}
