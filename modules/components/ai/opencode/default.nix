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

  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.opencode = inputs.wrappers.wrappers.opencode.wrap {
      inherit pkgs;

      runtimePkgs = [
        self'.packages.git
        self'.packages.fd
        pkgs.jq
        self'.packages.ripgrep
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
