{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.opencode = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.opencode
      ];
    }
  );

  perSystem = {pkgs, inputs', self', ...}: {
    packages.opencode = inputs.wrappers.wrappers.opencode.wrap {
      inherit pkgs;
      package = inputs'.llm-agents.packages.opencode2;

      runtimePkgs = [
        self'.packages.git
        self'.packages.fd
        pkgs.jq
        self'.packages.rg
      ];

      settings = {
        "$schema" = "https://opencode.ai/config.json";

        autoupdate = false;

        permission = {
          edit = "ask";
          bash = "ask";
        };
      };
    };
  };
}
