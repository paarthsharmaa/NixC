{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.claudeCode = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.claudeCode];
    }
  );
  perSystem = {pkgs, inputs', self', ...}: {
    packages.claudeCode = inputs.wrappers.lib.wrapPackage (
      {...}: {
        inherit pkgs;
        package = inputs'.llm-agents.packages.claude-code;
        runtimePkgs = [self'.packages.git];
      }
    );
  };
}
