{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.fuzzel = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.fuzzel ]; }
  );

  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    packages.fuzzel = inputs.wrappers.wrappers.fuzzel.wrap {
      inherit pkgs;

      settings = {
        main = {
          terminal = lib.getExe self'.packages.kitty;

          font = "JetBrainsMono Nerd Font:size=13";
          prompt = "❯ ";

          layer = "overlay";
          width = 50;
          lines = 12;

          horizontal-pad = 18;
          vertical-pad = 12;
          inner-pad = 8;
        };

        border = {
          width = 2;
          radius = 10;
        };
      };
    };
  };
}
