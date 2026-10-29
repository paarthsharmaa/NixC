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
    packages.nvim = inputs.wrappers.wrappers.neovim.wrap {
      inherit pkgs;

      # Compatibility fix for the pinned wrapper's deprecated platform check.
      # Remove when the wrappers input uses hostPlatform in this builder.
      builderFunction = import (builtins.toFile "neovim-symlinkScript.nix" (
        builtins.replaceStrings
        ["stdenv.isLinux"]
        ["stdenv.hostPlatform.isLinux"]
        (builtins.readFile "${inputs.wrappers}/wrapperModules/n/neovim/symlinkScript.nix")
      ));

      settings.config_directory = ./config;

      # Lua plugins use LSP subprocesses, not Neovim remote plugin hosts.
      hosts.python3.nvim-host.enable = false;
      hosts.node.nvim-host.enable = false;
      hosts.ruby.nvim-host.enable = false;

      runtimePkgs = with pkgs; [
        # Required by lazy.nvim.
        git

        # Search and picker tools.
        fd
        fzf
        ripgrep

        # Wayland clipboard provider.
        wl-clipboard

        # Language tools come from the project's devenv shell.
      ];
    };
  };
}
