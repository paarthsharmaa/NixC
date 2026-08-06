{
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.zsh = moduleWithSystem (
    {pkgs, ...}: {...}: {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        enableBashCompletion = true;
      };

      environment.systemPackages = [
        pkgs.zsh
      ];

      environment.shells = [
        pkgs.zsh
      ];

      users.defaultUserShell =
        pkgs.zsh;
    }
  );

  perSystem = {pkgs, ...}: {
    packages.zsh =
      pkgs.zsh;
  };
}
