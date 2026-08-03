{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.nvim = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [
        self'.packages.nvim
      ];
      environment.variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    }
  );

  perSystem = {pkgs, ...}: {
    packages.nvim = inputs.wrappers.wrappers.wrap {
      inherit pkgs;

      settings_config_directory = ./config;

      runtimePkgs = with pkgs; [
        fd
        fzf
        git
        ripgrep
        tree-sitter
      ];
    };
  };
}
