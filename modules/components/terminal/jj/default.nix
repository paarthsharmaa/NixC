{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.jj = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.jj
      ];
    }
  );

  perSystem = {pkgs, ...}: {
    packages.jj = inputs.wrappers.wrappers.jujutsu.wrap {
      inherit pkgs;

      settings = {
        user = {
          name = "paarthsharmaa";
          email = "paarthsharma0912@gmai.com";
        };
      };
    };
  };
}
